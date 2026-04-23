const Booking = require('../models/Booking');
const Pub = require('../models/Pub');

// @desc    Create booking
// @route   POST /api/bookings
// @access  Private
const createBooking = async (req, res) => {
  try {
    const { 
      pubId, 
      pub,
      eventId, 
      event,
      bookingType, 
      bookingDate, 
      numberOfPeople, 
      specialRequests, 
      tableDetails, 
      ticketDetails,
      totalAmount 
    } = req.body;

    const booking = await Booking.create({
      user: req.user.id,
      pub: (pubId && pubId !== '') ? pubId : ((pub && pub !== '') ? pub : undefined),
      event: (eventId && eventId !== '') ? eventId : ((event && event !== '') ? event : undefined),
      bookingType,
      bookingDate,
      numberOfPeople,
      specialRequests,
      tableDetails,
      ticketDetails: ticketDetails ? {
        ticketType: ticketDetails.name || ticketDetails.ticketType,
        pricePerTicket: ticketDetails.price || ticketDetails.pricePerTicket,
        quantity: ticketDetails.quantity
      } : undefined,
      totalAmount
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

// @desc    Update booking status
// @route   PUT /api/bookings/:id/status
// @access  Private
const updateBookingStatus = async (req, res) => {
  try {
    const { status } = req.body;

    const booking = await Booking.findById(req.params.id);

    if (!booking) {
      return res.status(404).json({ message: 'Booking not found' });
    }

    // Check permissions: Admin can do anything, User can only cancel their own booking
    if (req.user.role !== 'admin') {
      if (booking.user.toString() !== req.user.id || status !== 'cancelled') {
        return res.status(403).json({ message: 'Not authorized to perform this action' });
      }
    }

    booking.status = status;
    await booking.save();

    res.json({
      success: true,
      booking
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error', error: error.message });
  }
};

// @desc    Delete booking (Admin only)
// @route   DELETE /api/bookings/:id
// @access  Private/Admin
const deleteBooking = async (req, res) => {
  try {
    const booking = await Booking.findById(req.params.id);

    if (!booking) {
      return res.status(404).json({ message: 'Booking not found' });
    }

    await booking.deleteOne();

    res.json({
      success: true,
      message: 'Booking removed'
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error', error: error.message });
  }
};

module.exports = {
  createBooking,
  getAllBookings,
  updateBookingStatus,
  deleteBooking
};