import 'dart:io';
import 'dart:ui' as ui;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/entry_model.dart';

class PdfService {
  Future<String> _getDownloadPath() async {
    if (Platform.isAndroid) {
      // Try external storage Downloads folder first
      final downloadDir = Directory('/storage/emulated/0/Download');
      if (await downloadDir.exists()) {
        return downloadDir.path;
      }
      // Fallback to app's external storage directory
      final extDir = await getExternalStorageDirectory();
      if (extDir != null) {
        return extDir.path;
      }
      // Last fallback to app documents
      final docDir = await getApplicationDocumentsDirectory();
      return docDir.path;
    } else if (Platform.isIOS) {
      final directory = await getApplicationDocumentsDirectory();
      return directory.path;
    } else {
      // Windows/Mac/Linux
      final directory = await getDownloadsDirectory();
      return directory?.path ?? (await getApplicationDocumentsDirectory()).path;
    }
  }

  Future<pw.ImageProvider> _generateQrImage(String data) async {
    final qrPainter = QrPainter(
      data: data,
      version: QrVersions.auto,
      gapless: true,
      eyeStyle: const QrEyeStyle(
        eyeShape: QrEyeShape.square,
        color: ui.Color(0xFF1F2937),
      ),
      dataModuleStyle: const QrDataModuleStyle(
        dataModuleShape: QrDataModuleShape.square,
        color: ui.Color(0xFF1F2937),
      ),
    );

    final image = await qrPainter.toImage(200);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final bytes = byteData!.buffer.asUint8List();

    return pw.MemoryImage(bytes);
  }

  Future<String> generatePdf(EntryModel entry) async {
    // Generate QR code image
    final qrImage = await _generateQrImage(entry.toQrData());

    final pdf = pw.Document();
    final dateFormat = DateFormat('MMMM dd, yyyy • hh:mm a');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('#6366F1'),
                  borderRadius: pw.BorderRadius.circular(12),
                ),
                child: pw.Column(
                  children: [
                    pw.Text(
                      'Business Entry',
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      'Generated on ${dateFormat.format(DateTime.now())}',
                      style: const pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 30),

              // Entry Details Section
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: pw.BorderRadius.circular(12),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Entry Details',
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColor.fromHex('#1F2937'),
                      ),
                    ),
                    pw.SizedBox(height: 20),
                    _buildDetailRow('Name', entry.name),
                    pw.Divider(color: PdfColors.grey200),
                    _buildDetailRow('Address', entry.address),
                    pw.Divider(color: PdfColors.grey200),
                    _buildDetailRow('Contact Number', entry.contactNumber),
                    pw.Divider(color: PdfColors.grey200),
                    _buildDetailRow(
                        'Created Date', dateFormat.format(entry.createdAt)),
                  ],
                ),
              ),

              pw.SizedBox(height: 30),

              // QR Code Section
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('#F3F4F6'),
                  borderRadius: pw.BorderRadius.circular(12),
                ),
                child: pw.Column(
                  children: [
                    pw.Text(
                      'Scan for Audit',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColor.fromHex('#1F2937'),
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      'Scan this QR code to create an audit record',
                      style: pw.TextStyle(
                        fontSize: 11,
                        color: PdfColor.fromHex('#6B7280'),
                      ),
                    ),
                    pw.SizedBox(height: 16),
                    pw.Container(
                      padding: const pw.EdgeInsets.all(12),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.white,
                        borderRadius: pw.BorderRadius.circular(8),
                      ),
                      child: pw.Image(qrImage, width: 150, height: 150),
                    ),
                  ],
                ),
              ),

              pw.Spacer(),

              // Footer
              pw.Center(
                child: pw.Text(
                  'Entry ID: ${entry.id}',
                  style: const pw.TextStyle(
                    fontSize: 10,
                    color: PdfColors.grey500,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    // Save PDF to Downloads folder
    try {
      final downloadPath = await _getDownloadPath();
      final fileName = 'entry_${entry.name.replaceAll(' ', '_').replaceAll(RegExp(r'[^\w]'), '')}_${entry.id}.pdf';
      final file = File('$downloadPath/$fileName');
      await file.writeAsBytes(await pdf.save());
      return file.path;
    } catch (e) {
      // Fallback: save to app documents directory
      final docDir = await getApplicationDocumentsDirectory();
      final fileName = 'entry_${entry.name.replaceAll(' ', '_').replaceAll(RegExp(r'[^\w]'), '')}_${entry.id}.pdf';
      final file = File('${docDir.path}/$fileName');
      await file.writeAsBytes(await pdf.save());
      return file.path;
    }
  }

  pw.Widget _buildDetailRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 8),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 120,
            child: pw.Text(
              label,
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
                color: PdfColor.fromHex('#6B7280'),
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: 14,
                color: PdfColor.fromHex('#1F2937'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
