/**
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:tag/core/theme/app_colors.dart';
import 'package:tag/feature/map/map_screen.dart';
import 'package:tag/feature/map/places_service.dart';

class LocationCoordinateField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final String mapTitle;
  final List<double>? initialCoordinates; // [lng, lat]
  final ValueChanged<List<double>?> onCoordinatesChanged;

  const LocationCoordinateField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    required this.mapTitle,
    required this.onCoordinatesChanged,
    this.initialCoordinates,
  });

  @override
  State<LocationCoordinateField> createState() =>
      _LocationCoordinateFieldState();
}

class _LocationCoordinateFieldState extends State<LocationCoordinateField> {
  final PlacesService _placesService = PlacesService();
  final FocusNode _focusNode = FocusNode();

  Timer? _debounce;
  List<PlaceSuggestion> _suggestions = [];
  bool _loading = false;
  List<double>? _coords; // [lng, lat]
  bool _suppressSearch = false;

  @override
  void initState() {
    super.initState();
    _coords = widget.initialCoordinates;
    widget.controller.addListener(_onTextChanged);
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        Future.delayed(const Duration(milliseconds: 180), () {
          if (mounted) setState(() => _suggestions = []);
        });
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    widget.controller.removeListener(_onTextChanged);
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    if (_suppressSearch) {
      _suppressSearch = false;
      return;
    }

    final text = widget.controller.text.trim();
    _debounce?.cancel();

    if (_coords != null) {
      _coords = null;
      widget.onCoordinatesChanged(null);
    }

    if (text.length < 2) {
      setState(() {
        _suggestions = [];
        _loading = false;
      });
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 400), () async {
      setState(() => _loading = true);
      try {
        final results = await _placesService.getSuggestions(text);
        if (!mounted) return;
        setState(() {
          _suggestions = results;
          _loading = false;
        });
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _suggestions = [];
          _loading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e'), backgroundColor: Colors.red),
        );
      }
    });
  }

  Future<void> _openMapPicker() async {
    FocusScope.of(context).unfocus();

    final result = await MapScreen.openPickLocation(
      context,
      title: widget.mapTitle,
      initialLng: _coords != null ? _coords![0] : null,
      initialLat: _coords != null ? _coords![1] : null,
    );

    if (result == null || !mounted) return;

    _suppressSearch = true;
    setState(() {
      _coords = result.coordinates;
      _suggestions = [];
      widget.controller.text = result.address ??
          '${result.lng.toStringAsFixed(7)}, ${result.lat.toStringAsFixed(7)}';
    });
    widget.onCoordinatesChanged(_coords);
  }

  Future<void> _selectSuggestion(PlaceSuggestion suggestion) async {
    FocusScope.of(context).unfocus();
    setState(() => _loading = true);

    try {
      final place = await _placesService.getPlaceLatLng(suggestion.placeId);
      if (!mounted) return;

      _suppressSearch = true;
      setState(() {
        _coords = place.coordinates;
        _suggestions = [];
        _loading = false;
        widget.controller.text = place.address ?? suggestion.description;
      });
      widget.onCoordinatesChanged(_coords);
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e'), backgroundColor: Colors.red),
      );
    }
  }

  String? _validator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Location is required';
    }
    if (_coords == null || _coords!.length != 2) {
      return 'Select a suggestion or pick on map';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: widget.label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF6B7280),
              letterSpacing: 0.2,
            ),
            children: const [
              TextSpan(
                text: ' *',
                style: TextStyle(
                  color: Color(0xFFEF4444),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          validator: _validator,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1E3A5F),
          ),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: const TextStyle(
              fontSize: 14,
              color: Color(0xFFB0B7C3),
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: InkWell(
              onTap: _openMapPicker,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Icon(widget.icon, size: 20, color: AppColors.primaryColor),
              ),
            ),
            suffixIcon: _loading
                ? const Padding(
              padding: EdgeInsets.all(14),
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
                : IconButton(
              tooltip: 'Open map',
              onPressed: _openMapPicker,
              icon: Icon(Icons.map_outlined, size: 20, color: Colors.grey[500]),
            ),
            filled: true,
            fillColor: AppColors.textFieldWhiteColor,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.primaryColor, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
            ),
            errorStyle: const TextStyle(fontSize: 11, color: Color(0xFFEF4444)),
          ),
        ),
        if (_coords != null) ...[
          const SizedBox(height: 4),
          Text(
            'lng, lat: ${_coords![0].toStringAsFixed(6)}, ${_coords![1].toStringAsFixed(6)}',
            style: TextStyle(
              fontSize: 11,
              color: AppColors.primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
        if (_suggestions.isNotEmpty) ...[
          const SizedBox(height: 6),
          Container(
            constraints: const BoxConstraints(maxHeight: 220),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE5E7EB)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: _suggestions.length,
              separatorBuilder: (_, __) =>
              const Divider(height: 1, color: Color(0xFFF3F4F6)),
              itemBuilder: (context, index) {
                final item = _suggestions[index];
                return ListTile(
                  dense: true,
                  leading: Icon(
                    Icons.place_outlined,
                    color: AppColors.primaryColor,
                    size: 20,
                  ),
                  title: Text(
                    item.description,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1E3A5F),
                    ),
                  ),
                  onTap: () => _selectSuggestion(item),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}*/












