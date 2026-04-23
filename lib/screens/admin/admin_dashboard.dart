import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/pub_provider.dart';
import '../../providers/booking_provider.dart';
import '../auth/login_screen.dart';
import 'manage_pubs_screen.dart';
import 'manage_events_screen.dart';
import 'manage_bookings_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PubProvider>().fetchPubs();
      context.read<BookingProvider>().fetchAllBookings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      _buildOverviewTab(),
      const ManagePubsScreen(),
      const ManageEventsScreen(),
      const ManageBookingsScreen(),
      _buildSettingsTab(),
    ];

    bool isMobile = MediaQuery.of(context).size.width < 800;
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(isMobile ? 'Admin Panel' : 'Admin Dashboard'),
        leading: isMobile ? Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ) : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          PopupMenuButton<String>(
            itemBuilder: (context) => [
              PopupMenuItem<String>(
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(authProvider.user?.name[0] ?? 'A'),
                  ),
                  title: Text(authProvider.user?.name ?? 'Admin'),
                  subtitle: Text(authProvider.user?.email ?? ''),
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem<String>(
                child: ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Logout'),
                  onTap: () async {
                    Navigator.pop(context);
                    await authProvider.logout();
                    if (!mounted) return;
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
      drawer: isMobile ? Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Theme.of(context).primaryColor),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.admin_panel_settings, size: 48, color: Colors.white),
                    SizedBox(height: 8),
                    Text('Admin Panel', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            _buildDrawerItem(0, Icons.dashboard, 'Overview'),
            _buildDrawerItem(1, Icons.nightlife, 'Pubs'),
            _buildDrawerItem(2, Icons.event, 'Events'),
            _buildDrawerItem(3, Icons.book_online, 'Bookings'),
            _buildDrawerItem(4, Icons.settings, 'Settings'),
          ],
        ),
      ) : null,
      body: Row(
        children: [
          // Sidebar Navigation (Only for desktop/large screens)
          if (!isMobile)
            NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) {
                setState(() => _selectedIndex = index);
              },
              labelType: NavigationRailLabelType.all,
              leading: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(
                      Icons.admin_panel_settings,
                      size: 32,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Admin Panel',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard),
                  label: Text('Overview'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.nightlife_outlined),
                  selectedIcon: Icon(Icons.nightlife),
                  label: Text('Pubs'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.event_outlined),
                  selectedIcon: Icon(Icons.event),
                  label: Text('Events'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.book_online_outlined),
                  selectedIcon: Icon(Icons.book_online),
                  label: Text('Bookings'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.settings_outlined),
                  selectedIcon: Icon(Icons.settings),
                  label: Text('Settings'),
                ),
              ],
            ),

          if (!isMobile) const VerticalDivider(thickness: 1, width: 1),

          // Main Content
          Expanded(
            child: screens[_selectedIndex],
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(int index, IconData icon, String label) {
    return ListTile(
      leading: Icon(icon, color: _selectedIndex == index ? Theme.of(context).primaryColor : null),
      title: Text(label, style: TextStyle(color: _selectedIndex == index ? Theme.of(context).primaryColor : null)),
      selected: _selectedIndex == index,
      onTap: () {
        setState(() => _selectedIndex = index);
        Navigator.pop(context);
      },
    );
  }

  Widget _buildOverviewTab() {
    final pubProvider = Provider.of<PubProvider>(context);
    final bookingProvider = Provider.of<BookingProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Header
          Text(
            'Welcome back, ${authProvider.user?.name ?? 'Admin'}!',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Here\'s what\'s happening with your venues today.',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),

          // Stats Cards
          LayoutBuilder(
            builder: (context, constraints) {
              int crossAxisCount = constraints.maxWidth > 1200 ? 4 : constraints.maxWidth > 800 ? 2 : 1;
              double childAspectRatio = constraints.maxWidth > 1200 ? 1.5 : constraints.maxWidth > 800 ? 2.0 : 2.0;
              
              return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: childAspectRatio,
                  children: [
                    _buildStatCard(
                      'Total Pubs',
                      pubProvider.pubs.length.toString(),
                      Icons.nightlife,
                      Colors.blue,
                      '+2 this month',
                    ),
                    _buildStatCard(
                      'Active Bookings',
                      bookingProvider.allBookings
                          .where((b) => b.status == 'confirmed')
                          .length
                          .toString(),
                      Icons.book_online,
                      Colors.green,
                      'Today: 12',
                    ),
                    _buildStatCard(
                      'Total Revenue',
                      '\$${_calculateTotalRevenue(bookingProvider)}',
                      Icons.attach_money,
                      Colors.purple,
                      '+15% vs last month',
                    ),
                    _buildStatCard(
                      'Avg Occupancy',
                      '${_calculateAvgOccupancy(pubProvider)}%',
                      Icons.people,
                      Colors.orange,
                      'Peak: 85%',
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 32),

            // Recent Bookings
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Bookings',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                TextButton(
                  onPressed: () {
                    setState(() => _selectedIndex = 3);
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildRecentBookingsTable(bookingProvider),

            const SizedBox(height: 32),

            // Quick Actions
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildQuickActionCard(
                  'Add New Pub',
                  Icons.add_business,
                  Colors.blue,
                      () {
                    setState(() => _selectedIndex = 1);
                    // Trigger add pub dialog
                  },
                ),
                _buildQuickActionCard(
                  'Create Event',
                  Icons.event_available,
                  Colors.green,
                      () {
                    setState(() => _selectedIndex = 2);
                  },
                ),
                _buildQuickActionCard(
                  'View Reports',
                  Icons.analytics,
                  Colors.purple,
                      () {
                    // Navigate to reports
                  },
                ),
                _buildQuickActionCard(
                  'System Settings',
                  Icons.settings,
                  Colors.orange,
                      () {
                    setState(() => _selectedIndex = 4);
                  },
                ),
              ],
            ),
          ],
        ),
      );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, String subtitle) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentBookingsTable(BookingProvider bookingProvider) {
    final recentBookings = bookingProvider.allBookings.take(5).toList();

    return Card(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Booking ID')),
            DataColumn(label: Text('Customer')),
            DataColumn(label: Text('Venue')),
            DataColumn(label: Text('Date')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Amount')),
          ],
          rows: recentBookings.map((booking) {
            return DataRow(
              cells: [
                DataCell(Text(booking.confirmationCode)),
                DataCell(Text(booking.userName)),
                DataCell(Text(booking.pubName)),
                DataCell(Text(booking.formattedDate)),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(booking.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      booking.status,
                      style: TextStyle(
                        color: _getStatusColor(booking.status),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                DataCell(Text('\$${booking.totalAmount.toStringAsFixed(2)}')),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildQuickActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 160,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsTab() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'System Settings',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Maintenance Mode'),
                      subtitle: const Text('Temporarily disable the app for users'),
                      value: false,
                      onChanged: (value) {},
                    ),
                    const Divider(),
                    SwitchListTile(
                      title: const Text('New User Registration'),
                      subtitle: const Text('Allow new users to sign up'),
                      value: true,
                      onChanged: (value) {},
                    ),
                    const Divider(),
                    SwitchListTile(
                      title: const Text('Booking System'),
                      subtitle: const Text('Enable/disable new bookings'),
                      value: true,
                      onChanged: (value) {},
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _calculateTotalRevenue(BookingProvider bookingProvider) {
    final total = bookingProvider.allBookings
        .where((b) => b.status == 'confirmed' || b.status == 'completed')
        .fold(0.0, (sum, b) => sum + b.totalAmount);
    return total.toStringAsFixed(0);
  }

  String _calculateAvgOccupancy(PubProvider pubProvider) {
    if (pubProvider.pubs.isEmpty) return '0';
    final avg = pubProvider.pubs
        .map((p) => p.capacity.occupancyRate)
        .reduce((a, b) => a + b) / pubProvider.pubs.length;
    return avg.toStringAsFixed(1);
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'confirmed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}