const express = require('express');
const router = express.Router();
const {
  createBooking,
  getAllBookings,
  updateBookingStatus
} = require('../controllers/bookingController');
const { protect, authorize } = require('../middleware/authMiddleware');

router.use(protect); // All routes require authentication

router.post('/', createBooking);
router.get('/admin/all', authorize('admin'), getAllBookings);
router.put('/:id/status', authorize('admin'), updateBookingStatus);

module.exports = router;