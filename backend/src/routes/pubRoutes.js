const express = require('express');
const router = express.Router();
const {
  getPubs,
  getPubById,
  createPub,
  updatePub,
  deletePub,
  searchPubs,
  ratePub
} = require('../controllers/pubController');
const { protect, authorize } = require('../middleware/authMiddleware');

// Public routes
router.get('/', getPubs);
router.get('/search/:keyword', searchPubs);
router.get('/:id', getPubById);

// Private routes (require authentication)
router.post('/:id/rate', protect, ratePub);

// Admin routes
router.post('/', protect, authorize('admin'), createPub);
router.put('/:id', protect, authorize('admin'), updatePub);
router.delete('/:id', protect, authorize('admin'), deletePub);

module.exports = router;