import 'dart:async';
import 'package:flutter/material.dart';
import 'package:tag/core/theme/app_colors.dart';
import 'package:tag/feature/map/map_screen.dart';
import 'package:tag/feature/map/places_service.dart';

class LocationCoordinateField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final String mapTitle;
  final List<double>? initialCoordinates; // [lng, lat]
  final ValueChanged<List<double>?> onCoordinatesChanged;

  const LocationCoordinateField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    required this.mapTitle,
    required this.onCoordinatesChanged,
    this.initialCoordinates,
  });

  @override
  State<LocationCoordinateField> createState() =>
      _LocationCoordinateFieldState();
}

class _LocationCoordinateFieldState extends State<LocationCoordinateField> {
  final PlacesService _placesService = PlacesService();
  final FocusNode _focusNode = FocusNode();

  Timer? _debounce;
  List<PlaceSuggestion> _suggestions = [];
  bool _loading = false;
  List<double>? _coords; // [lng, lat]
  bool _suppressSearch = false;

  @override
  void initState() {
    super.initState();
    _coords = widget.initialCoordinates;
    widget.controller.addListener(_onTextChanged);
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        Future.delayed(const Duration(milliseconds: 180), () {
          if (mounted) setState(() => _suggestions = []);
        });
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    widget.controller.removeListener(_onTextChanged);
    _focusNode.dispose();
    super.dispose();
  }

  List<double>? _parseCoordinates(String input) {
    final parts = input.split(',');
    if (parts.length != 2) return null;
    final lng = double.tryParse(parts[0].trim());
    final lat = double.tryParse(parts[1].trim());
    if (lng == null || lat == null) return null;
    if (lng < -180 || lng > 180 || lat < -90 || lat > 90) return null;
    return [lng, lat];
  }

  void _setCoords(List<double>? coords) {
    _coords = coords;
    widget.onCoordinatesChanged(coords);
  }

