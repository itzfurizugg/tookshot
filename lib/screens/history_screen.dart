// lib/screens/history_screen.dart
import 'package:flutter/material.dart';
import 'package:tookshot/utils/formatter.dart';
import '../services/api_service.dart';
import '../models/rental.dart';

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final ApiService _apiService = ApiService();
  List<Rental> _rentals = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    
    try {
      // Note: API endpoint mungkin perlu disesuaikan
      // Endpoint /api/rentals/{camera} seharusnya untuk user melihat semua rentalnya
      // Jika API Laravel perlu diubah, bisa jadi /api/my/rentals
      
      // Untuk sementara, kita ambil dari endpoint yang ada
      // Pastikan endpoint ini return semua rental user yang login
      final response = await _apiService.getUserRentals(); // 0 = all cameras
      
      setState(() {
        _rentals = response.map((json) => Rental.fromJson(json)).toList();
        _rentals.sort((a, b) => b.id.compareTo(a.id)); // Sort by newest
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat histori: $e')),
      );
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.blue;
      case 'paid':
        return Colors.green;
      case 'returned':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Menunggu Approval';
      case 'approved':
        return 'Disetujui';
      case 'paid':
        return 'Sudah Dibayar';
      case 'returned':
        return 'Selesai';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_rentals.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Belum ada histori peminjaman',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadHistory,
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: _rentals.length,
        itemBuilder: (context, index) {
          final rental = _rentals[index];
          return Card(
            margin: EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'ID: #${rental.id}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[600],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusColor(rental.status),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _getStatusText(rental.status),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),

                  // Camera Name
                  Text(
                    rental.cameraName,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),

                  // Dates
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                      SizedBox(width: 8),
                      Text(
                        '${rental.startDate} s/d ${rental.endDate}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),

                  // Payment Status
                  Row(
                    children: [
                      Icon(
                        rental.isPaid ? Icons.check_circle : Icons.pending,
                        size: 16,
                        color: rental.isPaid ? Colors.green : Colors.orange,
                      ),
                      SizedBox(width: 8),
                      Text(
                        rental.isPaid ? 'Sudah Dibayar' : 'Belum Dibayar',
                        style: TextStyle(
                          color: rental.isPaid ? Colors.green : Colors.orange,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  
                  Divider(height: 24),

                  // Total Price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Pembayaran:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${formatRupiah(rental.totalPrice)}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}