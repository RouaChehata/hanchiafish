import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:primaa/models/boat_model.dart';
import '../services/pdf_service.dart';
import '../widgets/animated_speed_gauge.dart';
import '../widgets/wave_background_card.dart';
import '../widgets/live_indicator.dart';
import '../widgets/flip_stat_card.dart';

class BoatDetailScreen extends StatefulWidget {
  final Boat boat;
  const BoatDetailScreen({super.key, required this.boat});

  @override
  State<BoatDetailScreen> createState() => _BoatDetailScreenState();
}

class _BoatDetailScreenState extends State<BoatDetailScreen>
    with TickerProviderStateMixin {
  late LatLng _currentPosition;
  late double _currentSpeed;
  late String _lastUpdate;
  bool _followOnMap = true;
  String? _rapport;
  bool _rapportLoading = false;
  bool _showRapport = false;
  bool _isLoadingGps = false;
  final TextEditingController _responsableCtrl = TextEditingController();

  final MapController _mapController = MapController();
  Timer? _gpsTimer;
  late AnimationController _waveController;
  late AnimationController _pulseController;
  late AnimationController _sonarController;

  @override
  void initState() {
    super.initState();
    _currentPosition = LatLng(widget.boat.latitude, widget.boat.longitude);
    _currentSpeed = widget.boat.speed;
    _lastUpdate = widget.boat.lastUpdate;

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _sonarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    // Load GPS from Flask
    _loadGps();
    _gpsTimer = Timer.periodic(const Duration(seconds: 60), (timer) {
      _loadGps();
    });
  }

  Future<void> _loadGps() async {
    setState(() => _isLoadingGps = true);
    try {
      final response = await http
          .get(Uri.parse('http://127.0.0.1:5000/gps'))
          .timeout(const Duration(seconds: 3));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _currentPosition = LatLng(data['latitude'], data['longitude']);
          _currentSpeed = (data['speed'] ?? 0.0).toDouble();
          _lastUpdate = "Il y a quelques secondes";
          if (_followOnMap) {
            _mapController.move(_currentPosition, _mapController.camera.zoom);
          }
        });
      }
    } catch (e) {
      // serveur mch shayel — keep current position
    } finally {
      setState(() => _isLoadingGps = false);
    }
  }

  @override
  void dispose() {
    _gpsTimer?.cancel();
    _waveController.dispose();
    _pulseController.dispose();
    _sonarController.dispose();
    _responsableCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final boat = widget.boat;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 450,
            pinned: true,
            stretch: true,
            backgroundColor: const Color(0xFFF8FAFC),
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Color(0xFF1F2937),
                  size: 18,
                ),
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: _loadGps,
                  icon: _isLoadingGps
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF1E3A8A),
                          ),
                        )
                      : const Icon(
                          Icons.refresh,
                          color: Color(0xFF1E3A8A),
                          size: 18,
                        ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      'images/cage.png',
                      fit: BoxFit.cover,
                      gaplessPlayback: true,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Color(0xFF0D47A1),
                                Color(0xFF1565C0),
                                Color(0xFF1E88E5),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.transparent,
                            Colors.black.withOpacity(0.05),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 30,
                    left: 20,
                    right: 20,
                    child: Center(
                      child: _buildModernDashboardHeader(boat),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _buildModernSectionHeader('Informations générales'),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _buildModernStatsGrid(boat),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _buildModernSectionHeader(
                      'Position GPS & Temps réel',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _buildModernGpsInfo(),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _buildSpeedGaugeSection(),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _buildModernMapCard(),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _buildGroqRapportSection(boat),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _generateRapport(Boat boat) async {
    setState(() {
      _rapportLoading = true;
      _rapport = null;
      _showRapport = true;
    });

    const apiKey = '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';

    final prompt =
        """
Tu es un officier maritime. Génère un rapport d'état professionnel en français.

DONNÉES DU BATEAU:
- Nom: ${boat.name}
- Statut: ${boat.status}
- Position GPS: Lat ${_currentPosition.latitude.toStringAsFixed(4)}, Lon ${_currentPosition.longitude.toStringAsFixed(4)}
- Vitesse: ${_currentSpeed.toStringAsFixed(1)} noeuds
- Dernière mise à jour: $_lastUpdate

Le rapport doit inclure:
1. RÉSUMÉ DE L'ÉTAT
2. POSITION & NAVIGATION
3. ÉTAT TECHNIQUE
4. RECOMMANDATIONS
""";

    try {
      final response = await http.post(
        Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'llama-3.1-8b-instant',
          'messages': [
            {'role': 'user', 'content': prompt},
          ],
          'max_tokens': 800,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _rapport = data['choices'][0]['message']['content'];
        });
      } else {
        final error = jsonDecode(response.body);
        setState(() {
          _rapport = 'Erreur: ${error['error']['message']}';
        });
      }
    } catch (e) {
      setState(() {
        _rapport = 'Erreur connexion: $e';
      });
    } finally {
      setState(() {
        _rapportLoading = false;
      });
    }
  }

  Future<void> _downloadPdf(Boat boat) async {
    if (_rapport == null) return;

    final now = DateTime.now();
    final dateStr =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
    final responsable = _responsableCtrl.text.trim().isEmpty
        ? 'Non renseigné'
        : _responsableCtrl.text.trim();

    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        header: (context) => pw.Container(
          padding: const pw.EdgeInsets.only(bottom: 12),
          decoration: const pw.BoxDecoration(
            border: pw.Border(
              bottom: pw.BorderSide(color: PdfColors.blue800, width: 2),
            ),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    "RAPPORT D'ETAT MARITIME",
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blue900,
                    ),
                  ),
                  pw.Text(
                    boat.name,
                    style: pw.TextStyle(fontSize: 12, color: PdfColors.blue700),
                  ),
                ],
              ),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue700,
                  borderRadius: pw.BorderRadius.circular(20),
                ),
                child: pw.Text(
                  boat.status,
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
        ),
        footer: (context) => pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'Genere le $dateStr — CONFIDENTIEL',
              style: const pw.TextStyle(color: PdfColors.grey500, fontSize: 8),
            ),
            pw.Text(
              'Page ${context.pageNumber} / ${context.pagesCount}',
              style: const pw.TextStyle(color: PdfColors.grey500, fontSize: 8),
            ),
          ],
        ),
        build: (context) => [
          pw.SizedBox(height: 20),
          pw.Text(
            "RAPPORT D'ETAT DETAILLE",
            style: pw.TextStyle(
              fontSize: 13,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue800,
            ),
          ),
          pw.Divider(color: PdfColors.blue200),
          pw.SizedBox(height: 8),
          pw.Text(
            _rapport!,
            style: const pw.TextStyle(fontSize: 10.5, lineSpacing: 4),
          ),
          pw.SizedBox(height: 30),
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.blue200),
              borderRadius: pw.BorderRadius.circular(8),
              color: PdfColors.blue50,
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'DÉCLARATION DE RESPONSABILITÉ',
                  style: pw.TextStyle(
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue900,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  'Je, $responsable, déclare que les informations contenues dans ce rapport sont exactes et mises à jour. '
                  'Je suis responsable de la sécurité et de la maintenance du ${boat.name}.',
                  style: const pw.TextStyle(fontSize: 10, lineSpacing: 3),
                ),
                pw.SizedBox(height: 14),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Date : $dateStr',
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      'Signature : $responsable',
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name: 'rapport_${boat.name}.pdf',
    );
  }

  Widget _buildGroqRapportSection(Boat boat) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.blue.shade300,
                Colors.blue.shade400,
                Colors.blueAccent,
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.shade300.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: Colors.blueAccent.withOpacity(0.2),
                blurRadius: 25,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: _rapportLoading ? null : () => _generateRapport(boat),
            icon: _rapportLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text('⚡', style: TextStyle(fontSize: 18)),
            label: Text(
              _rapportLoading
                  ? 'Groq génère le rapport...'
                  : 'Générer Rapport IA',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        if (_showRapport && _rapport != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.blue.shade50,
                  Colors.blue.shade100,
                  Colors.blue.shade50,
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.blue.shade200.withOpacity(0.5),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.shade200.withOpacity(0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue.shade300, Colors.blue.shade400],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.description_outlined,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Rapport Généré',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => setState(() => _showRapport = false),
                      icon: const Icon(
                        Icons.close,
                        size: 18,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const Divider(color: Colors.blue),
                const SizedBox(height: 8),
                Text(
                  _rapport!,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    height: 1.7,
                    color: Colors.blue.shade800,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Nom du responsable',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _responsableCtrl,
                  decoration: InputDecoration(
                    hintText: 'Ex: Roua Chehata',
                    hintStyle: GoogleFonts.plusJakartaSans(color: Colors.grey),
                    prefixIcon: const Icon(
                      Icons.person_outline,
                      color: Colors.blue,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.blue.shade200),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.blue.shade200),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Colors.blue,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => _downloadPdf(boat),
                    icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
                    label: Text(
                      'Télécharger PDF',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildModernDashboardHeader(Boat boat) {
    Color statusColor;
    String statusLabel = boat.status;
    IconData statusIcon;
    switch (boat.status) {
      case 'En mer':
        statusColor = Colors.blueAccent;
        statusIcon = Icons.water;
        break;
      case 'Au port':
        statusColor = Colors.amber;
        statusIcon = Icons.anchor;
        break;
      case 'En maintenance':
        statusColor = Colors.red;
        statusIcon = Icons.build;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help_outline;
        statusLabel = 'Statut inconnu';
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 400),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.75),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
          border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.blueAccent.withOpacity(0.15),
                    Colors.blue.withOpacity(0.08),
                  ],
                ),
                border: Border.all(
                  color: Colors.blueAccent.withOpacity(0.4),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blueAccent.withOpacity(0.25),
                    blurRadius: 25,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  boat.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blueAccent, Colors.blue],
                      ),
                    ),
                    child: const Icon(
                      Icons.directions_boat_filled,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              boat.name,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1F2937),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'ID: ${boat.id}',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: statusColor.withOpacity(0.4),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 16, color: statusColor),
                      const SizedBox(width: 8),
                      Text(
                        statusLabel,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                LiveIndicator(
                  text: _lastUpdate,
                  size: 10,
                  textStyle: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF10B981),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernSectionHeader(String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 24,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.blueAccent, Colors.blue],
              ),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1F2937),
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernStatsGrid(Boat boat) {
    return SizedBox(
      height: 150,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          FlipStatCard(
            icon: Icons.speed_rounded,
            value: '${_currentSpeed.toStringAsFixed(0)}',
            label: 'nœuds',
            detailTitle: 'Vitesse actuelle',
            detailContent: 'Le bateau navigue à ${_currentSpeed.toStringAsFixed(1)} nœuds. Vitesse maximale enregistrée: 45.2 nœuds.',
            iconColor: Colors.blueAccent,
          ),
          const SizedBox(width: 12),
          FlipStatCard(
            icon: Icons.group_rounded,
            value: '${boat.crewMembers}',
            label: 'marins',
            detailTitle: 'Équipage',
            detailContent: '${boat.crewMembers} membres d\'équipage à bord. Tous les membres sont qualifiés et opérationnels.',
            iconColor: Colors.purple,
          ),
          const SizedBox(width: 12),
          FlipStatCard(
            icon: boat.cameraActive
                ? Icons.videocam_rounded
                : Icons.videocam_off_rounded,
            value: boat.cameraActive ? 'ON' : 'OFF',
            label: 'caméra',
            detailTitle: 'Système de surveillance',
            detailContent: boat.cameraActive 
                ? 'Caméras actives et enregistrant. 4 caméras opérationnelles.'
                : 'Caméras désactivées. Maintenance en cours.',
            iconColor: boat.cameraActive ? Colors.green : Colors.grey,
          ),
                  ],
      ),
    );
  }

  Widget _buildCompactStatCard({
    required IconData icon,
    required String value,
    required String unit,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.1), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1F2937),
            ),
          ),
          Text(
            unit,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 8,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernGpsInfo() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF8FAFC), Color(0xFFF1F5F9), Colors.white],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0D47A1), Color(0xFF1565C0)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.location_on_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Coordonnées actuelles',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1F2937),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Position GPS en temps réel',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: const Color(0xFF6B7280),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              // Live indicator
              LiveIndicator(
                text: _lastUpdate,
                size: 8,
                textStyle: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF10B981),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Speed badge from GPS API
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0D47A1), Color(0xFF1565C0)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0D47A1).withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.speed_rounded, color: Colors.white, size: 22),
                const SizedBox(width: 12),
                Text(
                  'Vitesse GPS',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                  ),
                ),
                const Spacer(),
                Text(
                  '${_currentSpeed.toStringAsFixed(1)} km/h',
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0D47A1).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.explore,
                              color: Color(0xFF0D47A1),
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Latitude',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: const Color(0xFF6B7280),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _currentPosition.latitude.toStringAsFixed(6),
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1F2937),
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(width: 1, height: 50, color: const Color(0xFFE5E7EB)),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF8B5CF6).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.compass_calibration,
                                color: Color(0xFF8B5CF6),
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Longitude',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: const Color(0xFF6B7280),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _currentPosition.longitude.toStringAsFixed(6),
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1F2937),
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpeedGaugeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildModernSectionHeader('Vitesse en temps réel'),
        const SizedBox(height: 16),
        WaveBackgroundCard(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: AnimatedSpeedGauge(
              speed: _currentSpeed,
              maxSpeed: 50.0,
              unit: 'nœuds',
              size: 240.0,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModernMapCard() {
    return Container(
      height: 400,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white, width: 4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.blueAccent.withOpacity(0.1),
            blurRadius: 40,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _currentPosition,
                initialZoom: 13,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.primaa',
                ),
                // Geofencing circle
                CircleLayer(
                  circles: [
                    CircleMarker(
                      point: const LatLng(
                        35.661970525816834,
                        10.958101377208251,
                      ),
                      radius: 500,
                      useRadiusInMeter: true,
                      color: Colors.blue.withOpacity(0.15),
                      borderColor: Colors.blue,
                      borderStrokeWidth: 2,
                    ),
                  ],
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      width: 60,
                      height: 60,
                      point: _currentPosition,
                      child: _buildModernBoatMarker(),
                    ),
                  ],
                ),
              ],
            ),
            Positioned(
              top: 20,
              right: 20,
              child: Column(
                children: [
                  _buildModernMapControl(
                    icon: Icons.my_location_rounded,
                    onTap: () => _mapController.move(
                      _currentPosition,
                      _mapController.camera.zoom,
                    ),
                    tooltip: 'Centrer sur la position',
                  ),
                  const SizedBox(height: 12),
                  _buildModernMapControl(
                    icon: _followOnMap
                        ? Icons.gps_fixed_rounded
                        : Icons.location_searching_rounded,
                    isActive: _followOnMap,
                    onTap: () => setState(() => _followOnMap = !_followOnMap),
                    tooltip: _followOnMap ? 'Suivi activé' : 'Activer le suivi',
                  ),
                  const SizedBox(height: 12),
                  _buildModernMapControl(
                    icon: Icons.layers_rounded,
                    onTap: () {},
                    tooltip: 'Changer de carte',
                  ),
                ],
              ),
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: _buildModernFollowButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernBoatMarker() {
    return AnimatedBuilder(
      animation: Listenable.merge([_pulseController, _sonarController]),
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Sonar pulse circles - 3 expanding circles with fade out
            _buildSonarCircle(0.0, 1.0), // First pulse
            _buildSonarCircle(0.3, 0.8), // Second pulse (delayed)
            _buildSonarCircle(0.6, 0.6), // Third pulse (delayed)
            
            // Original pulse ring
            Container(
              width: 55 + _pulseController.value * 10,
              height: 55 + _pulseController.value * 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blueAccent.withOpacity(
                  0.2 - _pulseController.value * 0.15,
                ),
              ),
            ),
            // Boat icon container
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.blueAccent, Colors.blue],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blueAccent.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(8),
              child: const Icon(
                Icons.directions_boat_filled,
                color: Colors.white,
                size: 28,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSonarCircle(double delay, double maxOpacity) {
    final adjustedValue = (_sonarController.value + delay) % 1.0;
    final size = 30.0 + adjustedValue * 50.0; // Expand from 30 to 80
    final opacity = maxOpacity * (1.0 - adjustedValue); // Fade out as it expands
    
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFF0EA5E9).withOpacity(opacity),
          width: 2.0,
        ),
      ),
    );
  }

  Widget _buildModernMapControl({
    required IconData icon,
    required VoidCallback onTap,
    bool isActive = false,
    String? tooltip,
  }) {
    return Tooltip(
      message: tooltip ?? '',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: isActive ? const Color(0xFF0D47A1) : Colors.grey[300]!,
              width: 2,
            ),
          ),
          child: Icon(
            icon,
            size: 24,
            color: isActive ? const Color(0xFF0D47A1) : Colors.grey[700],
          ),
        ),
      ),
    );
  }

  Widget _buildModernFollowButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D47A1), Color(0xFF1565C0)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D47A1).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        onPressed: () {
          setState(() => _followOnMap = true);
          _mapController.move(_currentPosition, _mapController.camera.zoom);
        },
        icon: const Icon(Icons.map_rounded, size: 20),
        label: const Text(
          'Suivre le bateau sur la carte',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

class SubtleWavePainter extends CustomPainter {
  final double animationValue;
  SubtleWavePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width == 0 || size.height == 0) return;
    final paint = Paint()..style = PaintingStyle.fill;
    _drawSubtleWave(
      canvas,
      size,
      paint..color = Colors.white.withOpacity(0.02),
      0.85,
      animationValue * 2 * math.pi,
      30,
    );
    _drawSubtleWave(
      canvas,
      size,
      paint..color = Colors.white.withOpacity(0.015),
      0.9,
      animationValue * 2 * math.pi + math.pi / 2,
      20,
    );
  }

  void _drawSubtleWave(
    Canvas canvas,
    Size size,
    Paint paint,
    double yPosition,
    double phase,
    double amplitude,
  ) {
    if (size.width == 0 || size.height == 0) return;
    final path = ui.Path();
    final y = size.height * yPosition;
    final waveLength = size.width / 3;
    path.moveTo(0, y);
    for (double x = 0; x <= size.width; x += 3) {
      path.lineTo(
        x,
        y + math.sin((x / waveLength * 2 * math.pi) + phase) * amplitude,
      );
    }
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(SubtleWavePainter oldDelegate) =>
      oldDelegate.animationValue != animationValue;
}