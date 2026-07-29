import 'dart:async';
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


  const MapScreen({
    super.key,
    required this.args,
  });

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
  static const double _liveRouteUpdateDistanceMeters = 20;

  final PlacesService _placesService = PlacesService();

  GoogleMapController? _mapController;
  StreamSubscription<Position>? _positionSubscription;

  LatLng _center = const LatLng(40.7128, -74.0060);

  String? _address;

  bool _loadingAddress = false;
  bool _locating = false;
  bool _isMoving = false;
  bool _permissionChecked = false;
  bool _hasLocationPermission = false;

  bool _routeLoading = false;
  bool _routeLoaded = false;
  bool _liveRouteUpdating = false;

  /// Ignores stale reverse-geocode responses after the user moves the map.
  int _addressRequestId = 0;

  /// Prevents overlapping live Directions calls.
  int _liveRouteRequestId = 0;

  Position? _lastRouteUpdatePosition;

  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  List<LatLng> _routePoints = [];

  MapMode get _mode => widget.args.mode;

  @override
  void initState() {
    super.initState();

    if (widget.args.initialLat != null &&
        widget.args.initialLng != null) {
      _center = LatLng(
        widget.args.initialLat!,
        widget.args.initialLng!,
      );
    }

    _initMapFlow();
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _initMapFlow() async {
    final granted = await _ensureLocationPermission(
      requestIfNeeded: true,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _hasLocationPermission = granted;
      _permissionChecked = true;
    });

    switch (_mode) {
      case MapMode.pickLocation:
        await _refreshAddress();

        if (granted &&
            (widget.args.initialLat == null ||
                widget.args.initialLng == null)) {
          await _goToCurrentLocation(silent: true);
        }
        break;

      case MapMode.viewRoute:
        await _setupRoute();
        if (granted) {
          await _startLiveRouteTracking();
        }
        break;

      case MapMode.browse:
        if (granted) {
          await _goToCurrentLocation(silent: true);
        }
        break;
    }
  }

  Future<bool> _ensureLocationPermission({
    bool requestIfNeeded = true,
  }) async {
    final serviceEnabled =
    await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      if (mounted && requestIfNeeded) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enable GPS / location services'),
          ),
        );
      }

      return false;
    }

    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied &&
        requestIfNeeded) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      if (mounted && requestIfNeeded) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Allow location permission to show your position on map',
            ),
          ),
        );
      }

      return false;
    }

    return true;
  }

  Future<void> _setupRoute() async {
    if (_routeLoading || _routeLoaded) {
      return;
    }

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

    _routeLoading = true;

    if (mounted) {
      setState(() {
        _markers = {
          Marker(
            markerId: const MarkerId('pickup'),
            position: pickupLatLng,
            infoWindow: InfoWindow(
              title: widget.args.pickupLabel ?? 'Pickup',
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueAzure,
            ),
          ),
          Marker(
            markerId: const MarkerId('delivery'),
            position: deliveryLatLng,
            infoWindow: InfoWindow(
              title: widget.args.deliveryLabel ?? 'Delivery',
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueRed,
            ),
          ),
        };

        _polylines = {};
      });
    }

    try {
      final routeCoordinates = await _placesService.getDrivingRoute(
        pickupCoordinates: pickup,
        deliveryCoordinates: delivery,
      );

      if (!mounted) {
        return;
      }

      final points = routeCoordinates
          .where((coordinate) => coordinate.length >= 2)
          .map(
            (coordinate) => LatLng(
          coordinate[1],
          coordinate[0],
        ),
      )
          .toList();

      if (points.length < 2) {
        throw Exception('No valid road path was returned');
      }

      setState(() {
        _routePoints = points;
        _routeLoaded = true;
        _routeLoading = false;
        _polylines = {
          Polyline(
            polylineId: const PolylineId('driving_route'),
            points: points,
            color: AppColors.primaryColor,
            width: 5,
            geodesic: false,
            jointType: JointType.round,
            startCap: Cap.roundCap,
            endCap: Cap.roundCap,
          ),
        };
      });

      await _fitRouteOnMap(points);
    } catch (error) {
      if (!mounted) {
        return;
      }

      _routeLoaded = false;

      setState(() {
        _routeLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not load road route: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _startLiveRouteTracking() async {
    await _positionSubscription?.cancel();

    try {
      final current = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      if (!mounted) return;

      _lastRouteUpdatePosition = current;

      // First live update from current GPS → delivery
      await _updateLiveRouteFromPosition(current, force: true);
    } catch (_) {
      // Keep static pickup→delivery route if GPS fails
    }

    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: _liveRouteUpdateDistanceMeters.round(),
      ),
    ).listen(
          (position) {
        _onLivePositionChanged(position);
      },
      onError: (_) {},
    );
  }

  Future<void> _onLivePositionChanged(Position position) async {
    if (_mode != MapMode.viewRoute || !mounted) return;

    final last = _lastRouteUpdatePosition;

    if (last != null) {
      final movedMeters = Geolocator.distanceBetween(
        last.latitude,
        last.longitude,
        position.latitude,
        position.longitude,
      );

      if (movedMeters < _liveRouteUpdateDistanceMeters) {
        return;
      }
    }

    _lastRouteUpdatePosition = position;
    await _updateLiveRouteFromPosition(position);
  }

  /// Recalculate road path: current user position → delivery
  Future<void> _updateLiveRouteFromPosition(
      Position position, {
        bool force = false,
      }) async {
    final delivery = widget.args.deliveryCoordinates;
    final pickup = widget.args.pickupCoordinates;

    if (delivery == null || delivery.length < 2) return;
    if (_liveRouteUpdating && !force) return;

    final requestId = ++_liveRouteRequestId;

    setState(() {
      _liveRouteUpdating = true;
    });

    try {
      final origin = <double>[position.longitude, position.latitude];

      final routeCoordinates = await _placesService.getDrivingRoute(
        pickupCoordinates: origin, // treated as route origin [lng, lat]
        deliveryCoordinates: delivery,
      );

      if (!mounted || requestId != _liveRouteRequestId) return;

      final points = routeCoordinates
          .where((coordinate) => coordinate.length >= 2)
          .map(
            (coordinate) => LatLng(
          coordinate[1],
          coordinate[0],
        ),
      )
          .toList();

      if (points.length < 2) {
        throw Exception('No valid live road path');
      }

      final pickupLatLng = pickup != null && pickup.length >= 2
          ? LatLng(pickup[1], pickup[0])
          : null;

      final deliveryLatLng = LatLng(delivery[1], delivery[0]);
      final userLatLng = LatLng(position.latitude, position.longitude);

      setState(() {
        _routePoints = points;
        _liveRouteUpdating = false;

        _markers = {
          if (pickupLatLng != null)
            Marker(
              markerId: const MarkerId('pickup'),
              position: pickupLatLng,
              infoWindow: InfoWindow(
                title: widget.args.pickupLabel ?? 'Pickup',
              ),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueAzure,
              ),
            ),
          Marker(
            markerId: const MarkerId('delivery'),
            position: deliveryLatLng,
            infoWindow: InfoWindow(
              title: widget.args.deliveryLabel ?? 'Delivery',
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueRed,
            ),
          ),
          Marker(
            markerId: const MarkerId('you'),
            position: userLatLng,
            infoWindow: const InfoWindow(title: 'You'),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueGreen,
            ),
          ),
        };

        _polylines = {
          Polyline(
            polylineId: const PolylineId('driving_route'),
            points: points,
            color: AppColors.primaryColor,
            width: 5,
            geodesic: false,
            jointType: JointType.round,
            startCap: Cap.roundCap,
            endCap: Cap.roundCap,
          ),
        };
      });

      // Keep user + remaining path in view (light follow)
      await _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(userLatLng, 15),
      );
    } catch (_) {
      if (!mounted || requestId != _liveRouteRequestId) return;

      setState(() {
        _liveRouteUpdating = false;
      });
    }
  }

  Future<void> _fitRouteOnMap(List<LatLng> points) async {
    if (_mapController == null || points.isEmpty) {
      return;
    }

    if (points.length == 1) {
      await _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(points.first, 15),
      );
      return;
    }

    var minimumLatitude = points.first.latitude;
    var maximumLatitude = points.first.latitude;
    var minimumLongitude = points.first.longitude;
    var maximumLongitude = points.first.longitude;

    for (final point in points.skip(1)) {
      if (point.latitude < minimumLatitude) {
        minimumLatitude = point.latitude;
      }
      if (point.latitude > maximumLatitude) {
        maximumLatitude = point.latitude;
      }
      if (point.longitude < minimumLongitude) {
        minimumLongitude = point.longitude;
      }
      if (point.longitude > maximumLongitude) {
        maximumLongitude = point.longitude;
      }
    }

    if (minimumLatitude == maximumLatitude &&
        minimumLongitude == maximumLongitude) {
      await _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(points.first, 15),
      );
      return;
    }

    try {
      await _mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(minimumLatitude, minimumLongitude),
            northeast: LatLng(maximumLatitude, maximumLongitude),
          ),
          90,
        ),
      );
    } catch (_) {
      await _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(points.first, 13),
      );
    }
  }

  Future<void> _refreshAddress() async {
    if (_mode != MapMode.pickLocation) {
      return;
    }

    final requestId = ++_addressRequestId;
    final lat = _center.latitude;
    final lng = _center.longitude;

    setState(() {
      _loadingAddress = true;
    });

    try {
      final address = await _placesService.reverseGeocode(lat, lng);

      if (!mounted || requestId != _addressRequestId) {
        return;
      }

      setState(() {
        _address = address;
        _loadingAddress = false;
      });
    } catch (_) {
      if (!mounted || requestId != _addressRequestId) {
        return;
      }

      setState(() {
        _address = null;
        _loadingAddress = false;
      });
    }
  }

  Future<void> _goToCurrentLocation({
    bool silent = false,
  }) async {
    setState(() {
      _locating = true;
    });

    try {
      final granted = await _ensureLocationPermission(
        requestIfNeeded: !silent,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _hasLocationPermission = granted;
      });

      if (!granted) {
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      final next = LatLng(
        position.latitude,
        position.longitude,
      );

      setState(() {
        _center = next;
      });

      await _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(next, 15),
      );

      if (_mode == MapMode.pickLocation) {
        await _refreshAddress();
      }

      if (_mode == MapMode.viewRoute) {
        await _updateLiveRouteFromPosition(position, force: true);
      }
    } catch (error) {
      if (!silent && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not get location: $error'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _locating = false;
        });
      }
    }
  }

  void _onCameraMove(CameraPosition position) {
    if (_mode != MapMode.pickLocation) {
      return;
    }

    _center = position.target;

    if (!_isMoving) {
      setState(() {
        _isMoving = true;
      });
    }
  }

  void _onCameraIdle() {
    if (_mode != MapMode.pickLocation) {
      return;
    }

    setState(() {
      _isMoving = false;
    });

    Future.delayed(const Duration(milliseconds: 280), () {
      if (!mounted || _isMoving) {
        return;
      }
      _refreshAddress();
    });
  }

  void _confirmPick() {
    if (_loadingAddress) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please wait while getting the address'),
        ),
      );
      return;
    }

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
      final pickup = widget.args.pickupCoordinates!;

      return CameraPosition(
        target: LatLng(pickup[1], pickup[0]),
        zoom: 10,
      );
    }

    return CameraPosition(
      target: _center,
      zoom: 14,
    );
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
          icon: const Icon(
            Icons.close_rounded,
            color: Color(0xFF1E3A5F),
          ),
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
                : Icon(
              Icons.my_location,
              color: AppColors.primaryColor,
            ),
          ),
        ],
      ),
      body: !_permissionChecked
          ? const Center(child: CircularProgressIndicator())
          : Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _initialCamera,
            onMapCreated: (controller) {
              _mapController = controller;

              if (_mode == MapMode.viewRoute) {
                if (_routePoints.isNotEmpty) {
                  _fitRouteOnMap(_routePoints);
                } else {
                  _setupRoute();
                }
              }
            },
            onCameraMove: _onCameraMove,
            onCameraIdle: _onCameraIdle,
            myLocationEnabled: _hasLocationPermission,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            markers: _mode == MapMode.pickLocation ? {} : _markers,
            polylines: _polylines,
            mapType: MapType.normal,
          ),
          if (_mode == MapMode.pickLocation)
            IgnorePointer(
              child: Align(
                alignment: Alignment.center,
                child: AnimatedSlide(
                  duration: const Duration(milliseconds: 100),
                  offset: Offset(0, _isMoving ? -0.12 : 0),
                  child: Transform.translate(
                    offset: const Offset(0, -24),
                    child: Icon(
                      Icons.location_on,
                      size: 48,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
              ),
            ),
          if (_mode == MapMode.viewRoute &&
              (_routeLoading || _liveRouteUpdating))
            Positioned(
              top: 16,
              left: 0,
              right: 0,
              child: Center(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          _liveRouteUpdating
                              ? 'Updating route...'
                              : 'Loading road route...',
                        ),
                      ],
                    ),
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
                  : _loadingAddress
                  ? 'Getting address...'
                  : _address ?? 'Center the pin on your location',
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${_center.longitude.toStringAsFixed(7)}, '
                  '${_center.latitude.toStringAsFixed(7)}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryColor,
              ),
            ),
            const SizedBox(height: 14),
            CustomElevatedButton(
              onPressed:
              _isMoving || _loadingAddress ? null : _confirmPick,
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
            const SizedBox(height: 8),
            const Text(
              'Live route: updates every 20m from your position',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF6B7280),
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
