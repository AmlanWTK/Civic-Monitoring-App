import 'package:civic_app_4/models/models.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../services/sms_service.dart';

class ComplaintsScreen extends StatefulWidget {
  @override
  _ComplaintsScreenState createState() => _ComplaintsScreenState();
}

class _ComplaintsScreenState extends State<ComplaintsScreen> {
  final SMSService _smsService = SMSService();
  
  List<Complaint> _complaints = [];
  List<Complaint> _filteredComplaints = [];
  bool _loading = false;
  String? _error;
  String _searchQuery = '';
  String _selectedCategory = 'All';
  String _selectedPriority = 'All';

  final List<String> _categories = [
    'All', 'NETWORK_OUTAGE', 'SLOW_INTERNET', 'BILLING_ISSUE', 
    'TECHNICAL_SUPPORT', 'SERVICE_INTERRUPTION', 'OTHER'
  ];

  final List<String> _priorities = ['All', 'HIGH', 'MEDIUM', 'LOW'];

  @override
  void initState() {
    super.initState();
    _loadComplaints();
  }

  Future<void> _loadComplaints() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // Load both real and sample complaints
      await Future.wait([
        _loadSampleComplaints(),
        _loadRealComplaints(),
      ]);
      
      _filterComplaints();
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _loadSampleComplaints() async {
    // Sample complaints for demonstration
    final sampleComplaints = [
      Complaint(
        id: 'SMS001',
        phoneNumber: '+8801712345678',
        message: 'আমার ইন্টারনেট স্পিড খুবই কম। দয়া করে দেখুন।',
        originalText: 'আমার ইন্টারনেট স্পিড খুবই কম। দয়া করে দেখুন।',
        translatedText: 'My internet speed is very slow. Please check.',
        category: 'SLOW_INTERNET',
        priority: 'MEDIUM',
        sentiment: 'NEGATIVE',
        confidence: 0.89,
        timestamp: DateTime.now().subtract(Duration(minutes: 15)),
        status: 'PENDING',
        location: 'Dhaka, Bangladesh',
      ),
      Complaint(
        id: 'SMS002',
        phoneNumber: '+8801987654321',
        message: 'Network down in Chittagong area since morning',
        originalText: 'Network down in Chittagong area since morning',
        translatedText: 'Network down in Chittagong area since morning',
        category: 'NETWORK_OUTAGE',
        priority: 'HIGH',
        sentiment: 'NEGATIVE',
        confidence: 0.95,
        timestamp: DateTime.now().subtract(Duration(hours: 2)),
        status: 'IN_PROGRESS',
        location: 'Chittagong, Bangladesh',
      ),
      Complaint(
        id: 'SMS003',
        phoneNumber: '+8801555666777',
        message: 'Bill amount is wrong this month. Please correct it.',
        originalText: 'Bill amount is wrong this month. Please correct it.',
        translatedText: 'Bill amount is wrong this month. Please correct it.',
        category: 'BILLING_ISSUE',
        priority: 'MEDIUM',
        sentiment: 'NEUTRAL',
        confidence: 0.76,
        timestamp: DateTime.now().subtract(Duration(hours: 5)),
        status: 'RESOLVED',
        location: 'Sylhet, Bangladesh',
      ),
      Complaint(
        id: 'SMS004',
        phoneNumber: '+8801777888999',
        message: 'টাওয়ারে সমস্যা হচ্ছে। সিগন্যাল পাচ্ছি না।',
        originalText: 'টাওয়ারে সমস্যা হচ্ছে। সিগন্যাল পাচ্ছি না।',
        translatedText: 'Tower is having problems. Not getting signal.',
        category: 'TECHNICAL_SUPPORT',
        priority: 'HIGH',
        sentiment: 'NEGATIVE',
        confidence: 0.92,
        timestamp: DateTime.now().subtract(Duration(minutes: 30)),
        status: 'PENDING',
        location: 'Khulna, Bangladesh',
      ),
    ];

    setState(() {
      _complaints.addAll(sampleComplaints);
    });
  }

  Future<void> _loadRealComplaints() async {
    // In a real implementation, this would connect to SMS APIs or databases
    // For now, we'll simulate processing some additional complaints
    
    try {
      // Simulate API delay
      await Future.delayed(Duration(milliseconds: 500));
      
      // This is where you'd integrate with:
      // - Twilio SMS API for incoming messages
      // - Local SMS processing service
      // - OpenAI/Hugging Face API for text classification
      // - Google Translate API for translation
      
      print('Real SMS complaint processing would happen here');
    } catch (e) {
      print('Error loading real complaints: $e');
    }
  }

