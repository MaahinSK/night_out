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

router.use(protect); // All routes require authentication

router.put('/profile', updateProfile);
router.put('/change-password', changePassword);
router.get('/favorites', getFavorites);
router.post('/favorites/:pubId', addToFavorites);
router.delete('/favorites/:pubId', removeFromFavorites);
router.get('/bookings', getUserBookings);

module.exports = router;