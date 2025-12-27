import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class BaseMap extends StatefulWidget {
  final String? start;
  final String? end;
  final double height;
  final double width;
  final double borderRadius;
  final bool showRouteInfoOverlay;
  final bool showZoomControls;
  final double? routeDistance;
  final String title;
  final Color? accentColor;
  final Function(LatLng)? onLocationSelected;
  final bool isSelectable;

  const BaseMap({
    Key? key,
    required this.start,
    required this.end,
    required this.height,
    required this.width,
    this.borderRadius = 20,
    this.showRouteInfoOverlay = true,
    this.showZoomControls = true,
    this.routeDistance,
    this.title = 'Location',
    this.accentColor,
    this.onLocationSelected,
    this.isSelectable = false,
  }) : super(key: key);

  @override
  State<BaseMap> createState() => _BaseMapState();
}

class _BaseMapState extends State<BaseMap> with TickerProviderStateMixin {
  late final MapController _mapController;
  double _zoom = 13;
  List<LatLng>? _routePoints;
  bool _loadingRoute = false;
  String? _routeError;
  bool _isDragging = false;
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOutCubic),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _fadeController.forward();
    _scaleController.forward();
    _fetchRoute();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  Future<void> _fetchRoute() async {
    LatLng? startLatLng;
    LatLng? endLatLng;

    try {
      if (widget.start != null && widget.end != null) {
        final startParts = widget.start!.split(',');
        final endParts = widget.end!.split(',');
        if (startParts.length == 2 && endParts.length == 2) {
          startLatLng = LatLng(
            double.parse(startParts[0]),
            double.parse(startParts[1]),
          );
          endLatLng = LatLng(
            double.parse(endParts[0]),
            double.parse(endParts[1]),
          );
        }
      }
    } catch (e) {
      setState(() {
        _routeError = 'Failed to parse locations.';
      });
      return;
    }

    if (startLatLng == null || endLatLng == null) {
      setState(() {
        _routeError = 'Location not available.';
      });
      return;
    }

    setState(() {
      _loadingRoute = true;
      _routeError = null;
    });

    try {
      final apiKey = dotenv.env['OPENROUTESERVICE_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        setState(() {
          _routeError = 'API key not found.';
          _loadingRoute = false;
        });
        return;
      }

      final url = Uri.parse(
        'https://api.openrouteservice.org/v2/directions/driving-car?api_key=$apiKey&start=${startLatLng.longitude},${startLatLng.latitude}&end=${endLatLng.longitude},${endLatLng.latitude}',
      );

      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final geometry = data['features'][0]['geometry'];
        if (geometry['type'] == 'LineString') {
          final coords = geometry['coordinates'] as List;
          final points = coords
              .map<LatLng>(
                (c) =>
                    LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble()),
              )
              .toList();
          setState(() {
            _routePoints = points;
            _loadingRoute = false;
          });
        } else {
          setState(() {
            _routeError = 'Route geometry not found.';
            _loadingRoute = false;
          });
        }
      } else {
        setState(() {
          _routeError = 'Failed to fetch route (${response.statusCode})';
          _loadingRoute = false;
        });
      }
    } catch (e) {
      setState(() {
        _routeError = 'Error fetching route.';
        _loadingRoute = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final accentColor =
        widget.accentColor ?? Theme.of(context).colorScheme.primary;
    LatLng? startLatLng;
    LatLng? endLatLng;
    String? error;

    try {
      if (widget.start != null && widget.end != null) {
        final startParts = widget.start!.split(',');
        final endParts = widget.end!.split(',');
        if (startParts.length == 2 && endParts.length == 2) {
          startLatLng = LatLng(
            double.parse(startParts[0]),
            double.parse(startParts[1]),
          );
          endLatLng = LatLng(
            double.parse(endParts[0]),
            double.parse(endParts[1]),
          );
        } else {
          error = 'Invalid location format.';
        }
      } else {
        error = 'Location not available.';
      }
    } catch (e) {
      error = 'Failed to parse locations.';
    }

    if (error != null) {
      return _buildErrorCard(error, accentColor);
    }

    final LatLng center = startLatLng != null && endLatLng != null
        ? LatLng(
            (startLatLng.latitude + endLatLng.latitude) / 2,
            (startLatLng.longitude + endLatLng.longitude) / 2,
          )
        : (startLatLng ?? LatLng(0, 0));

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          height: widget.height,
          width: widget.width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            boxShadow: [
              BoxShadow(
                color: accentColor.withOpacity(0.15),
                blurRadius: 20,
                spreadRadius: 2,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            child: Stack(
              children: [
                _buildMapContent(center, startLatLng, endLatLng, accentColor),
                if (widget.showRouteInfoOverlay)
                  _buildRouteInfoOverlay(accentColor),
                if (widget.showZoomControls) _buildZoomControls(accentColor),
                if (widget.routeDistance != null)
                  _buildDistanceOverlay(accentColor),
                if (_routeError != null)
                  _buildErrorOverlay(_routeError!, accentColor),
                if (_loadingRoute) _buildLoadingOverlay(accentColor),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMapContent(
    LatLng center,
    LatLng? startLatLng,
    LatLng? endLatLng,
    Color accentColor,
  ) {
    return MouseRegion(
      cursor: _isDragging
          ? SystemMouseCursors.grabbing
          : SystemMouseCursors.grab,
      child: Listener(
        onPointerDown: (_) => setState(() => _isDragging = true),
        onPointerUp: (_) => setState(() => _isDragging = false),
        onPointerCancel: (_) => setState(() => _isDragging = false),
        child: FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: center,
            initialZoom: _zoom,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
            ),
            onPositionChanged: (pos, hasGesture) {
              setState(() {
                _zoom = pos.zoom ?? _zoom;
              });
            },
            onTap: widget.isSelectable
                ? (tapPosition, point) {
                    if (widget.onLocationSelected != null) {
                      widget.onLocationSelected!(point);
                    }
                  }
                : null,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.manifest_desktop',
            ),
            if (_routePoints != null)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: _routePoints!,
                    color: accentColor,
                    strokeWidth: 6.0,
                    borderStrokeWidth: 10.0,
                    borderColor: Colors.white.withOpacity(0.8),
                  ),
                ],
              ),
            if (startLatLng != null)
              MarkerLayer(
                markers: [
                  _buildMarker(
                    startLatLng,
                    Icons.play_arrow,
                    Colors.green,
                    accentColor,
                  ),
                  if (endLatLng != null)
                    _buildMarker(
                      endLatLng,
                      Icons.festival,
                      Colors.red,
                      accentColor,
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Marker _buildMarker(
    LatLng point,
    IconData icon,
    Color color,
    Color accentColor,
  ) {
    return Marker(
      point: point,
      width: 50,
      height: 50,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 4),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 12,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }

  Widget _buildRouteInfoOverlay(Color accentColor) {
    return Positioned(
      top: 16,
      left: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: accentColor.withOpacity(0.3), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.location_on, color: accentColor, size: 20),
            const SizedBox(width: 8),
            Text(
              widget.title,
              style: TextStyle(
                color: Colors.grey[800],
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildZoomControls(Color accentColor) {
    return Positioned(
      top: 16,
      right: 16,
      child: Column(
        children: [
          _buildZoomButton(Icons.add, 'Zoom In', () {
            setState(() {
              _zoom += 1;
              _mapController.move(_mapController.center, _zoom);
            });
          }, accentColor),
          const SizedBox(height: 8),
          _buildZoomButton(Icons.remove, 'Zoom Out', () {
            setState(() {
              _zoom -= 1;
              _mapController.move(_mapController.center, _zoom);
            });
          }, accentColor),
        ],
      ),
    );
  }

  Widget _buildZoomButton(
    IconData icon,
    String tooltip,
    VoidCallback onPressed,
    Color accentColor,
  ) {
    return Tooltip(
      message: tooltip,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: accentColor.withOpacity(0.3), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onPressed,
            child: Container(
              width: 44,
              height: 44,
              child: Icon(icon, color: accentColor, size: 20),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDistanceOverlay(Color accentColor) {
    return Positioned(
      bottom: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: accentColor.withOpacity(0.3), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.straighten, color: accentColor, size: 20),
            const SizedBox(width: 8),
            Text(
              'Distance:',
              style: TextStyle(
                color: Colors.grey[800],
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '${widget.routeDistance!.toStringAsFixed(2)} km',
              style: TextStyle(
                color: accentColor,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorOverlay(String error, Color accentColor) {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                error,
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay(Color accentColor) {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Loading map...',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorCard(String error, Color accentColor) {
    return Container(
      height: widget.height,
      width: widget.width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        border: Border.all(color: Colors.red.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.1),
            blurRadius: 16,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.map_outlined, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              error,
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
