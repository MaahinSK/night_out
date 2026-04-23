const http = require('http');
const mongoose = require('mongoose');
const dotenv = require('dotenv');

dotenv.config();

const options = (path, method = 'GET', headers = {}, body = null) => ({
  hostname: 'localhost',
  port: process.env.PORT || 5000,
  path: `/api${path}`,
  method,
  headers: {
    'Content-Type': 'application/json',
    ...headers,
  },
});

const request = (opt, body) => new Promise((resolve, reject) => {
  const req = http.request(opt, (res) => {
    let data = '';
    res.on('data', chunk => data += chunk);
    res.on('end', () => {
      try {
        resolve({ status: res.statusCode, data: JSON.parse(data) });
      } catch (e) {
        resolve({ status: res.statusCode, data });
      }
    });
  });
  req.on('error', reject);
  if (body) req.write(JSON.stringify(body));
  req.end();
});

async function runTests() {
  try {
    console.log('Testing Endpoints...');
    
    // Register user
    const email = `testuser${Date.now()}@test.com`;
    console.log(`Registering user ${email}...`);
    let res = await request(options('/auth/register', 'POST'), {
      name: 'Test User',
      email,
      password: 'password123',
      phone: '1234567890'
    });
    
    if (res.status !== 201) {
      console.error('Failed to register:', res.data);
      return;
    }
    
    const token = res.data.token;
    console.log('User registered. Token received.');
    
    // Create pub
    console.log('Creating pub...');
    // We need admin token to create pub, wait, let's see if we can create pub or if there is a pub.
    // Let's just fetch pubs
    res = await request(options('/pubs'));
    let pubId;
    if (res.data.pubs && res.data.pubs.length > 0) {
      pubId = res.data.pubs[0]._id;
      console.log('Found existing pub:', pubId);
    } else {
      console.error('No pubs found. Cannot test favorites and bookings properly without a pub. Please seed a pub or create one.');
      // Create admin user
      const adminEmail = `admin${Date.now()}@test.com`;
      let adminRes = await request(options('/auth/register', 'POST'), {
        name: 'Admin User',
        email: adminEmail,
        password: 'password123',
        phone: '1234567890',
        role: 'admin' // The register endpoint might not allow role assignment, let's check.
      });
      console.log('Created admin?', adminRes.status);
      return;
    }

    const authHeaders = { Authorization: `Bearer ${token}` };

    // Test Favorites
    console.log('Testing Add to Favorites...');
    res = await request(options(`/users/favorites/${pubId}`, 'POST', authHeaders));
    console.log('Add to favorites status:', res.status);
    console.log('Favorites:', res.data.favorites);

    console.log('Testing Get Favorites...');
    res = await request(options(`/users/favorites`, 'GET', authHeaders));
    console.log('Get favorites status:', res.status);
    console.log('Favorites count:', res.data.favorites?.length);

    console.log('Testing Remove from Favorites...');
    res = await request(options(`/users/favorites/${pubId}`, 'DELETE', authHeaders));
    console.log('Remove from favorites status:', res.status);
    console.log('Favorites count after removal:', res.data.favorites?.length);

    // Test Bookings
    console.log('Testing Create Booking...');
    const bookingPayload = {
      pubId: pubId,
      bookingType: 'table',
      bookingDate: new Date().toISOString(),
      numberOfPeople: 4,
      tableDetails: { tableNumber: '12' },
      totalAmount: 150
    };
    res = await request(options('/bookings', 'POST', authHeaders), bookingPayload);
    console.log('Create booking status:', res.status);
    console.log('Booking Data:', res.data);

    console.log('Testing Get Bookings...');
    res = await request(options('/users/bookings', 'GET', authHeaders));
    console.log('Get bookings status:', res.status);
    console.log('Bookings count:', res.data.bookings?.length);
    if (res.data.bookings?.length > 0) {
        console.log('First booking table number:', res.data.bookings[0].tableDetails?.tableNumber);
        console.log('First booking total amount:', res.data.bookings[0].totalAmount);
    }

    console.log('All tests finished.');
  } catch (error) {
    console.error('Error during testing:', error);
  }
}

runTests();
