// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await _apiService.getProfile();
      setState(() {
        _profile = profile['data'] ?? profile; // Handle different response format
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat profil: $e')),
      );
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Konfirmasi Logout'),
        content: Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _apiService.logout();
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    final name = _profile?['name'] ?? 'User';
    final email = _profile?['email'] ?? '';
    final createdAt = _profile?['created_at'] ?? '';

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          SizedBox(height: 20),

          // Profile Avatar
          CircleAvatar(
            radius: 60,
            backgroundColor: Colors.blue[100],
            child: Text(
              name[0].toUpperCase(),
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ),
          SizedBox(height: 16),

          // Name
          Text(
            name,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),

          // Email
          Text(
            email,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 32),

          // Profile Info Cards
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.person, color: Colors.blue),
                  title: Text('Nama Lengkap'),
                  subtitle: Text(name),
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.email, color: Colors.blue),
                  title: Text('Email'),
                  subtitle: Text(email),
                ),
                if (createdAt.isNotEmpty) ...[
                  Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.calendar_today, color: Colors.blue),
                    title: Text('Bergabung Sejak'),
                    subtitle: Text(createdAt.split('T')[0]),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(height: 16),

          // About Section
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.info_outline, color: Colors.blue),
                  title: Text('Tentang Aplikasi'),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: 'TookShot',
                      applicationVersion: '1.0.0',
                      applicationIcon: Icon(Icons.camera_alt, size: 48, color: Colors.blue),
                      children: [
                        SizedBox(height: 16),
                        Text('TookShot adalah aplikasi peminjaman kamera online yang memudahkan Anda untuk menyewa berbagai jenis kamera sesuai kebutuhan.'),
                        SizedBox(height: 8),
                        Text('© 2026 TookShot. All rights reserved.'),
                      ],
                    );
                  },
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.help_outline, color: Colors.blue),
                  title: Text('Bantuan'),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Bantuan'),
                        content: Text(
                          'Untuk bantuan, silakan hubungi:\n\n'
                          'Email: support@tookshot.com\n'
                          'WhatsApp: +62 812-3456-7890',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('OK'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: 32),

          // Logout Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton.icon(
              onPressed: _logout,
              icon: Icon(Icons.logout, color: Colors.red),
              label: Text(
                'Logout',
                style: TextStyle(color: Colors.red, fontSize: 16),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.red),
              ),
            ),
          ),
          SizedBox(height: 40),
        ],
      ),
    );
  }
}