const express = require('express');
const router = express.Router();
const {
  createEvent,
  getEvents,
  getEventsByPub,
  updateEvent,
  deleteEvent
} = require('../controllers/eventController');
const { protect, authorize } = require('../middleware/authMiddleware');

// Public routes
router.get('/', getEvents);
router.get('/pub/:pubId', getEventsByPub);

// Admin routes
router.post('/', protect, authorize('admin'), createEvent);
router.put('/:id', protect, authorize('admin'), updateEvent);
router.delete('/:id', protect, authorize('admin'), deleteEvent);

module.exports = router;