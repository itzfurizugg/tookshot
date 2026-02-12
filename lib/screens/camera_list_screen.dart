// lib/screens/camera_list_screen.dart
import 'package:flutter/material.dart';
import 'package:tookshot/utils/formatter.dart';
import '../services/api_service.dart';
import '../models/camera.dart';
import 'camera_detail_screen.dart';

class CameraListScreen extends StatefulWidget {
  final String? searchQuery;
  final String? selectedCategory;

  const CameraListScreen({
    Key? key,
    this.searchQuery,
    this.selectedCategory,
  }) : super(key: key);

  @override
  _CameraListScreenState createState() => _CameraListScreenState();
}

class _CameraListScreenState extends State<CameraListScreen> {
  final ApiService _apiService = ApiService();
  List<Camera> _cameras = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCameras();
  }

  @override
  void didUpdateWidget(CameraListScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Rebuild when search or category changes
    if (oldWidget.searchQuery != widget.searchQuery ||
        oldWidget.selectedCategory != widget.selectedCategory) {
      setState(() {});
    }
  }

  Future<void> _loadCameras() async {
    try {
      final response = await _apiService.getAllCameras();
      setState(() {
        _cameras = response.map((json) => Camera.fromJson(json)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat data: $e')),
      );
    }
  }

  List<Camera> _getFilteredCameras() {
    List<Camera> filtered = _cameras;

    // Filter by search query (search by name and brand)
    if (widget.searchQuery != null && widget.searchQuery!.isNotEmpty) {
      filtered = filtered.where((camera) {
        final searchLower = widget.searchQuery!.toLowerCase();
        return camera.name.toLowerCase().contains(searchLower) ||
               camera.brand.toLowerCase().contains(searchLower);
      }).toList();
    }

    // Filter by category (if your Camera model has category field)
    // Uncomment if you have category field
    // if (widget.selectedCategory != null && widget.selectedCategory != 'Semua') {
    //   filtered = filtered.where((camera) {
    //     return camera.category?.toLowerCase() == widget.selectedCategory!.toLowerCase();
    //   }).toList();
    // }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF55829E);

    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: primaryColor,
        ),
      );
    }

    final filteredCameras = _getFilteredCameras();

    if (filteredCameras.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.camera_alt_outlined, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              widget.searchQuery?.isNotEmpty == true 
                  ? 'Kamera tidak ditemukan' 
                  : 'Belum ada kamera tersedia',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadCameras,
      color: primaryColor,
      child: GridView.builder(
        padding: EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.7,
        ),
        itemCount: filteredCameras.length,
        itemBuilder: (context, index) {
          final camera = filteredCameras[index];
          return _buildCameraCard(camera, primaryColor);
        },
      ),
    );
  }

  Widget _buildCameraCard(Camera camera, Color primaryColor) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CameraDetailScreen(camera: camera),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: camera.imageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                        child: Image.network(
                          camera.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Center(
                            child: Icon(
                              Icons.camera_alt,
                              size: 50,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      )
                    : Center(
                        child: Icon(
                          Icons.camera_alt,
                          size: 50,
                          color: Colors.grey,
                        ),
                      ),
              ),
            ),
            
            // Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Name and Brand
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          camera.name,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 2),
                      ],
                    ),
                    
                    // Price and Status
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '${formatRupiah(camera.pricePerDay)}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF55829E),
                              ),
                            ),
                            Text(
                              ' /hari',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 6),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: camera.isAvailable ? Colors.green : Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            camera.isAvailable ? 'Tersedia' : 'Habis',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
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