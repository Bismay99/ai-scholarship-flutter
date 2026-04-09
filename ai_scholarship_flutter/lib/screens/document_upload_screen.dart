import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:async';

class DocumentUploadScreen extends StatefulWidget {
  const DocumentUploadScreen({super.key});

  @override
  State<DocumentUploadScreen> createState() => _DocumentUploadScreenState();
}

class _DocumentUploadScreenState extends State<DocumentUploadScreen> {
  bool _isUploading = false;
  bool _isProcessing = false;
  bool _isVerified = false;
  
  Map<String, String>? _extractedData;

  void _simulateUpload() {
    setState(() => _isUploading = true);
    
    // Simulate image upload network/disk delay
    Timer(const Duration(seconds: 2), () {
      setState(() {
        _isUploading = false;
        _isProcessing = true;
      });
      _simulateOCR();
    });
  }

  void _simulateOCR() {
    // Simulate AI OCR model extracting text
    Timer(const Duration(seconds: 3), () {
      setState(() {
        _isProcessing = false;
        _isVerified = true;
        _extractedData = {
          "Name": "Alex Johnson",
          "Income": "\$45,000 / year",
          "ID Number": "STU-992-881",
        };
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Document Verification', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Upload Proof of Income",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.5),
            ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0),
            const SizedBox(height: 10),
            const Text(
              "Our AI will securely extract and verify your details instantly without manual review.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Colors.white54, height: 1.5),
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),
            const SizedBox(height: 40),

            // Upload Box / Preview Area
            GestureDetector(
              onTap: (!_isUploading && !_isProcessing && !_isVerified) ? _simulateUpload : null,
              child: Container(
                width: double.infinity,
                height: 250,
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: _isVerified ? const Color(0xFF22D3EE) : const Color(0xFF1E3A8A),
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 5))
                  ]
                ),
                child: Center(
                  child: _buildPreviewContent(),
                ),
              ),
            ).animate().fadeIn(delay: 300.ms).scale(begin: const Offset(0.95, 0.95)),
            const SizedBox(height: 40),

            // OCR Extraction Results
            AnimatedOpacity(
              opacity: _isVerified ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 500),
              child: _isVerified ? _buildExtractedDataCard() : const SizedBox(height: 200),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewContent() {
    if (_isUploading) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          CircularProgressIndicator(color: Color(0xFF7C3AED)),
          SizedBox(height: 20),
          Text("Uploading encrypted file...", style: TextStyle(color: Colors.white70)),
        ],
      );
    } else if (_isProcessing) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          CircularProgressIndicator(color: Color(0xFF22D3EE)),
          SizedBox(height: 20),
          Text("Running OCR Extraction Map...", style: TextStyle(color: Color(0xFF22D3EE))),
        ],
      );
    } else if (_isVerified) {
      return Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Image.network(
              'https://images.unsplash.com/photo-1618044733300-9472054094ee?q=80&w=600&auto=format&fit=crop', // Mock blurred tax doc
              fit: BoxFit.cover,
              color: Colors.black.withOpacity(0.6),
              colorBlendMode: BlendMode.darken,
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.verified, color: Color(0xFF22D3EE), size: 60),
                SizedBox(height: 10),
                Text("Document Verified ✅", style: TextStyle(color: Color(0xFF22D3EE), fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          )
        ],
      );
    }

    // Default State
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.cloud_upload_outlined, size: 60, color: const Color(0xFF7C3AED).withOpacity(0.8)),
        const SizedBox(height: 15),
        const Text("Tap to select image (JPEG/PNG)", style: TextStyle(color: Colors.white, fontSize: 16)),
        const SizedBox(height: 8),
        const Text("Simulate Upload", style: TextStyle(color: Colors.white54, fontSize: 13)),
      ],
    );
  }

  Widget _buildExtractedDataCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF1E3A8A).withOpacity(0.5)),
        boxShadow: [
          BoxShadow(color: const Color(0xFF22D3EE).withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 5))
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Extracted Information",
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          if (_extractedData != null)
            ..._extractedData!.entries.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Icons.document_scanner_outlined, color: Color(0xFF22D3EE), size: 20),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(e.key, style: const TextStyle(color: Colors.white54, fontSize: 13)),
                        const SizedBox(height: 4),
                        Text(e.value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
              ),
            )),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF7C3AED), Color(0xFF1E3A8A)]),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Confirm & Continue", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          )
        ],
      ),
    );
  }
}
