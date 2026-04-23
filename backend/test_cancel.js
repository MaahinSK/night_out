const http = require('http');
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
    const email = `testuser${Date.now()}@test.com`;
    let res = await request(options('/auth/register', 'POST'), {
      name: 'Test User Cancel',
      email,
      password: 'password123',
      phone: '1234567890'
    });
    const token = res.data.token;
    const authHeaders = { Authorization: `Bearer ${token}` };

    res = await request(options('/pubs'));
    const pubId = res.data.pubs[0]._id;

    console.log('Testing Create Booking...');
    res = await request(options('/bookings', 'POST', authHeaders), {
      pubId: pubId,
      bookingType: 'table',
      bookingDate: new Date().toISOString(),
      numberOfPeople: 4,
    });
    const bookingId = res.data.booking._id;
    console.log('Created booking ID:', bookingId);

    console.log('Testing Cancel Booking (User)...');
    res = await request(options(`/bookings/${bookingId}/status`, 'PUT', authHeaders), {
      status: 'cancelled'
    });
    console.log('Cancel status:', res.status);
    console.log('Booking status after cancel:', res.data.booking?.status);

    console.log('All tests finished.');
  } catch (error) {
    console.error('Error during testing:', error);
  }
}

runTests();
