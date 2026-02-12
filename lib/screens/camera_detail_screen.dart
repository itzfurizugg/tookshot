// lib/screens/camera_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tookshot/utils/formatter.dart';
import '../models/camera.dart';
import '../services/api_service.dart';
import 'payment_screen.dart';

class CameraDetailScreen extends StatefulWidget {
  final Camera camera;

  CameraDetailScreen({required this.camera});

  @override
  _CameraDetailScreenState createState() => _CameraDetailScreenState();
}

class _CameraDetailScreenState extends State<CameraDetailScreen> {
  final ApiService _apiService = ApiService();
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isLoading = false;

  // ✅ Helper formatter rupiah
  String _formatRupiah(double amount) {
    return NumberFormat('#,###', 'id_ID').format(amount);
  }

  int get _rentalDays {
    if (_startDate == null || _endDate == null) return 0;
    return _endDate!.difference(_startDate!).inDays + 1;
  }

  double get _totalPrice {
    return _rentalDays * widget.camera.pricePerDay;
  }

  bool get _canRent {
    return widget.camera.isAvailable && 
           _startDate != null && 
           _endDate != null && 
           !_isLoading;
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate 
          ? DateTime.now() 
          : (_startDate ?? DateTime.now()),
      firstDate: isStartDate 
          ? DateTime.now() 
          : (_startDate ?? DateTime.now()),
      lastDate: DateTime.now().add(Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xFF55829E),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = null;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _rentCamera() async {
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pilih tanggal mulai dan selesai terlebih dahulu'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_endDate!.isBefore(_startDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tanggal selesai harus setelah tanggal mulai'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await _apiService.createRental(
        widget.camera.id,
        _startDate!.toIso8601String().split('T')[0],
        _endDate!.toIso8601String().split('T')[0],
      );

      setState(() => _isLoading = false);

      if (response['id'] != null || response['rental'] != null) {
        final rentalId = response['id'] ?? response['rental']['id'];
        
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentScreen(
              rentalId: rentalId,
              totalPrice: _totalPrice,
              cameraName: widget.camera.name,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Gagal membuat rental')),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF55829E);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Kamera'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Container(
              width: double.infinity,
              height: 250,
              color: Colors.grey[300],
              child: widget.camera.imageUrl != null
                  ? Image.network(
                      widget.camera.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(Icons.camera_alt, size: 80),
                    )
                  : Icon(Icons.camera_alt, size: 80),
            ),

            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  Text(
                    widget.camera.name,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),

                  // Price ✅ pakai _formatRupiah
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        SizedBox(width: 8),
                        Text(
                          '${formatRupiah(widget.camera.pricePerDay)} / hari',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),

                  // Description
                  Text(
                    'Deskripsi',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    widget.camera.description,
                    style: TextStyle(fontSize: 14, height: 1.5),
                  ),
                  SizedBox(height: 24),

                  // Date Selection
                  Text(
                    'Pilih Tanggal Sewa',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),

                  // Start Date
                  InkWell(
                    onTap: () => _selectDate(context, true),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _startDate == null ? Colors.red.withOpacity(0.5) : Colors.grey[300]!,
                          width: _startDate == null ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            color: _startDate == null ? Colors.red : primaryColor,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Tanggal Mulai',
                                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  _startDate == null 
                                      ? 'Pilih tanggal' 
                                      : '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: _startDate != null ? FontWeight.w500 : FontWeight.normal,
                                    color: _startDate == null ? Colors.red : Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 12),

                  // End Date
                  InkWell(
                    onTap: () => _selectDate(context, false),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _endDate == null ? Colors.red.withOpacity(0.5) : Colors.grey[300]!,
                          width: _endDate == null ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            color: _endDate == null ? Colors.red : primaryColor,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Tanggal Selesai',
                                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  _endDate == null 
                                      ? 'Pilih tanggal' 
                                      : '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: _endDate != null ? FontWeight.w500 : FontWeight.normal,
                                    color: _endDate == null ? Colors.red : Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),

                  if (_rentalDays > 0) ...[
                    SizedBox(height: 16),
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: primaryColor.withOpacity(0.3)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Durasi Sewa:'),
                              Text(
                                '$_rentalDays hari',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Divider(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total Harga:',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Rp ${_formatRupiah(_totalPrice)}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],

                  SizedBox(height: 24),

                  // Rent Button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _canRent ? _rentCamera : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        disabledBackgroundColor: Colors.grey[300],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              widget.camera.isAvailable 
                                  ? (_startDate == null || _endDate == null 
                                      ? 'Pilih Tanggal Terlebih Dahulu' 
                                      : 'Sewa Sekarang')
                                  : 'Tidak Tersedia',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  
                  SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}