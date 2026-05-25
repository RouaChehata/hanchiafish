import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html; // ← pour le téléchargement direct sur Web
import '../models/boat_model.dart';

class PdfService {
  Future<void> generateAndDownload({
    required Boat boat,
    required String report,
    required String responsable,
    required double currentSpeed,
    required double currentLat,
    required double currentLon,
  }) async {
    final now = DateTime.now();
    final dateStr =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
    final timeStr =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    final responsableName =
        responsable.trim().isEmpty ? 'Non renseigné' : responsable.trim();

    final statusColor = {
          'En mer': PdfColors.blue700,
          'Au port': PdfColors.green700,
          'En maintenance': PdfColors.red700,
        }[boat.status] ??
        PdfColors.grey700;

    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        header: (context) => _buildHeader(boat, statusColor),
        footer: (context) => _buildFooter(context, dateStr, timeStr),
        build: (context) => [
          pw.SizedBox(height: 20),
          _buildInfoBadges(boat, currentLat, currentLon, currentSpeed),
          pw.SizedBox(height: 22),
          _buildDetailedReport(report),
          pw.SizedBox(height: 30),
          _buildResponsibilityBox(responsableName, boat.name, dateStr),
        ],
      ),
    );

    final pdfBytes = await pdf.save();
    final fileName = 'rapport_${boat.name}_$dateStr.pdf';

    if (kIsWeb) {
      // ✅ FIX Web : téléchargement direct sans dialog de partage
      final blob = html.Blob([pdfBytes], 'application/pdf');
      final url  = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', fileName)
        ..click();
      html.Url.revokeObjectUrl(url); // libérer la mémoire
    } else {
      // Mobile / Desktop : preview impression
      await Printing.layoutPdf(
        onLayout: (format) async => pdfBytes,
        name: fileName,
      );
    }
  }

  // ── التعديلات لتحسين نظافة الكود (Widgets) ──

  pw.Widget _buildHeader(Boat boat, PdfColor statusColor) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 14),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColors.blue900, width: 2.5),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text("RAPPORT D'ÉTAT MARITIME",
                  style: pw.TextStyle(
                      fontSize: 17,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blue900)),
              pw.SizedBox(height: 4),
              pw.Text('Hanchiafish Maritime — ${boat.name}',
                  style: const pw.TextStyle(fontSize: 11, color: PdfColors.blue700)),
            ],
          ),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: pw.BoxDecoration(
                color: statusColor, borderRadius: pw.BorderRadius.circular(20)),
            child: pw.Text(boat.status,
                style: pw.TextStyle(
                    color: PdfColors.white,
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 11)),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildFooter(pw.Context context, String date, String time) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 10),
      decoration: const pw.BoxDecoration(
          border: pw.Border(top: pw.BorderSide(color: PdfColors.grey300))),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('Généré le $date à $time — CONFIDENTIEL',
              style: const pw.TextStyle(color: PdfColors.grey500, fontSize: 8)),
          pw.Text('Page ${context.pageNumber} / ${context.pagesCount}',
              style: const pw.TextStyle(color: PdfColors.grey500, fontSize: 8)),
        ],
      ),
    );
  }

  pw.Widget _buildInfoBadges(Boat boat, double lat, double lon, double speed) {
    return pw.Row(
      children: [
        _infoBadge('ID', boat.id),
        pw.SizedBox(width: 8),
        _infoBadge('LATITUDE', lat.toStringAsFixed(4)),
        pw.SizedBox(width: 8),
        _infoBadge('LONGITUDE', lon.toStringAsFixed(4)),
        pw.SizedBox(width: 8),
        _infoBadge('VITESSE', '${speed.toStringAsFixed(1)} nd'),
        pw.SizedBox(width: 8),
        _infoBadge('ÉQUIPAGE', '${boat.crewMembers} marins'),
      ],
    );
  }

  pw.Widget _buildDetailedReport(String report) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text("RAPPORT D'ÉTAT DÉTAILLÉ",
            style: pw.TextStyle(
                fontSize: 13,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue800)),
        pw.Divider(color: PdfColors.blue200, thickness: 0.8),
        pw.SizedBox(height: 8),
        pw.Text(report,
            style: const pw.TextStyle(fontSize: 10.5, lineSpacing: 4.5)),
      ],
    );
  }

  pw.Widget _buildResponsibilityBox(String name, String boatName, String date) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(18),
      decoration: pw.BoxDecoration(
          color: PdfColors.blue50,
          border: pw.Border.all(color: PdfColors.blue200),
          borderRadius: pw.BorderRadius.circular(10)),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('DÉCLARATION DE RESPONSABILITÉ',
              style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue900)),
          pw.SizedBox(height: 10),
          pw.Text(
              'Je, $name, déclare que les informations contenues dans ce rapport sont exactes... Je suis responsable de la sécurité du $boatName.',
              style: const pw.TextStyle(fontSize: 10, lineSpacing: 3.5)),
          pw.SizedBox(height: 16),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              _signatureField('Date', date),
              _signatureField('Responsable', name),
              _signatureField('Signature', '________________'),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _signatureField(String label, String value) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(label, style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
        pw.SizedBox(height: 4),
        pw.Text(value, style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
      ],
    );
  }

  pw.Widget _infoBadge(String label, String value) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 7),
        decoration: pw.BoxDecoration(
          color: PdfColors.blue50,
          border: pw.Border.all(color: PdfColors.blue100),
          borderRadius: pw.BorderRadius.circular(8),
        ),
        child: pw.Column(
          children: [
            pw.Text(label,
                style: pw.TextStyle(
                    fontSize: 6.5,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue600)),
            pw.SizedBox(height: 3),
            pw.Text(value,
                style: pw.TextStyle(
                    fontSize: 8.5,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue900),
                textAlign: pw.TextAlign.center),
          ],
        ),
      ),
    );
  }
}
