const mongoose = require('mongoose');

const eventSchema = new mongoose.Schema({
  name: {
    type: String,
    required: [true, 'Please add an event name'],
    trim: true
  },
  description: {
    type: String,
    default: ''
  },
  pub: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Pub',
    required: true
  },
  eventType: {
    type: String,
    enum: ['live-music', 'dj-night', 'theme-party', 'special-event', 'happy-hour'],
    default: 'dj-night'
  },
  date: {
    type: Date,
    required: true
  },
  endDate: Date,
  startTime: {
    type: String,
    default: '21:00'
  },
  endTime: {
    type: String,
    default: '02:00'
  },
  images: [{
    url: String,
    caption: String
  }],
  ticketTypes: [{
    name: String,
    price: Number,
    quantity: Number,
    sold: {
      type: Number,
      default: 0
    },
    description: String
  }],
  performers: [{
    name: String,
    role: String,
    image: String,
    bio: String
  }],
  specialOffers: String,
  ageRestriction: {
    type: Number,
    default: 18
  },
  dressCode: {
    type: String,
    default: 'Smart Casual'
  },
  capacity: {
    type: Number,
    default: 100
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

const Event = mongoose.model('Event', eventSchema);
module.exports = Event;