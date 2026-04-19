const User = require('../models/User');
const Pub = require('../models/Pub');
const Booking = require('../models/Booking');


// @desc    Update user profile
// @route   PUT /api/users/profile
// @access  Private
const updateProfile = async (req, res) => {
  try {
    const { name, phone } = req.body;

    console.log('Update profile request:');
    console.log('User ID:', req.user.id);
    console.log('Request body:', req.body);

    // Find user by ID (from auth middleware)
    const user = await User.findById(req.user.id);

    if (!user) {
      console.log('User not found');
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    console.log('User before update:', {
      id: user._id,
      name: user.name,
      phone: user.phone
    });

    // Update fields if provided
    if (name) user.name = name;
    if (phone) user.phone = phone;

    // Save the updated user
    const updatedUser = await user.save();

    console.log('User after update:', {
      id: updatedUser._id,
      name: updatedUser.name,
      phone: updatedUser.phone
    });

    res.json({
      success: true,
      message: 'Profile updated successfully',
      user: {
        id: updatedUser._id,
        name: updatedUser.name,
        email: updatedUser.email,
        phone: updatedUser.phone,
        role: updatedUser.role,
        favorites: updatedUser.favorites
      }
    });
  } catch (error) {
    console.error('Update profile error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message
    });
  }
};

// @desc    Change password
// @route   PUT /api/users/change-password
// @access  Private
const changePassword = async (req, res) => {
  try {
    const { currentPassword, newPassword } = req.body;

    // Validate input
    if (!currentPassword || !newPassword) {
      return res.status(400).json({
        success: false,
        message: 'Please provide current and new password'
      });
    }

    if (newPassword.length < 6) {
      return res.status(400).json({
        success: false,
        message: 'New password must be at least 6 characters'
      });
    }

    // Get user with password field
    const user = await User.findById(req.user.id).select('+password');

    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    // Check current password
    const isMatch = await user.matchPassword(currentPassword);
    if (!isMatch) {
      return res.status(401).json({
        success: false,
        message: 'Current password is incorrect'
      });
    }

    // Set new password
    user.password = newPassword;
    await user.save();

    res.json({
      success: true,
      message: 'Password updated successfully'
    });
  } catch (error) {
    console.error('Change password error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message
    });
  }
};

// @desc    Add to favorites
// @route   POST /api/users/favorites/:pubId
// @access  Private
const addToFavorites = async (req, res) => {
  try {
    const user = await User.findById(req.user.id);
    const pubId = req.params.pubId;

    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    // Check if pub exists
    const pub = await Pub.findById(pubId);
    if (!pub) {
      return res.status(404).json({
        success: false,
        message: 'Pub not found'
      });
    }

    // Add to favorites if not already there
    if (!user.favorites.includes(pubId)) {
      user.favorites.push(pubId);
      await user.save();
    }

    // Return populated favorites
    const populatedUser = await User.findById(req.user.id).populate('favorites');

    res.json({
      success: true,
      favorites: populatedUser.favorites,
      message: 'Added to favorites'
    });
  } catch (error) {
    console.error('Add to favorites error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message
    });
  }
};

// @desc    Remove from favorites
// @route   DELETE /api/users/favorites/:pubId
// @access  Private
const removeFromFavorites = async (req, res) => {
  try {
    const user = await User.findById(req.user.id);
    const pubId = req.params.pubId;

    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    // Remove from favorites
    user.favorites = user.favorites.filter(id => id.toString() !== pubId);
    await user.save();

    // Return updated favorites
    const populatedUser = await User.findById(req.user.id).populate('favorites');

    res.json({
      success: true,
      favorites: populatedUser.favorites,
      message: 'Removed from favorites'
    });
  } catch (error) {
    console.error('Remove from favorites error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message
    });
  }
};

// @desc    Get user favorites
// @route   GET /api/users/favorites
// @access  Private
const getFavorites = async (req, res) => {
  try {
    const user = await User.findById(req.user.id).populate('favorites');

    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    res.json({
      success: true,
      favorites: user.favorites
    });
  } catch (error) {
    console.error('Get favorites error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message
    });
  }
};

// @desc    Get user bookings
// @route   GET /api/users/bookings
// @access  Private
const getUserBookings = async (req, res) => {
  try {
    const bookings = await Booking.find({ user: req.user.id })
      .populate('pub', 'name address images pricing')
      .populate('event', 'name date')
      .sort('-createdAt');

    res.json({
      success: true,
      bookings
    });
  } catch (error) {
    console.error('Get user bookings error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message
    });
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