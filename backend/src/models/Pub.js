const mongoose = require('mongoose');

const pubSchema = new mongoose.Schema({
  name: {
    type: String,
    required: [true, 'Please add a pub name'],
    trim: true
  },
  description: {
    type: String,
    default: ''
  },
  category: {
    type: [String],
    default: ['Bar']
  },
  address: {
    street: { type: String, default: '' },
    city: { type: String, default: '' },
    state: { type: String, default: '' },
    zipCode: { type: String, default: '' },
    country: { type: String, default: '' }
  },
  contactInfo: {
    phone: { type: String, default: '' },
    email: { type: String, default: '' },
    website: { type: String, default: '' }
  },
  images: [{
    url: { type: String, default: '' },
    caption: { type: String, default: '' },
    isPrimary: { type: Boolean, default: false }
  }],
  videos: [{
    url: { type: String, default: '' },
    thumbnail: { type: String, default: '' },
    title: { type: String, default: '' }
  }],
  openingHours: {
    monday: { open: { type: String, default: '17:00' }, close: { type: String, default: '02:00' }, isOpen: { type: Boolean, default: true } },
    tuesday: { open: { type: String, default: '17:00' }, close: { type: String, default: '02:00' }, isOpen: { type: Boolean, default: true } },
    wednesday: { open: { type: String, default: '17:00' }, close: { type: String, default: '02:00' }, isOpen: { type: Boolean, default: true } },
    thursday: { open: { type: String, default: '17:00' }, close: { type: String, default: '02:00' }, isOpen: { type: Boolean, default: true } },
    friday: { open: { type: String, default: '17:00' }, close: { type: String, default: '04:00' }, isOpen: { type: Boolean, default: true } },
    saturday: { open: { type: String, default: '17:00' }, close: { type: String, default: '04:00' }, isOpen: { type: Boolean, default: true } },
    sunday: { open: { type: String, default: '17:00' }, close: { type: String, default: '02:00' }, isOpen: { type: Boolean, default: true } }
  },
  amenities: {
    type: [String],
    default: ['WiFi', 'Parking']
  },
  musicGenre: {
    type: [String],
    default: ['Pop', 'Electronic']
  },
  dressCode: {
    type: String,
    default: 'Smart Casual'
  },
  ageRestriction: {
    type: Number,
    default: 18
  },
  pricing: {
    entryFee: { type: Number, default: 20 },
    averageDrinkPrice: { type: Number, default: 10 }
  },
  capacity: {
    total: { type: Number, default: 100 },
    current: { type: Number, default: 0 }
  },
  tables: [{
    tableNumber: { type: String, default: '' },
    capacity: { type: Number, default: 4 },
    minimumSpend: { type: Number, default: 100 },
    location: { type: String, default: 'Main Floor' },
    isAvailable: { type: Boolean, default: true }
  }],
  ratings: {
    average: { type: Number, default: 0 },
    count: { type: Number, default: 0 }
  },
  isActive: {
    type: Boolean,
    default: true
  },
  featured: {
    type: Boolean,
    default: false
  },
  createdAt: {
    type: Date,
    default: Date.now
  }
}, {
  timestamps: true
});

const Pub = mongoose.model('Pub', pubSchema);
module.exports = Pub;