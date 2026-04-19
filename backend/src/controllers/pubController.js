const Pub = require('../models/Pub');
const Event = require('../models/Event');

// @desc    Create pub (Admin only)
// @route   POST /api/pubs
// @access  Private/Admin
const createPub = async (req, res) => {
  try {
    console.log('Creating pub with data:', JSON.stringify(req.body, null, 2));

    // Ensure all required nested objects exist
    const pubData = {
      name: req.body.name,
      description: req.body.description || '',
      address: {
        street: req.body.address?.street || '',
        city: req.body.address?.city || '',
        state: req.body.address?.state || '',
        zipCode: req.body.address?.zipCode || '',
        country: req.body.address?.country || ''
      },
      contactInfo: {
        phone: req.body.contactInfo?.phone || '',
        email: req.body.contactInfo?.email || '',
        website: req.body.contactInfo?.website || ''
      },
      pricing: {
        entryFee: req.body.pricing?.entryFee || 0,
        averageDrinkPrice: req.body.pricing?.averageDrinkPrice || 10
      },
      capacity: {
        total: req.body.capacity?.total || 100,
        current: 0
      },
      amenities: req.body.amenities || ['WiFi', 'Parking'],
      musicGenre: req.body.musicGenre || ['Pop', 'Electronic'],
      dressCode: req.body.dressCode || 'Smart Casual',
      ageRestriction: req.body.ageRestriction || 18,
      isActive: req.body.isActive !== undefined ? req.body.isActive : true,
      featured: req.body.featured || false,
      // Set default opening hours
      openingHours: req.body.openingHours || {
        monday: { open: '17:00', close: '02:00', isOpen: true },
        tuesday: { open: '17:00', close: '02:00', isOpen: true },
        wednesday: { open: '17:00', close: '02:00', isOpen: true },
        thursday: { open: '17:00', close: '02:00', isOpen: true },
        friday: { open: '17:00', close: '04:00', isOpen: true },
        saturday: { open: '17:00', close: '04:00', isOpen: true },
        sunday: { open: '17:00', close: '02:00', isOpen: true }
      }
    };

    const pub = await Pub.create(pubData);

    console.log('Pub created successfully:', pub._id);

    res.status(201).json({
      success: true,
      pub
    });
  } catch (error) {
    console.error('Error creating pub:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message
    });
  }
};

// @desc    Get all pubs
// @route   GET /api/pubs
// @access  Public
const getPubs = async (req, res) => {
  try {
    const { featured, active, limit = 20 } = req.query;

    let query = {};
    if (featured) query.featured = featured === 'true';
    if (active) query.isActive = active === 'true';

    const pubs = await Pub.find(query)
      .limit(parseInt(limit))
      .sort('-createdAt');

    res.json({
      success: true,
      count: pubs.length,
      pubs
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error', error: error.message });
  }
};

// @desc    Get single pub
// @route   GET /api/pubs/:id
// @access  Public
const getPubById = async (req, res) => {
  try {
    const pub = await Pub.findById(req.params.id);

    if (pub) {
      // Get upcoming events for this pub
      const events = await Event.find({
        pub: pub._id,
        date: { $gte: new Date() },
        isActive: true
      }).limit(5);

      res.json({
        success: true,
        pub,
        upcomingEvents: events
      });
    } else {
      res.status(404).json({ message: 'Pub not found' });
    }
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error', error: error.message });
  }
};

// @desc    Update pub (Admin only)
// @route   PUT /api/pubs/:id
// @access  Private/Admin
const updatePub = async (req, res) => {
  try {
    let pub = await Pub.findById(req.params.id);

    if (!pub) {
      return res.status(404).json({ message: 'Pub not found' });
    }

    pub = await Pub.findByIdAndUpdate(req.params.id, req.body, {
      new: true,
      runValidators: true
    });

    res.json({
      success: true,
      pub
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error', error: error.message });
  }
};

// @desc    Delete pub (Admin only)
// @route   DELETE /api/pubs/:id
// @access  Private/Admin
const deletePub = async (req, res) => {
  try {
    const pub = await Pub.findById(req.params.id);

    if (!pub) {
      return res.status(404).json({ message: 'Pub not found' });
    }

    await pub.deleteOne();

    res.json({
      success: true,
      message: 'Pub removed'
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error', error: error.message });
  }
};

// @desc    Search pubs
// @route   GET /api/pubs/search/:keyword
// @access  Public
const searchPubs = async (req, res) => {
  try {
    const keyword = req.params.keyword;

    const pubs = await Pub.find({
      $or: [
        { name: { $regex: keyword, $options: 'i' } },
        { description: { $regex: keyword, $options: 'i' } },
        { 'address.city': { $regex: keyword, $options: 'i' } },
        { musicGenre: { $in: [new RegExp(keyword, 'i')] } }
      ],
      isActive: true
    });

    res.json({
      success: true,
      count: pubs.length,
      pubs
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error', error: error.message });
  }
};

module.exports = {
  getPubs,
  getPubById,
  createPub,
  updatePub,
  deletePub,
  searchPubs
};