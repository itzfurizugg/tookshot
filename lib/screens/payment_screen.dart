// lib/screens/payment_screen.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class PaymentScreen extends StatefulWidget {
  final int rentalId;
  final double totalPrice;
  final String cameraName;

  PaymentScreen({
    required this.rentalId,
    required this.totalPrice,
    required this.cameraName,
  });

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final ApiService _apiService = ApiService();
  String _selectedPayment = 'cash'; // cash atau qris
  bool _isLoading = false;
  bool _showQRIS = false;

  Future<void> _processPayment() async {
    if (_selectedPayment == 'qris') {
      setState(() => _showQRIS = true);
      return;
    }

    // Untuk cash, langsung confirm
    _confirmPayment();
  }

  Future<void> _confirmPayment() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiService.payRental(widget.rentalId, _selectedPayment); // ✅ tambah parameter
      setState(() => _isLoading = false);

      if (response['message'] != null && 
          (response['message'].toString().contains('success') || 
          response['message'].toString().contains('berhasil'))) {
        _showSuccessDialog();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Pembayaran gagal')),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 30),
              SizedBox(width: 10),
              Text('Pembayaran Berhasil'),
            ],
          ),
          content: Text(
            'Pembayaran Anda telah dikonfirmasi. Silakan tunggu approval dari admin.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Close payment screen
                Navigator.of(context).pop(); // Close detail screen
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pembayaran'),
      ),
      body: _showQRIS ? _buildQRISView() : _buildPaymentSelection(),
    );
  }

  Widget _buildPaymentSelection() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order Summary
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ringkasan Pesanan',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Kamera:'),
                            Expanded(
                              child: Text(
                                widget.cameraName,
                                textAlign: TextAlign.right,
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Rental ID:'),
                            Text(
                              '#${widget.rentalId}',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                        Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total Pembayaran:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Rp ${widget.totalPrice.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24),

                // Payment Methods
                Text(
                  'Pilih Metode Pembayaran',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12),

                // Cash Option
                Card(
                  child: RadioListTile<String>(
                    value: 'cash',
                    groupValue: _selectedPayment,
                    onChanged: (value) {
                      setState(() => _selectedPayment = value!);
                    },
                    title: Row(
                      children: [
                        Icon(Icons.money, color: Colors.green),
                        SizedBox(width: 12),
                        Text('Cash (Bayar di Tempat)'),
                      ],
                    ),
                    subtitle: Padding(
                      padding: EdgeInsets.only(left: 36, top: 4),
                      child: Text(
                        'Bayar langsung saat pengambilan kamera',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 8),

                // QRIS Option
                Card(
                  child: RadioListTile<String>(
                    value: 'qris',
                    groupValue: _selectedPayment,
                    onChanged: (value) {
                      setState(() => _selectedPayment = value!);
                    },
                    title: Row(
                      children: [
                        Icon(Icons.qr_code, color: Colors.blue),
                        SizedBox(width: 12),
                        Text('QRIS'),
                      ],
                    ),
                    subtitle: Padding(
                      padding: EdgeInsets.only(left: 36, top: 4),
                      child: Text(
                        'Bayar menggunakan QRIS (GoPay, OVO, Dana, dll)',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Bottom Button
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _processPayment,
              child: _isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text(
                      _selectedPayment == 'cash' ? 'Konfirmasi Pembayaran' : 'Lanjut ke QRIS',
                      style: TextStyle(fontSize: 16),
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQRISView() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          'Scan QRIS untuk Pembayaran',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Total: Rp ${widget.totalPrice.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24),

                // QR Code Image
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Ganti dengan URL QR code dari backend/static
                      Container(
                        width: 350,
                        height: 350,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Image.network(
                          'https://almerpro.com/images/qris.jpeg', // URL QR dari backend
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            // Fallback jika gambar tidak ada
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.qr_code, size: 100, color: Colors.grey),
                                  SizedBox(height: 8),
                                  Text('QR Code'),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Scan menggunakan aplikasi e-wallet Anda',
                        style: TextStyle(color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24),

                // Instructions
                Card(
                  color: Colors.blue[50],
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.blue),
                            SizedBox(width: 8),
                            Text(
                              'Cara Pembayaran',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        _buildInstruction('1', 'Buka aplikasi e-wallet (GoPay, OVO, Dana, dll)'),
                        _buildInstruction('2', 'Pilih menu Scan QR / Bayar'),
                        _buildInstruction('3', 'Scan QR Code di atas'),
                        _buildInstruction('4', 'Konfirmasi pembayaran'),
                        _buildInstruction('5', 'Klik tombol "Saya Sudah Bayar" di bawah'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Bottom Buttons
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _confirmPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'Saya Sudah Bayar',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                ),
              ),
              SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: _isLoading ? null : () {
                    setState(() => _showQRIS = false);
                  },
                  child: Text('Ganti Metode Pembayaran'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInstruction(String number, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}