  void _onTextChanged() {
    if (_suppressSearch) {
      _suppressSearch = false;
      return;
    }

    final text = widget.controller.text.trim();
    _debounce?.cancel();

    // ✅ Typed/pasted "lng, lat" is valid — accept it
    final parsed = _parseCoordinates(text);
    if (parsed != null) {
      setState(() {
        _suggestions = [];
        _loading = false;
        _coords = parsed;
      });
      widget.onCoordinatesChanged(parsed);
      return;
    }

    // Address text changed → clear resolved coords until pick again
    if (_coords != null) {
      _setCoords(null);
      setState(() {});
    }

    if (text.length < 2) {
      setState(() {
        _suggestions = [];
        _loading = false;
      });
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 400), () async {
      setState(() => _loading = true);
      try {
        final results = await _placesService.getSuggestions(text);
        if (!mounted) return;
        setState(() {
          _suggestions = results;
          _loading = false;
        });
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _suggestions = [];
          _loading = false;
        });
      }
    });
  }

  Future<void> _openMapPicker() async {
    FocusScope.of(context).unfocus();

    final result = await MapScreen.openPickLocation(
      context,
      title: widget.mapTitle,
      initialLng: _coords != null ? _coords![0] : null,
      initialLat: _coords != null ? _coords![1] : null,
    );

    if (result == null || !mounted) return;

    _suppressSearch = true;
    setState(() {
      _coords = result.coordinates;
      _suggestions = [];
      widget.controller.text = result.address ??
          '${result.lng.toStringAsFixed(7)}, ${result.lat.toStringAsFixed(7)}';
    });
    widget.onCoordinatesChanged(_coords);
  }

  Future<void> _selectSuggestion(PlaceSuggestion suggestion) async {
    FocusScope.of(context).unfocus();
    setState(() => _loading = true);

    try {
      final place = await _placesService.getPlaceLatLng(suggestion.placeId);
      if (!mounted) return;

      _suppressSearch = true;
      setState(() {
        _coords = place.coordinates;
        _suggestions = [];
        _loading = false;
        widget.controller.text = place.address ?? suggestion.description;
      });
      widget.onCoordinatesChanged(_coords);
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e'), backgroundColor: Colors.red),
      );
    }
  }

  String? _validator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Location is required';
    }

    // Accept already-resolved coords OR typed lng,lat
    if (_coords != null && _coords!.length == 2) return null;
    if (_parseCoordinates(value.trim()) != null) return null;

    return 'Select a suggestion or pick on map';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: widget.label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF6B7280),
              letterSpacing: 0.2,
            ),
            children: const [
              TextSpan(
                text: ' *',
                style: TextStyle(
                  color: Color(0xFFEF4444),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          validator: _validator,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1E3A5F),
          ),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: const TextStyle(
              fontSize: 14,
              color: Color(0xFFB0B7C3),
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: IconButton(
              tooltip: 'Open map',
              onPressed: _openMapPicker,
              icon: Icon(widget.icon, size: 20, color: AppColors.primaryColor),
            ),
            suffixIcon: _loading
                ? const Padding(
              padding: EdgeInsets.all(14),
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
                : IconButton(
              tooltip: 'Open map',
              onPressed: _openMapPicker,
              icon: Icon(Icons.map_outlined, size: 20, color: Colors.grey[500]),
            ),
            filled: true,
            fillColor: AppColors.textFieldWhiteColor,
            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.primaryColor, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
            ),
            errorStyle: const TextStyle(fontSize: 11, color: Color(0xFFEF4444)),
          ),
        ),
        if (_coords != null) ...[
          const SizedBox(height: 4),
          Text(
            'lng, lat: ${_coords![0].toStringAsFixed(6)}, ${_coords![1].toStringAsFixed(6)}',
            style: TextStyle(
              fontSize: 11,
              color: AppColors.primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
        if (_suggestions.isNotEmpty) ...[
          const SizedBox(height: 6),
          Material(
            color: Colors.white,
            elevation: 2,
            borderRadius: BorderRadius.circular(10),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 220),
              child: ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: _suggestions.length,
                separatorBuilder: (_, __) =>
                const Divider(height: 1, color: Color(0xFFF3F4F6)),
                itemBuilder: (context, index) {
                  final item = _suggestions[index];
                  return ListTile(
                    dense: true,
                    leading: Icon(
                      Icons.place_outlined,
                      color: AppColors.primaryColor,
                      size: 20,
                    ),
                    title: Text(
                      item.description,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1E3A5F),
                      ),
                    ),
                    onTap: () => _selectSuggestion(item),
                  );
                },
              ),
            ),
          ),
        ],
      ],
    );
  }
}