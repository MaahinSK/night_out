const mongoose = require('mongoose');

const bookingSchema = new mongoose.Schema({
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  pub: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Pub',
    required: false
  },
  event: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Event'
  },
  bookingType: {
    type: String,
    enum: ['entry', 'table', 'event'],
    default: 'entry'
  },
  bookingDate: {
    type: Date,
    required: true
  },
  numberOfPeople: {
    type: Number,
    required: true,
    min: 1,
    default: 1
  },
  tableDetails: {
    tableId: mongoose.Schema.Types.ObjectId,
    tableNumber: String
  },
  ticketDetails: {
    ticketType: String,
    quantity: Number,
    pricePerTicket: Number
  },
  totalAmount: {
    type: Number,
    default: 0
  },
  status: {
    type: String,
    enum: ['pending', 'confirmed', 'cancelled', 'completed'],
    default: 'confirmed'
  },
  specialRequests: String,
  confirmationCode: {
    type: String,
    unique: true
  },
  createdAt: {
    type: Date,
    default: Date.now
  }
}, {
  timestamps: true
});

// Generate confirmation code before saving
bookingSchema.pre('save', function() {
  if (!this.confirmationCode) {
    this.confirmationCode = 'NO' + Date.now().toString().slice(-8) + Math.floor(Math.random() * 1000);
  }
});

const Booking = mongoose.model('Booking', bookingSchema);
module.exports = Booking;