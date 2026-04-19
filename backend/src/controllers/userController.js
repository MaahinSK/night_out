const User = require('../models/User');
const Pub = require('../models/Pub');
const Booking = require('../models/Booking');

// @desc    Update user profile
// @route   PUT /api/users/profile
// @access  Private
const updateProfile = async (req, res) => {
  try {
    const { name, phone } = req.body;

    const user = await User.findById(req.user.id);

    if (user) {
      user.name = name || user.name;
      user.phone = phone || user.phone;

      const updatedUser = await user.save();

      res.json({
        success: true,
        user: {
          id: updatedUser._id,
          name: updatedUser.name,
          email: updatedUser.email,
          phone: updatedUser.phone,
          role: updatedUser.role
        }
      });
    } else {
      res.status(404).json({ message: 'User not found' });
    }
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error', error: error.message });
  }
};

// @desc    Change password
// @route   PUT /api/users/change-password
// @access  Private
const changePassword = async (req, res) => {
  try {
    const { currentPassword, newPassword } = req.body;

    const user = await User.findById(req.user.id).select('+password');

    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    // Check current password
    const isMatch = await user.matchPassword(currentPassword);
    if (!isMatch) {
      return res.status(401).json({ message: 'Current password is incorrect' });
    }

    user.password = newPassword;
    await user.save();

    res.json({
      success: true,
      message: 'Password updated successfully'
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error', error: error.message });
  }
};

// @desc    Add to favorites
// @route   POST /api/users/favorites/:pubId
// @access  Private
const addToFavorites = async (req, res) => {
  try {
    const user = await User.findById(req.user.id);
    const pubId = req.params.pubId;

    if (!user.favorites.includes(pubId)) {
      user.favorites.push(pubId);
      await user.save();
    }

    res.json({
      success: true,
      favorites: user.favorites,
      message: 'Added to favorites'
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error', error: error.message });
  }
};

// @desc    Remove from favorites
// @route   DELETE /api/users/favorites/:pubId
// @access  Private
const removeFromFavorites = async (req, res) => {
  try {
    const user = await User.findById(req.user.id);
    const pubId = req.params.pubId;

    user.favorites = user.favorites.filter(id => id.toString() !== pubId);
    await user.save();

    res.json({
      success: true,
      favorites: user.favorites,
      message: 'Removed from favorites'
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error', error: error.message });
  }
};

// @desc    Get user favorites
// @route   GET /api/users/favorites
// @access  Private
const getFavorites = async (req, res) => {
  try {
    const user = await User.findById(req.user.id).populate('favorites');

    res.json({
      success: true,
      favorites: user.favorites
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error', error: error.message });
  }
};

// @desc    Get user bookings
// @route   GET /api/users/bookings
// @access  Private
const getUserBookings = async (req, res) => {
  try {
    const bookings = await Booking.find({ user: req.user.id })
      .populate('pub', 'name address images')
      .populate('event', 'name date')
      .sort('-createdAt');

    res.json({
      success: true,
      bookings
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error', error: error.message });
  }
};

module.exports = {
  updateProfile,
  changePassword,
  addToFavorites,
  removeFromFavorites,
  getFavorites,
  getUserBookings
};