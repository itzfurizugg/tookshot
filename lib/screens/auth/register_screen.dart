// lib/screens/auth/register_screen.dart
import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  Future<void> _register() async {
    // Validasi form
    if (!_formKey.currentState!.validate()) return;

    // Cek password match
    if (_passwordController.text != _confirmPasswordController.text) {
      _showError('Password dan Konfirmasi Password tidak cocok');
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      final response = await _apiService.register(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text,
      );
      
      setState(() => _isLoading = false);
      
      print('=== REGISTER RESPONSE ===');
      print(response);
      
      // Cek jika ada error dari server
      if (response['error'] != null) {
        _showError(response['message'] ?? 'Terjadi kesalahan pada server');
        return;
      }
      
      // Cek berbagai kemungkinan response sukses dari Laravel
      bool isSuccess = false;
      
      if (response['user'] != null) {
        isSuccess = true;
      } else if (response['data']?['user'] != null) {
        isSuccess = true;
      } else if (response['success'] == true) {
        isSuccess = true;
      } else if (response['token'] != null) {
        isSuccess = true;
      } else if (response['message'] != null) {
        String message = response['message'].toString().toLowerCase();
        if (message.contains('success') || 
            message.contains('berhasil') || 
            message.contains('created') ||
            message.contains('registered')) {
          isSuccess = true;
        }
      }
      
      if (isSuccess) {
        _showSuccess('Pendaftaran berhasil! Silakan login.');
        
        // Tunggu sebentar biar user baca message
        await Future.delayed(Duration(seconds: 2));
        
        // Kembali ke login screen
        if (mounted) {
          Navigator.pop(context);
        }
      } else {
        // Gagal tapi tidak ada pesan error spesifik
        String errorMessage = 'Pendaftaran gagal. Silakan coba lagi.';
        
        if (response['message'] != null) {
          errorMessage = response['message'].toString();
        } else if (response['errors'] != null) {
          // Handle validation errors dari Laravel
          Map<String, dynamic> errors = response['errors'];
          errorMessage = errors.values.first[0].toString();
        }
        
        _showError(errorMessage);
      }
      
    } catch (e) {
      setState(() => _isLoading = false);
      
      print('=== REGISTER ERROR ===');
      print(e.toString());
      
      String errorMessage = 'Terjadi kesalahan: ';
      
      if (e.toString().contains('SocketException')) {
        errorMessage += 'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.';
      } else if (e.toString().contains('FormatException')) {
        errorMessage += 'Response server tidak valid. Periksa URL API Anda.';
      } else if (e.toString().contains('TimeoutException')) {
        errorMessage += 'Koneksi timeout. Coba lagi.';
      } else {
        errorMessage += e.toString();
      }
      
      _showError(errorMessage);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 20),
                
                // Title
                Text(
                  'Daftar Akun',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Buat akun baru untuk memulai',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 32),

                // Name Field
                TextFormField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  enabled: !_isLoading,
                  decoration: InputDecoration(
                    labelText: 'Nama Lengkap',
                    hintText: 'Masukkan nama lengkap Anda',
                    prefixIcon: Icon(Icons.person_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Color(0xFF55829E), width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nama lengkap tidak boleh kosong';
                    }
                    if (value.trim().length < 3) {
                      return 'Nama minimal 3 karakter';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                // Email Field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  enabled: !_isLoading,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    hintText: 'Masukkan email Anda',
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Color(0xFF55829E), width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email tidak boleh kosong';
                    }
                    value = value.trim();
                    if (!value.contains('@')) {
                      return 'Email tidak valid';
                    }
                    if (!RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$').hasMatch(value)) {
                      return 'Format email tidak valid';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                
                // Password Field
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  enabled: !_isLoading,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Minimal 6 karakter',
                    prefixIcon: Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword 
                          ? Icons.visibility_outlined 
                          : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Color(0xFF55829E), width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password tidak boleh kosong';
                    }
                    if (value.length < 6) {
                      return 'Password minimal 6 karakter';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                
                // Confirm Password Field
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  enabled: !_isLoading,
                  decoration: InputDecoration(
                    labelText: 'Konfirmasi Password',
                    hintText: 'Masukkan ulang password',
                    prefixIcon: Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword 
                          ? Icons.visibility_outlined 
                          : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Color(0xFF55829E), width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Konfirmasi password tidak boleh kosong';
                    }
                    if (value != _passwordController.text) {
                      return 'Password tidak cocok';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 24),
                
                // Register Button
                SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF55829E),
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
                            'Daftar',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                SizedBox(height: 24),
                
                // Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Sudah punya akun? ',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    GestureDetector(
                      onTap: _isLoading ? null : () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Masuk',
                        style: TextStyle(
                          fontSize: 14,
                          color: _isLoading ? Colors.grey : Color(0xFF55829E),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}