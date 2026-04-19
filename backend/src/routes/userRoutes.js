const express = require('express');
const router = express.Router();
const {
  updateProfile,
  changePassword,
  addToFavorites,
  removeFromFavorites,
  getFavorites,
  getUserBookings
} = require('../controllers/userController');
const { protect } = require('../middleware/authMiddleware');

// All routes require authentication
router.use(protect);

router.put('/profile', updateProfile);
router.put('/change-password', changePassword);
router.get('/favorites', getFavorites);
router.post('/favorites/:pubId', addToFavorites);
router.delete('/favorites/:pubId', removeFromFavorites);
router.get('/bookings', getUserBookings);

module.exports = router;