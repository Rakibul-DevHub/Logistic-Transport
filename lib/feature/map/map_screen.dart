import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tag/core/theme/app_colors.dart';
import 'package:tag/core/theme/app_text_style.dart';
import 'package:tag/shared/components/Custom_Elevated_Button.dart';
import 'map_model.dart';
import 'places_service.dart';

class MapScreen extends StatefulWidget {
  final MapScreenArgs args;

  const MapScreen({super.key, required this.args});

  static Future<MapPickResult?> openPickLocation(
      BuildContext context, {
        String title = 'Pick Location',
        double? initialLat,
        double? initialLng,
      }) {
    return Navigator.push<MapPickResult>(
      context,
      MaterialPageRoute(
        builder: (_) => MapScreen(
          args: MapScreenArgs(
            mode: MapMode.pickLocation,
            title: title,
            initialLat: initialLat,
            initialLng: initialLng,
          ),
        ),
      ),
    );
  }

  static Future<void> openViewRoute(
      BuildContext context, {
        required List<double> pickupCoordinates,
        required List<double> deliveryCoordinates,
        String title = 'Route',
        String? pickupLabel,
        String? deliveryLabel,
      }) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MapScreen(
          args: MapScreenArgs(
            mode: MapMode.viewRoute,
            title: title,
            pickupCoordinates: pickupCoordinates,
            deliveryCoordinates: deliveryCoordinates,
            pickupLabel: pickupLabel,
            deliveryLabel: deliveryLabel,
          ),
        ),
      ),
    );
  }

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final PlacesService _placesService = PlacesService();

  GoogleMapController? _mapController;

  /// Camera center = selected location (NO tap-to-move)
  LatLng _center = const LatLng(40.7128, -74.0060);
  String? _address;
  bool _loadingAddress = false;
  bool _locating = false;
  bool _isMoving = false;

  /// Only enable MyLocation AFTER permission is granted (fixes log error)
  bool _hasLocationPermission = false;
  bool _permissionChecked = false;

  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  MapMode get _mode => widget.args.mode;

  @override
  void initState() {
    super.initState();
    if (widget.args.initialLat != null && widget.args.initialLng != null) {
      _center = LatLng(widget.args.initialLat!, widget.args.initialLng!);
    }
    _initMapFlow();
  }

  /// 1) Ask permission first → 2) then enable my-location / move camera
  Future<void> _initMapFlow() async {
    final granted = await _ensureLocationPermission(requestIfNeeded: true);
    if (!mounted) return;

    setState(() {
      _hasLocationPermission = granted;
      _permissionChecked = true;
    });

    switch (_mode) {
      case MapMode.pickLocation:
        _refreshAddress();
        if (granted &&
            (widget.args.initialLat == null || widget.args.initialLng == null)) {
          await _goToCurrentLocation(silent: true);
        }
        break;

      case MapMode.viewRoute:
        _setupRoute();
        break;

      case MapMode.browse:
        if (granted) await _goToCurrentLocation(silent: true);
        break;
    }
  }

  Future<bool> _ensureLocationPermission({bool requestIfNeeded = true}) async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted && requestIfNeeded) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enable location services')),
        );
      }
      return false;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied && requestIfNeeded) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      if (mounted && requestIfNeeded) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Location permission is required. Enable it in Settings.',
            ),
          ),
        );
      }
      return false;
    }

    return true;
  }

  void _setupRoute() {
    final pickup = widget.args.pickupCoordinates;
    final delivery = widget.args.deliveryCoordinates;
    if (pickup == null ||
        delivery == null ||
        pickup.length < 2 ||
        delivery.length < 2) {
      return;
    }

    final pickupLatLng = LatLng(pickup[1], pickup[0]);
    final deliveryLatLng = LatLng(delivery[1], delivery[0]);

    setState(() {
      _markers = {
        Marker(
          markerId: const MarkerId('pickup'),
          position: pickupLatLng,
          infoWindow: InfoWindow(title: widget.args.pickupLabel ?? 'Pickup'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        ),
        Marker(
          markerId: const MarkerId('delivery'),
          position: deliveryLatLng,
          infoWindow: InfoWindow(title: widget.args.deliveryLabel ?? 'Delivery'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      };

      _polylines = {
        Polyline(
          polylineId: const PolylineId('route'),
          points: [pickupLatLng, deliveryLatLng],
          color: AppColors.primaryColor,
          width: 4,
        ),
      };
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _mapController?.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(
              [pickupLatLng.latitude, deliveryLatLng.latitude]
                  .reduce((a, b) => a < b ? a : b),
              [pickupLatLng.longitude, deliveryLatLng.longitude]
                  .reduce((a, b) => a < b ? a : b),
            ),
            northeast: LatLng(
              [pickupLatLng.latitude, deliveryLatLng.latitude]
                  .reduce((a, b) => a > b ? a : b),
              [pickupLatLng.longitude, deliveryLatLng.longitude]
                  .reduce((a, b) => a > b ? a : b),
            ),
          ),
          80,
        ),
      );
    });
  }

  Future<void> _refreshAddress() async {
    if (_mode != MapMode.pickLocation) return;
    setState(() => _loadingAddress = true);
    try {
      final address = await _placesService.reverseGeocode(
        _center.latitude,
        _center.longitude,
      );
      if (!mounted) return;
      setState(() {
        _address = address;
        _loadingAddress = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _address = null;
        _loadingAddress = false;
      });
    }
  }

  Future<void> _goToCurrentLocation({bool silent = false}) async {
    setState(() => _locating = true);
    try {
      final granted = await _ensureLocationPermission(requestIfNeeded: !silent);
      if (!mounted) return;

      setState(() => _hasLocationPermission = granted);
      if (!granted) return;

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      final next = LatLng(pos.latitude, pos.longitude);
      setState(() => _center = next);

      await _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(next, 15),
      );
      await _refreshAddress();
    } catch (e) {
      if (!silent && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not get location: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  /// Map pans under fixed center pin → update selected coords
  void _onCameraMove(CameraPosition position) {
    if (_mode != MapMode.pickLocation) return;
    _center = position.target;
    if (!_isMoving) {
      setState(() => _isMoving = true);
    }
  }

  void _onCameraIdle() {
    if (_mode != MapMode.pickLocation) return;
    setState(() => _isMoving = false);
    _refreshAddress();
  }

  void _confirmPick() {
    Navigator.pop(
      context,
      MapPickResult(
        lat: _center.latitude,
        lng: _center.longitude,
        address: _address,
      ),
    );
  }

  CameraPosition get _initialCamera {
    if (_mode == MapMode.viewRoute &&
        widget.args.pickupCoordinates != null &&
        widget.args.pickupCoordinates!.length >= 2) {
      final p = widget.args.pickupCoordinates!;
      return CameraPosition(target: LatLng(p[1], p[0]), zoom: 10);
    }
    return CameraPosition(target: _center, zoom: 14);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          widget.args.title,
          style: AppTextStyle.SFProDisplay_Regular.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1E3A5F),
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close_rounded, color: Color(0xFF1E3A5F)),
        ),
        actions: [
          IconButton(
            onPressed: _locating ? null : () => _goToCurrentLocation(),
            icon: _locating
                ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : Icon(Icons.my_location, color: AppColors.primaryColor),
          ),
        ],
      ),
      body: !_permissionChecked
          ? const Center(child: CircularProgressIndicator())
          : Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _initialCamera,
            onMapCreated: (c) {
              _mapController = c;
              if (_mode == MapMode.viewRoute) _setupRoute();
            },
            // NO onTap — pin stays centered
            onCameraMove: _onCameraMove,
            onCameraIdle: _onCameraIdle,
            // FIX: only true AFTER permission granted
            myLocationEnabled: _hasLocationPermission,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            markers: _mode == MapMode.pickLocation ? {} : _markers,
            polylines: _polylines,
            mapType: MapType.normal,
          ),

          // Fixed center pin overlay
          if (_mode == MapMode.pickLocation)
            IgnorePointer(
              child: Center(
                child: AnimatedPadding(
                  duration: const Duration(milliseconds: 120),
                  padding: EdgeInsets.only(bottom: _isMoving ? 48 : 36),
                  child: Icon(
                    Icons.location_on,
                    size: 48,
                    color: AppColors.primaryColor,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          if (_mode == MapMode.pickLocation) _buildPickBottomPanel(),
          if (_mode == MapMode.viewRoute) _buildRouteBottomPanel(),
        ],
      ),
    );
  }

  Widget _buildPickBottomPanel() {
    return Positioned(
      left: 16,
      right: 16,
      bottom: 24,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Move the map to position the pin',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E3A5F),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _isMoving
                  ? 'Moving...'
                  : (_loadingAddress
                  ? 'Getting address...'
                  : (_address ?? 'Center the pin on your location')),
              style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 4),
            Text(
              '${_center.longitude.toStringAsFixed(7)}, ${_center.latitude.toStringAsFixed(7)}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryColor,
              ),
            ),
            const SizedBox(height: 14),
            CustomElevatedButton(
              onPressed: _isMoving ? null : _confirmPick,
              buttonText: 'Confirm Location',
              backgroundColor: const Color(0xFF1E3A5F),
              foregroundColor: Colors.white,
              height: 48,
              isFullWidth: true,
              hasShadow: false,
              borderRadius: BorderRadius.circular(28),
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteBottomPanel() {
    return Positioned(
      left: 16,
      right: 16,
      bottom: 24,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.args.pickupLabel ?? 'Pickup',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E3A5F),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.args.deliveryLabel ?? 'Delivery',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E3A5F),
              ),
            ),
            const SizedBox(height: 12),
            CustomElevatedButton(
              onPressed: () => Navigator.pop(context),
              buttonText: 'Close',
              backgroundColor: const Color(0xFF1E3A5F),
              foregroundColor: Colors.white,
              height: 48,
              isFullWidth: true,
              hasShadow: false,
              borderRadius: BorderRadius.circular(28),
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ],
        ),
      ),
    );
  }
}