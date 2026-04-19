const express = require('express');
const router = express.Router();
const {
  getPubs,
  getPubById,
  createPub,
  updatePub,
  deletePub,
  searchPubs
} = require('../controllers/pubController');
const { protect, authorize } = require('../middleware/authMiddleware');

// Public routes
router.get('/', getPubs);
router.get('/search/:keyword', searchPubs);
router.get('/:id', getPubById);

// Admin routes
router.post('/', protect, authorize('admin'), createPub);
router.put('/:id', protect, authorize('admin'), updatePub);
router.delete('/:id', protect, authorize('admin'), deletePub);

module.exports = router;