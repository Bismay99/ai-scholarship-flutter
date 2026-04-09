import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/document_provider.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;

class DocumentVaultScreen extends StatelessWidget {
  const DocumentVaultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final docProvider = Provider.of<DocumentProvider>(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Get all completed/verified documents
    final verifiedDocs = docProvider.sections.values
        .expand((section) => section)
        .where((f) => f.status == FieldStatus.completed && f.value != null && f.value!.isNotEmpty)
        .toList();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('My Document Vault', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("All documents are securely encrypted and stored.")),
              );
            },
          ),
        ],
      ),
      body: verifiedDocs.isEmpty
          ? _buildEmptyState(colorScheme)
          : GridView.builder(
              padding: const EdgeInsets.all(20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.85,
              ),
              itemCount: verifiedDocs.length,
              itemBuilder: (context, index) {
                final doc = verifiedDocs[index];
                return _buildDocCard(context, doc, colorScheme, theme)
                    .animate()
                    .fadeIn(delay: (index * 100).ms)
                    .scale(begin: const Offset(0.9, 0.9));
              },
            ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_off_outlined, size: 80, color: colorScheme.primary.withOpacity(0.3)),
          const SizedBox(height: 20),
          const Text(
            "Your vault is empty",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 10),
          const Text(
            "Go to 'Verified Documents' to upload\nand secure your identity proof.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white54),
          ),
        ],
      ),
    );
  }

  Widget _buildDocCard(BuildContext context, VerificationField doc, ColorScheme colorScheme, ThemeData theme) {
    final String docPath = doc.value ?? "";
    final bool isNetworkUrl = docPath.startsWith('http');
    bool isPdf = docPath.toLowerCase().contains('.pdf');

    return GestureDetector(
      onTap: () => _viewDocument(context, doc),
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colorScheme.primary.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Preview Area
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.05),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: isPdf
                      ? Center(child: Icon(Icons.picture_as_pdf, size: 50, color: Colors.redAccent.withOpacity(0.8)))
                      : isNetworkUrl
                          ? Image.network(
                              docPath,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Center(child: Icon(Icons.description, size: 40, color: colorScheme.primary.withOpacity(0.5))),
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(child: CircularProgressIndicator(value: loadingProgress.expectedTotalBytes != null ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes! : null));
                              },
                            )
                          : File(docPath).existsSync()
                              ? Image.file(
                                  File(docPath),
                                  fit: BoxFit.cover,
                                )
                              : Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.shield_rounded, size: 40, color: colorScheme.primary.withOpacity(0.7)),
                                      const SizedBox(height: 8),
                                      const Text("Secure Asset", style: TextStyle(color: Colors.white54, fontSize: 10)),
                                    ],
                                  ),
                                ),
                ),
              ),
            ),
            // Info Area
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doc.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.verified, size: 12, color: Colors.green),
                      const SizedBox(width: 4),
                      Text(
                        "Verified",
                        style: TextStyle(fontSize: 10, color: Colors.green.withOpacity(0.8), fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _viewDocument(BuildContext context, VerificationField doc) {
    final colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            Container(
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: doc.value!.toLowerCase().contains('.pdf')
                    ? _buildPdfPlaceholder(doc.title)
                    : doc.value!.startsWith('http')
                        ? Image.network(
                            doc.value!,
                            fit: BoxFit.contain,
                          )
                        : File(doc.value!).existsSync()
                            ? Image.file(
                                File(doc.value!),
                                fit: BoxFit.contain,
                              )
                            : _buildLocalPlaceholder(context, doc),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _downloadDocument(context, doc),
                icon: const Icon(Icons.file_download_outlined, color: Colors.white),
                label: const Text(
                  "DOWNLOAD / SAVE TO DEVICE",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.1),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 8,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _downloadDocument(BuildContext context, VerificationField doc) async {
    final String docPath = doc.value ?? "";
    if (docPath.isEmpty) return;

    try {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Preparing for download...")));
      
      String finalPath = docPath;
      
      // If it's a network URL, download it first to a temporary file
      if (docPath.startsWith('http')) {
        final response = await http.get(Uri.parse(docPath));
        final bytes = response.bodyBytes;
        final tempDir = await getTemporaryDirectory();
        final fileName = p.basename(docPath).contains('?') 
            ? '${doc.id}_${DateTime.now().millisecondsSinceEpoch}.jpg' 
            : p.basename(docPath);
        final tempFile = File('${tempDir.path}/$fileName');
        await tempFile.writeAsBytes(bytes);
        finalPath = tempFile.path;
      }
      
      if (await File(finalPath).exists()) {
        await Share.shareXFiles([XFile(finalPath)], text: 'Verified ${doc.title}');
      } else {
        throw "File not found locally";
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Download error: $e"), backgroundColor: Colors.red));
    }
  }

  Widget _buildPdfPlaceholder(String title) {
    return Container(
      padding: const EdgeInsets.all(40),
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.picture_as_pdf, color: Colors.red, size: 80),
          const SizedBox(height: 20),
          const Text("PDF Preview Not Available In-App", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }

  Widget _buildLocalPlaceholder(BuildContext context, VerificationField doc) {
    final title = doc.title;
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shield_rounded, color: Theme.of(context).colorScheme.primary, size: 80),
          const SizedBox(height: 20),
          const Text(
            "Secure Verification Asset",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            "This document ($title) was verified locally but its image is missing or was saved in a previous version.",
            style: const TextStyle(color: Colors.white70, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
            ),
            child: const Text(
              "ACTION REQUIRED: Please RE-UPLOAD this document to enable permanent local storage.",
              style: TextStyle(color: Colors.orangeAccent, fontSize: 11, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Internal Path: ${doc.value}",
            style: const TextStyle(color: Colors.white24, fontSize: 9, fontStyle: FontStyle.italic),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          const CircularProgressIndicator(),
        ],
      ),
    );
  }
}
