const express = require('express');
const router = express.Router();
const {
  createBooking,
  getAllBookings,
  updateBookingStatus,
  deleteBooking
} = require('../controllers/bookingController');
const { protect, authorize } = require('../middleware/authMiddleware');

router.use(protect); // All routes require authentication

router.post('/', createBooking);
router.get('/admin/all', authorize('admin'), getAllBookings);
router.put('/:id/status', updateBookingStatus);
router.delete('/:id', authorize('admin'), deleteBooking);

module.exports = router;