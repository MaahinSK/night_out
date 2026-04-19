const Booking = require('../models/Booking');
const Pub = require('../models/Pub');

// @desc    Create booking
// @route   POST /api/bookings
// @access  Private
const createBooking = async (req, res) => {
  try {
    const { pubId, eventId, bookingType, bookingDate, numberOfPeople, specialRequests } = req.body;

    const booking = await Booking.create({
      user: req.user.id,
      pub: pubId,
      event: eventId,
      bookingType,
      bookingDate,
      numberOfPeople,
      specialRequests
    });

    res.status(201).json({
      success: true,
      booking
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error', error: error.message });
  }
};

// @desc    Get all bookings (Admin only)
// @route   GET /api/bookings/admin/all
// @access  Private/Admin
const getAllBookings = async (req, res) => {
  try {
    const bookings = await Booking.find()
      .populate('user', 'name email')
      .populate('pub', 'name')
      .populate('event', 'name date')
      .sort('-createdAt');

    res.json({
      success: true,
      count: bookings.length,
      bookings
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error', error: error.message });
  }
};

// @desc    Update booking status (Admin only)
// @route   PUT /api/bookings/:id/status
// @access  Private/Admin
const updateBookingStatus = async (req, res) => {
  try {
    const { status } = req.body;

    const booking = await Booking.findByIdAndUpdate(
      req.params.id,
      { status },
      { new: true }
    );

    if (!booking) {
      return res.status(404).json({ message: 'Booking not found' });
    }

    res.json({
      success: true,
      booking
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error', error: error.message });
  }
};

module.exports = {
  createBooking,
  getAllBookings,
  updateBookingStatus
};