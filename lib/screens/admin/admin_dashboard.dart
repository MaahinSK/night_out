import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.red[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.logout();
              if (!context.mounted) return;
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome Admin, ${authProvider.user?.name ?? 'User'}!',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),
            const Text(
              '🏗️ Admin Dashboard Under Construction',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'Coming soon:\n'
                  '- Manage Pubs & Events\n'
                  '- View Bookings\n'
                  '- System Controls\n'
                  '- Analytics Dashboard',
              style: TextStyle(color: Colors.grey[700], fontSize: 16),
            ),
            const SizedBox(height: 32),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.nightlife),
                      title: const Text('Total Pubs'),
                      subtitle: const Text('0 Pubs'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        // Navigate to manage pubs
                      },
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.event),
                      title: const Text('Total Events'),
                      subtitle: const Text('0 Events'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        // Navigate to manage events
                      },
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.book_online),
                      title: const Text('Total Bookings'),
                      subtitle: const Text('0 Bookings'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        // Navigate to view bookings
                      },
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
}