  void _filterComplaints() {
    setState(() {
      _filteredComplaints = _complaints.where((complaint) {
        bool matchesSearch = _searchQuery.isEmpty ||
            complaint.message.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            complaint.translatedText.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            complaint.phoneNumber.contains(_searchQuery);
            
        bool matchesCategory = _selectedCategory == 'All' || 
            complaint.category == _selectedCategory;
            
        bool matchesPriority = _selectedPriority == 'All' || 
            complaint.priority == _selectedPriority;

        return matchesSearch && matchesCategory && matchesPriority;
      }).toList();

      // Sort by priority and timestamp
      _filteredComplaints.sort((a, b) {
        int priorityCompare = _getPriorityOrder(b.priority).compareTo(_getPriorityOrder(a.priority));
        if (priorityCompare != 0) return priorityCompare;
        return b.timestamp.compareTo(a.timestamp);
      });
    });
  }

  int _getPriorityOrder(String priority) {
    switch (priority) {
      case 'HIGH': return 3;
      case 'MEDIUM': return 2;
      case 'LOW': return 1;
      default: return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        scaffoldBackgroundColor: Colors.grey[50],
        cardColor: Colors.white,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 1,
          shadowColor: Colors.grey[300],
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          shadowColor: Colors.grey[300],
          elevation: 2,
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: Colors.white,
        ),
      ),
      child: Container(
        color: Colors.grey[50],
        child: Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
            elevation: 1,
            shadowColor: Colors.grey[300],
            title: Text('SMS Complaints', style: GoogleFonts.playfairDisplay(color: Colors.black87,fontWeight: FontWeight.bold)),
            actions: [
              IconButton(
                icon: Icon(Icons.refresh, color: Colors.black87),
                onPressed: _loadComplaints,
              ),
              IconButton(
                icon: Icon(Icons.filter_list, color: Colors.black87),
                onPressed: _showFilterDialog,
              ),
            ],
          ),
          body: _loading
              ? Center(child: CircularProgressIndicator())
              : _error != null
                  ? _buildErrorWidget()
                  : _buildComplaintsView(),
          floatingActionButton: FloatingActionButton(
            onPressed: _showAddComplaintDialog,
            child: Icon(Icons.add),
            tooltip: 'Add Test Complaint',
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      color: Colors.grey[50],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text('Error: $_error', style: TextStyle(color: Colors.black87)),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadComplaints,
              child: Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComplaintsView() {
    return Container(
      color: Colors.grey[50],
      child: Column(
        children: [
          _buildSearchAndStats(),
          Expanded(
            child: _filteredComplaints.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: _filteredComplaints.length,
                    itemBuilder: (context, index) {
                      return _buildComplaintCard(_filteredComplaints[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndStats() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // Search bar
          TextField(
            decoration: InputDecoration(
              hintText: 'Search complaints...',
              hintStyle: GoogleFonts.roboto(color: Colors.grey[600]),
              prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.blue[600]!),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            style: TextStyle(color: Colors.black87),
            onChanged: (value) {
              _searchQuery = value;
              _filterComplaints();
            },
          ),
          SizedBox(height: 16),
          // Stats row
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total',
                  '${_complaints.length}',
                  Colors.blue,
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  'Pending',
                  '${_complaints.where((c) => c.status == 'PENDING').length}',
                  Colors.orange,
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  'High Priority',
                  '${_complaints.where((c) => c.priority == 'HIGH').length}',
                  Colors.red,
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  'Resolved',
                  '${_complaints.where((c) => c.status == 'RESOLVED').length}',
                  Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      color: Colors.grey[50],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.message_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No complaints found',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.black87),
            ),
            Text(
              'Complaints will appear here when received via SMS',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComplaintCard(Complaint complaint) {
    return Card(
      color: Colors.white,
      shadowColor: Colors.grey[300],
      elevation: 2,
      margin: EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showComplaintDetails(complaint),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _getCategoryIcon(complaint.category),
                    color: _getPriorityColor(complaint.priority),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          complaint.id,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          complaint.phoneNumber,
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusChip(complaint.status),
                  SizedBox(width: 8),
                  _buildPriorityChip(complaint.priority),
                ],
              ),
              SizedBox(height: 12),
              Text(
                complaint.translatedText,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.black87),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (complaint.originalText != complaint.translatedText) ...[
                SizedBox(height: 8),
                Text(
                  'Original: ${complaint.originalText}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                  SizedBox(width: 4),
                  Text(
                    complaint.location,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  Spacer(),
                  Text(
                    _formatTimestamp(complaint.timestamp),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status) {
      case 'PENDING':
        color = Colors.orange;
        break;
      case 'IN_PROGRESS':
        color = Colors.blue;
        break;
      case 'RESOLVED':
        color = Colors.green;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildPriorityChip(String priority) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getPriorityColor(priority).withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        priority,
        style: TextStyle(
          color: _getPriorityColor(priority),
          fontSize: 10,
          fontWeight: FontWeight.bold,
          
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'NETWORK_OUTAGE':
        return Icons.signal_wifi_off;
      case 'SLOW_INTERNET':
        return Icons.speed;
      case 'BILLING_ISSUE':
        return Icons.receipt;
      case 'TECHNICAL_SUPPORT':
        return Icons.build;
      case 'SERVICE_INTERRUPTION':
        return Icons.warning;
      default:
        return Icons.help;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'HIGH':
        return Colors.red;
      case 'MEDIUM':
        return Colors.orange;
      case 'LOW':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    Duration difference = DateTime.now().difference(timestamp);
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  void _showComplaintDetails(Complaint complaint) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          color: Colors.white,
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(_getCategoryIcon(complaint.category), color: Colors.black87),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Complaint ${complaint.id}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.black87),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: Colors.black87),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow('Phone Number', complaint.phoneNumber),
                      _buildDetailRow('Category', complaint.category),
                      _buildDetailRow('Priority', complaint.priority),
                      _buildDetailRow('Status', complaint.status),
                      _buildDetailRow('Location', complaint.location),
                      _buildDetailRow('Sentiment', complaint.sentiment),
                      _buildDetailRow('Confidence', '${(complaint.confidence * 100).toInt()}%'),
                      _buildDetailRow('Timestamp', complaint.timestamp.toString()),
                      SizedBox(height: 16),
                      Text('Original Message:', style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold, color: Colors.black87)),
                      SizedBox(height: 8),
                      Text(complaint.originalText, style: TextStyle(color: Colors.black87)),
                      SizedBox(height: 16),
                      Text('Translated Message:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                      SizedBox(height: 8),
                      Text(complaint.translatedText, style: TextStyle(color: Colors.black87)),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _updateComplaintStatus(complaint, 'IN_PROGRESS'),
                      child: Text('Mark In Progress'),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _updateComplaintStatus(complaint, 'RESOLVED'),
                      child: Text('Mark Resolved'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold, color: Colors.black87),
            ),
          ),
          Expanded(child: Text(value, style: TextStyle(color: Colors.black87))),
        ],
      ),
    );
  }

  void _updateComplaintStatus(Complaint complaint, String newStatus) {
    setState(() {
      complaint.status = newStatus;
    });
    Navigator.pop(context);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Complaint ${complaint.id} marked as $newStatus'),
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text('Filter Complaints', style: GoogleFonts.playfairDisplay(color: Colors.blueGrey)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: InputDecoration(
                labelText: 'Category',
                labelStyle: TextStyle(color: Colors.grey[600]),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              style: TextStyle(color: Colors.black87),
              items: _categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category.replaceAll('_', ' '), style: TextStyle(color: Colors.black87)),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                });
              },
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedPriority,
              decoration: InputDecoration(
                labelText: 'Priority',
                labelStyle: TextStyle(color: Colors.grey[600]),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              style: TextStyle(color: Colors.black87),
              items: _priorities.map((priority) {
                return DropdownMenuItem(
                  value: priority,
                  child: Text(priority, style: TextStyle(color: Colors.black87)),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedPriority = value!;
                });
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedCategory = 'All';
                _selectedPriority = 'All';
              });
              _filterComplaints();
              Navigator.pop(context);
            },
            child: Text('Clear'),
          ),
          ElevatedButton(
            onPressed: () {
              _filterComplaints();
              Navigator.pop(context);
            },
            child: Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _showAddComplaintDialog() {
    final messageController = TextEditingController();
    final phoneController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text('Add Test Complaint', style: TextStyle(color: Colors.black87)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: phoneController,
              style: TextStyle(color: Colors.black87),
              decoration: InputDecoration(
                labelText: 'Phone Number',
                labelStyle: TextStyle(color: Colors.grey[600]),
                hintText: '+8801XXXXXXXXX',
                hintStyle: TextStyle(color: Colors.grey[400]),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: messageController,
              style: TextStyle(color: Colors.black87),
              decoration: InputDecoration(
                labelText: 'Complaint Message',
                labelStyle: TextStyle(color: Colors.grey[600]),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (messageController.text.isNotEmpty && phoneController.text.isNotEmpty) {
                _addTestComplaint(phoneController.text, messageController.text);
                Navigator.pop(context);
              }
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  void _addTestComplaint(String phone, String message) {
    final complaint = Complaint(
      id: 'SMS${DateTime.now().millisecondsSinceEpoch}',
      phoneNumber: phone,
      message: message,
      originalText: message,
      translatedText: message, // In real app, would translate if needed
      category: 'OTHER', // In real app, would classify using ML
      priority: 'MEDIUM',
      sentiment: 'NEUTRAL',
      confidence: 0.75,
      timestamp: DateTime.now(),
      status: 'PENDING',
      location: 'Unknown',
    );

    setState(() {
      _complaints.insert(0, complaint);
    });
    
    _filterComplaints();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Test complaint added')),
    );
  }
}