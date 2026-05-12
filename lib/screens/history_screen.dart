import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:primaa/api_service.dart';
import '../models/boat_model.dart';
import 'app theme.dart';

// ════════════════════════════════════════════════════════════════
//  HistoryScreen — Amélioré
//  • Hanchia1 (id='1') → GPS réel via ApiService.getGpsHistory()
//    + auto-refresh toutes les 30 s
//  • Autres bateaux → positions démo générées localement
//  • Filtres Aujourd'hui / Semaine / Mois → filtrés par date réelle
//    (changer le filtre ne recharge PAS l'API, juste re-filtre)
//  • Toggle carte 🗺 / liste 📋 dans l'AppBar
//  • Mini-carte avec tracé du trajet, départ 🟢 et arrivée 🔴
//  • Carte résumé : points GPS, distance, durée, vitesse moy.
// ════════════════════════════════════════════════════════════════

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final List<Boat> _boats = Boat.getDemoBoats();
  String? _selectedBoatId;
  String _selectedFilter = "Aujourd'hui";
  List<dynamic> _allHistory = [];
  List<dynamic> _historyData = [];
  bool _isLoading = true;
  bool _showMap = false;
  Timer? _gpsTimer;

  static const String _realBoatId = '1'; // Hanchia1
  static const _filters = ["Aujourd'hui", 'Semaine', 'Mois'];

  @override
  void initState() {
    super.initState();
    _selectedBoatId = _boats.first.id;
    _loadHistory();
    _gpsTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (_selectedBoatId == _realBoatId && mounted) _loadHistory();
    });
  }

  @override
  void dispose() {
    _gpsTimer?.cancel();
    super.dispose();
  }

  // ── Chargement ──────────────────────────────────────────────
  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    List<dynamic> data;
    if (_selectedBoatId == _realBoatId) {
      data = await ApiService.getGpsHistory();
    } else {
      final boat = _boats.firstWhere(
        (b) => b.id == _selectedBoatId,
        orElse: () => _boats.first,
      );
      data = _generateDemoHistory(boat);
    }
    setState(() {
      _allHistory = data;
      _historyData = _applyFilter(data);
      _isLoading = false;
    });
  }

  // ── Filtre par période ──────────────────────────────────────
  List<dynamic> _applyFilter(List<dynamic> data) {
    if (data.isEmpty) return data;
    final now = DateTime.now();
    late DateTime cutoff;
    switch (_selectedFilter) {
      case 'Semaine':
        cutoff = now.subtract(const Duration(days: 7));
        break;
      case 'Mois':
        cutoff = now.subtract(const Duration(days: 30));
        break;
      default: // Aujourd'hui
        cutoff = DateTime(now.year, now.month, now.day);
    }
    final filtered = data.where((item) {
      try {
        return DateTime.parse(item['timestamp'].toString()).isAfter(cutoff);
      } catch (_) {
        return true;
      }
    }).toList();
    // Si filtre trop strict → on retourne toutes les données avec avertissement
    return filtered;
  }

  // ── Historique démo ─────────────────────────────────────────
  List<Map<String, dynamic>> _generateDemoHistory(Boat boat) {
    final now = DateTime.now();
    final rng = math.Random(boat.id.hashCode);
    return List.generate(14, (i) {
      final ts = now.subtract(Duration(hours: i * 3 + rng.nextInt(2)));
      return {
        'timestamp': ts.toIso8601String(),
        'latitude': boat.latitude + (rng.nextDouble() - 0.5) * 0.03,
        'longitude': boat.longitude + (rng.nextDouble() - 0.5) * 0.03,
        'speed': (rng.nextDouble() * 14 + 1).toStringAsFixed(1),
      };
    });
  }

  // ── Résumé ──────────────────────────────────────────────────
  Map<String, String> _computeSummary() {
    if (_historyData.length < 2) {
      return {
        'points': '${_historyData.length}',
        'distance': '—',
        'duration': '—',
        'avgSpeed': '—',
      };
    }
    double totalKm = 0;
    for (int i = 1; i < _historyData.length; i++) {
      totalKm += _haversine(
        (_historyData[i - 1]['latitude'] as num).toDouble(),
        (_historyData[i - 1]['longitude'] as num).toDouble(),
        (_historyData[i]['latitude'] as num).toDouble(),
        (_historyData[i]['longitude'] as num).toDouble(),
      );
    }
    String duration = '—';
    try {
      final t1 = DateTime.parse(_historyData.last['timestamp'].toString());
      final t2 = DateTime.parse(_historyData.first['timestamp'].toString());
      final d = t2.difference(t1).abs();
      duration = d.inHours > 0
          ? '${d.inHours}h ${d.inMinutes % 60}min'
          : '${d.inMinutes} min';
    } catch (_) {}
    final speeds = _historyData
        .map((e) => double.tryParse(e['speed']?.toString() ?? '0') ?? 0.0)
        .toList();
    final avg = speeds.isEmpty
        ? 0.0
        : speeds.reduce((a, b) => a + b) / speeds.length;
    return {
      'points': '${_historyData.length}',
      'distance': '${totalKm.toStringAsFixed(1)} km',
      'duration': duration,
      'avgSpeed': '${avg.toStringAsFixed(1)} nœuds',
    };
  }

  double _haversine(double lat1, double lon1, double lat2, double lon2) {
    const r = 6371.0;
    final dLat = _deg2rad(lat2 - lat1);
    final dLon = _deg2rad(lon2 - lon1);
    final a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_deg2rad(lat1)) *
            math.cos(_deg2rad(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    return r * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }

  double _deg2rad(double deg) => deg * math.pi / 180;

  // ── Build ───────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final summary = _computeSummary();
    return MaritimeScaffold(
      appBar: MaritimeAppBar(
        title: 'Historique',
        actions: [
          IconButton(
            icon: Icon(
              _showMap ? Icons.list_alt_rounded : Icons.map_rounded,
              color: AppColors.white,
            ),
            tooltip: _showMap ? 'Vue liste' : 'Vue carte',
            onPressed: () => setState(() => _showMap = !_showMap),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.white),
            onPressed: _loadHistory,
          ),
        ],
      ),
      headerContent: _buildFilters(),
      child: _isLoading
          ? const MaritimeLoadingState(message: 'Chargement du trajet…')
          : _historyData.isEmpty
          ? MaritimeEmptyState(
              icon: Icons.route,
              title: 'Aucun point sur cette période',
              subtitle:
                  'Essayez "Semaine" ou "Mois"\npour voir plus d\'historique.',
              action: TextButton.icon(
                onPressed: () {
                  setState(() {
                    _selectedFilter = 'Mois';
                    _historyData = _applyFilter(_allHistory);
                  });
                },
                icon: const Icon(Icons.date_range),
                label: const Text('Voir ce mois'),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryCard(summary),
                if (_showMap) _buildMapView() else _buildListView(),
              ],
            ),
    );
  }

  // ── Filtres dans la zone bleue ───────────────────────────────
  Widget _buildFilters() {
    final isReal = _selectedBoatId == _realBoatId;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dropdown bateau
          Container(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(AppRadius.lg),
              boxShadow: AppShadows.card,
            ),
            child: DropdownButton<String>(
              value: _selectedBoatId,
              isExpanded: true,
              underline: SizedBox(),
              dropdownColor: AppColors.white,
              icon: const Icon(Icons.arrow_drop_down, color: AppColors.primary),
              items: _boats.map((boat) {
                final real = boat.id == _realBoatId;
                return DropdownMenuItem<String>(
                  value: boat.id,
                  child: Row(
                    children: [
                      Icon(
                        Icons.directions_boat,
                        color: real ? AppColors.success : AppColors.primary,
                        size: 18,
                      ),
                      SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          boat.name,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: real ? AppColors.success : AppColors.primary,
                          ),
                        ),
                      ),
                      if (real)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.success.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'GPS LIVE',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: AppColors.success,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (v) {
                setState(() => _selectedBoatId = v);
                _loadHistory();
              },
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          // Chips période
          Row(
            children:
                _filters
                    .map((f) => _filterChip(f, _selectedFilter == f))
                    .expand((w) => [w, SizedBox(width: AppSpacing.sm)])
                    .toList()
                  ..removeLast(),
          ),
          if (isReal) ...[
            SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.gps_fixed, color: AppColors.success, size: 12),
                      SizedBox(width: 4),
                      Text(
                        'GPS réel · refresh 30s',
                        style: TextStyle(
                          color: AppColors.success,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _filterChip(String label, bool isSelected) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          _selectedFilter = label;
          _historyData = _applyFilter(_allHistory);
        }),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.white
                : Colors.white.withOpacity(0.55),
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: isSelected ? AppColors.primary : Colors.white54,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
              color: isSelected ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }

  // ── Carte résumé ─────────────────────────────────────────────
  Widget _buildSummaryCard(Map<String, String> s) {
    return Container(
      margin: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: AppShadows.elevated,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.route, color: AppColors.white, size: 17),
              SizedBox(width: AppSpacing.sm),
              const Text(
                'Résumé du trajet',
                style: TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Text(
                  _selectedFilter,
                  style: TextStyle(
                    color: AppColors.white.withOpacity(0.9),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          Row(
            children: [
              _summaryItem(Icons.pin_drop_outlined, s['points']!, 'Points GPS'),
              _vDivider(),
              _summaryItem(Icons.straighten, s['distance']!, 'Distance'),
              _vDivider(),
              _summaryItem(Icons.timer_outlined, s['duration']!, 'Durée'),
              _vDivider(),
              _summaryItem(
                Icons.speed_outlined,
                s['avgSpeed']!,
                'Vitesse moy.',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryItem(IconData icon, String value, String label) => Expanded(
    child: Column(
      children: [
        Icon(icon, color: AppColors.white.withOpacity(0.8), size: 15),
        SizedBox(height: 3),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.w800,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          label,
          style: TextStyle(
            color: AppColors.white.withOpacity(0.6),
            fontSize: 9,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );

  Widget _vDivider() =>
      Container(width: 1, height: 32, color: AppColors.white.withOpacity(0.25));

  // ── Vue carte ────────────────────────────────────────────────
  Widget _buildMapView() {
    final points = _historyData
        .map(
          (e) => LatLng(
            (e['latitude'] as num).toDouble(),
            (e['longitude'] as num).toDouble(),
          ),
        )
        .toList();

    if (points.isEmpty) return SizedBox();

    final centerLat =
        points.map((p) => p.latitude).reduce((a, b) => a + b) / points.length;
    final centerLng =
        points.map((p) => p.longitude).reduce((a, b) => a + b) / points.length;

    return Expanded(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.lg,
          0,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          child: FlutterMap(
            options: MapOptions(
              initialCenter: LatLng(centerLat, centerLng),
              initialZoom: 13,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.primaa',
              ),
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: points,
                    color: AppColors.primaryLight,
                    strokeWidth: 3.5,
                  ),
                ],
              ),
              MarkerLayer(
                markers: points.asMap().entries.map((e) {
                  final isFirst = e.key == 0;
                  final isLast = e.key == points.length - 1;
                  final isPOI = isFirst || isLast;
                  return Marker(
                    width: isPOI ? 36 : 12,
                    height: isPOI ? 36 : 12,
                    point: e.value,
                    child: isPOI
                        ? Container(
                            decoration: BoxDecoration(
                              color: isFirst
                                  ? AppColors.success
                                  : AppColors.error,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.white,
                                width: 2.5,
                              ),
                              boxShadow: AppShadows.card,
                            ),
                            child: Icon(
                              isFirst
                                  ? Icons.play_arrow_rounded
                                  : Icons.flag_rounded,
                              color: AppColors.white,
                              size: 18,
                            ),
                          )
                        : Container(
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.65),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.white,
                                width: 1.5,
                              ),
                            ),
                          ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Vue liste ────────────────────────────────────────────────
  Widget _buildListView() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.sm,
              AppSpacing.xl,
              AppSpacing.sm,
            ),
            child: Row(
              children: [
                Text(
                  'Points du trajet',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                MaritimeBadge(
                  label: '${_historyData.length} pts',
                  color: AppColors.primaryLight,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              itemCount: _historyData.length,
              itemBuilder: (_, i) => _buildHistoryItem(_historyData[i], i),
            ),
          ),
        ],
      ),
    );
  }

  // ── Item timeline ────────────────────────────────────────────
  Widget _buildHistoryItem(Map<String, dynamic> item, int index) {
    final ts = item['timestamp'].toString();
    final time = ts.length >= 16 ? ts.substring(11, 16) : '';
    final date = ts.length >= 10 ? ts.substring(0, 10) : ts;
    final lat = (item['latitude'] as num).toDouble();
    final lng = (item['longitude'] as num).toDouble();
    final speed = double.tryParse(item['speed']?.toString() ?? '0') ?? 0.0;
    final isFirst = index == 0;
    final isLast = index == _historyData.length - 1;

    // Couleur du point selon la position dans le trajet
    final dotColor = isFirst
        ? AppColors.success
        : isLast
        ? AppColors.error
        : AppColors.primary;

    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Timeline ──────────────────────────
          SizedBox(
            width: 24,
            child: Column(
              children: [
                SizedBox(height: 4),
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: dotColor,
                    border: Border.all(color: AppColors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: dotColor.withOpacity(0.4),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: isFirst || isLast
                      ? Icon(
                          isFirst ? Icons.play_arrow : Icons.flag,
                          size: 7,
                          color: AppColors.white,
                        )
                      : null,
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [dotColor.withOpacity(0.5), AppColors.border],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(width: AppSpacing.md),
          // ── Carte point ───────────────────────
          Expanded(
            child: Container(
              margin: EdgeInsets.only(bottom: AppSpacing.sm),
              padding: EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                  color: isFirst
                      ? AppColors.success.withOpacity(0.3)
                      : isLast
                      ? AppColors.error.withOpacity(0.3)
                      : AppColors.border,
                ),
                boxShadow: AppShadows.subtle,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ligne 1 : heure + badge
                  Row(
                    children: [
                      Text(
                        time,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(width: AppSpacing.sm),
                      if (isFirst)
                        MaritimeBadge(
                          label: 'DÉPART',
                          color: AppColors.success,
                          icon: Icons.play_arrow,
                        ),
                      if (isLast && !isFirst)
                        MaritimeBadge(
                          label: 'ARRIVÉE',
                          color: AppColors.error,
                          icon: Icons.flag,
                        ),
                      if (!isFirst && !isLast)
                        MaritimeBadge(
                          label: 'En mer',
                          color: AppColors.primaryLight,
                          filled: false,
                        ),
                      const Spacer(),
                      Text(
                        date,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.sm),
                  // Ligne 2 : coordonnées
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.lightGrey,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 13,
                          color: AppColors.primaryLight,
                        ),
                        SizedBox(width: 4),
                        Text(
                          '${lat.toStringAsFixed(5)},  ${lng.toStringAsFixed(5)}',
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 11,
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: AppSpacing.sm),
                  // Ligne 3 : vitesse
                  Row(
                    children: [
                      Icon(
                        Icons.speed,
                        size: 13,
                        color: speed > 8
                            ? AppColors.warning
                            : AppColors.textSecondary,
                      ),
                      SizedBox(width: 4),
                      Text(
                        '${speed.toStringAsFixed(1)} nœuds',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: speed > 8
                              ? AppColors.warning
                              : AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(width: AppSpacing.md),
                      Text(
                        'Point #${index + 1}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 10,
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
    );
  }
}
