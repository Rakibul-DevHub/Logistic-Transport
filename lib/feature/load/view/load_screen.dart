import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tag/core/theme/app_colors.dart';
import 'package:tag/feature/profile/view/manage_drivers/cubit/driver_screen_cubit.dart';

// Data Model for Load
class LoadModel {
  final String id;
  final String driverName;
  final LoadStatus status;
  final String pickupLocation;
  final DateTime pickupDateTime;
  final String deliveryLocation;
  final DateTime deliveryDateTime;
  final double rate;

  LoadModel({
    required this.id,
    required this.driverName,
    required this.status,
    required this.pickupLocation,
    required this.pickupDateTime,
    required this.deliveryLocation,
    required this.deliveryDateTime,
    required this.rate,
  });
}

enum LoadStatus { inProgress, completed, missingPOD }

// Sample Data
class LoadData {
  static List<LoadModel> getLoads() {
    return [
      LoadModel(
        id: '#LD-8821',
        driverName: 'John',
        status: LoadStatus.inProgress,
        pickupLocation: 'Chicago, IL',
        pickupDateTime: DateTime(2024, 10, 24, 8, 0),
        deliveryLocation: 'Dallas, TX',
        deliveryDateTime: DateTime(2024, 10, 26, 14, 30),
        rate: 1250.00,
      ),
      LoadModel(
        id: '#LD-8822',
        driverName: 'Hanna',
        status: LoadStatus.inProgress,
        pickupLocation: 'Chicago, IL',
        pickupDateTime: DateTime(2024, 10, 24, 8, 0),
        deliveryLocation: 'Dallas, TX',
        deliveryDateTime: DateTime(2024, 10, 26, 14, 30),
        rate: 1250.00,
      ),
      LoadModel(
        id: '#LD-8823',
        driverName: 'Dhon',
        status: LoadStatus.completed,
        pickupLocation: 'Chicago, IL',
        pickupDateTime: DateTime(2024, 10, 24, 8, 0),
        deliveryLocation: 'Dallas, TX',
        deliveryDateTime: DateTime(2024, 10, 26, 14, 30),
        rate: 1250.00,
      ),
      LoadModel(
        id: '#LD-8824',
        driverName: 'John',
        status: LoadStatus.missingPOD,
        pickupLocation: 'Los Angeles, CA',
        pickupDateTime: DateTime(2024, 10, 25, 9, 0),
        deliveryLocation: 'Phoenix, AZ',
        deliveryDateTime: DateTime(2024, 10, 26, 16, 0),
        rate: 980.00,
      ),
      LoadModel(
        id: '#LD-8825',
        driverName: 'Keli',
        status: LoadStatus.completed,
        pickupLocation: 'Miami, FL',
        pickupDateTime: DateTime(2024, 10, 23, 7, 30),
        deliveryLocation: 'Atlanta, GA',
        deliveryDateTime: DateTime(2024, 10, 24, 12, 0),
        rate: 750.00,
      ),
    ];
  }
}

class LoadScreen extends StatefulWidget {
  const LoadScreen({super.key});

  @override
  State<LoadScreen> createState() => _LoadScreenState();
}

class _LoadScreenState extends State<LoadScreen> {
  String _selectedFilter = 'All';
  String _selectedDriver = 'All Drivers';
  String _searchQuery = '';

  /// Search container expanded (field visible)
  bool _isSearchExpanded = false;

  /// Dropdown shown only when search is fully collapsed (avoids overflow)
  bool _showDropdown = true;

  late final List<LoadModel> _allLoads;
  late List<LoadModel> _filteredLoads;
  List<String> _driverList = const ['All Drivers'];

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final GlobalKey _driverFilterKey = GlobalKey();
  final DriverService _driverService = DriverService();

  final List<String> _filters = [
    'All',
    'In Progress',
    'Completed',
    'Missing POD',
  ];

  static const Duration _animDuration = Duration(milliseconds: 280);

  @override
  void initState() {
    super.initState();
    _allLoads = LoadData.getLoads();
    _filteredLoads = _allLoads;

    // Prefer cached API drivers; fall back to names from sample loads
    if (_driverService.hasCache) {
      _driverList = ['All Drivers', ..._driverService.cachedDriverNames];
    } else {
      final fromLoads =
          _allLoads.map((load) => load.driverName).toSet().toList()..sort();
      _driverList = ['All Drivers', ...fromLoads];
    }

    _loadDriverNamesFromService();
  }

  Future<void> _loadDriverNamesFromService() async {
    try {
      final names = await _driverService.getDriverNames(
        forceRefresh: !_driverService.hasCache,
        includeAll: true,
      );
      if (!mounted) return;
      setState(() {
        _driverList = names;
        if (!_driverList.contains(_selectedDriver)) {
          _selectedDriver = 'All Drivers';
          _updateFilteredLoads();
        }
      });
    } catch (_) {
      // Keep existing fallback list if drivers API fails
    }
  }

  void _updateFilteredLoads() {
    _filteredLoads = _filterLoads(
      filter: _selectedFilter,
      driver: _selectedDriver,
      searchQuery: _searchQuery,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  List<LoadModel> _filterLoads({
    required String filter,
    required String driver,
    required String searchQuery,
  }) {
    List<LoadModel> result = _allLoads;

    switch (filter) {
      case 'In Progress':
        result = result
            .where((load) => load.status == LoadStatus.inProgress)
            .toList();
        break;
      case 'Completed':
        result = result
            .where((load) => load.status == LoadStatus.completed)
            .toList();
        break;
      case 'Missing POD':
        result = result
            .where((load) => load.status == LoadStatus.missingPOD)
            .toList();
        break;
      default:
        break;
    }

    if (driver != 'All Drivers') {
      result = result.where((load) => load.driverName == driver).toList();
    }

    final query = searchQuery.trim().toLowerCase();
    if (query.isNotEmpty) {
      result = result
          .where((load) => load.driverName.toLowerCase().contains(query))
          .toList();
    }

    return result;
  }

  void _refreshList() {
    setState(() {
      _filteredLoads = _filterLoads(
        filter: _selectedFilter,
        driver: _selectedDriver,
        searchQuery: _searchQuery,
      );
    });
  }

  void _applyFilter(String filter) {
    _selectedFilter = filter;
    _refreshList();
  }

  void _applyDriverFilter(String driver) {
    _selectedDriver = driver;
    _refreshList();
  }

  void _onSearchChanged(String value) {
    _searchQuery = value;
    _refreshList();
  }

  Future<void> _openSearch() async {
    if (_isSearchExpanded) return;

    // 1) Hide dropdown first so row has full width
    setState(() => _showDropdown = false);

    await Future.delayed(const Duration(milliseconds: 16));
    if (!mounted) return;

    // 2) Expand search container to full width
    setState(() => _isSearchExpanded = true);

    await Future.delayed(_animDuration);
    if (!mounted) return;

    _searchFocusNode.requestFocus();
  }

  Future<void> _closeSearch() async {
    if (!_isSearchExpanded && _showDropdown) return;

    _searchFocusNode.unfocus();

    // 1) Collapse search container first (dropdown still hidden)
    setState(() {
      _isSearchExpanded = false;
      _searchController.clear();
      _searchQuery = '';
      _filteredLoads = _filterLoads(
        filter: _selectedFilter,
        driver: _selectedDriver,
        searchQuery: '',
      );
    });

    await Future.delayed(_animDuration);
    if (!mounted) return;

    // 2) Show dropdown again after collapse finishes
    setState(() => _showDropdown = true);
  }

  void _clearSearchText() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _filteredLoads = _filterLoads(
        filter: _selectedFilter,
        driver: _selectedDriver,
        searchQuery: '',
      );
    });
    _searchFocusNode.requestFocus();
  }

  /// Toggle search - opens if closed, closes if open
  Future<void> _toggleSearch() async {
    if (_isSearchExpanded) {
      await _closeSearch();
    } else {
      await _openSearch();
    }
  }

  Future<void> _openDriverDropdown() async {
    if (_isSearchExpanded || !_showDropdown) return;

    final media = MediaQuery.of(context);
    final fullMenuWidth = media.size.width - 32;

    final keyContext = _driverFilterKey.currentContext;
    double top = media.padding.top + 60 + 48 + 8;

    if (keyContext != null) {
      final box = keyContext.findRenderObject() as RenderBox?;
      if (box != null && box.hasSize) {
        final offset = box.localToGlobal(Offset.zero);
        top = offset.dy + box.size.height + 6;
      }
    }

    final selected = await showMenu<String>(
      context: context,
      color: Colors.white,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      constraints: BoxConstraints(
        minWidth: fullMenuWidth,
        maxWidth: fullMenuWidth,
      ),
      position: RelativeRect.fromLTRB(16, top, 16, 0),
      items: _driverList.map((driver) {
        final isSelected = driver == _selectedDriver;
        return PopupMenuItem<String>(
          value: driver,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              Icon(
                Icons.person_outline,
                size: 18,
                color: driver == 'All Drivers'
                    ? const Color(0xFF6B7280)
                    : const Color(0xFF3B82F6),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  driver,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: const Color(0xFF1E3A5F),
                  ),
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_rounded,
                  size: 18,
                  color: Color(0xFF1E3A5F),
                ),
            ],
          ),
        );
      }).toList(),
    );

    if (selected != null) {
      _applyDriverFilter(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Padding(
        padding: const EdgeInsets.only(top: 60.0, bottom: 20),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildSearchAndDropdownRow(),
            ),
            const SizedBox(height: 16),
            RepaintBoundary(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8ECF1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: _filters.map((filter) {
                    final isSelected = _selectedFilter == filter;

                    return Expanded(
                      child: GestureDetector(
                        onTap: () => _applyFilter(filter),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: isSelected
                                ? [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ]
                                : null,
                          ),
                          child: Text(
                            filter,
                            maxLines: 1,
                            softWrap: false,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isSelected
                                  ? const Color(0xFF1E3A5F)
                                  : const Color(0xFF6B7280),
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _filteredLoads.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.local_shipping_outlined,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No loads found',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _searchQuery.isNotEmpty
                          ? 'No driver matches "$_searchQuery"'
                          : 'Try changing your filters',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              )
                  : ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _filteredLoads.length,
                separatorBuilder: (_, __) =>
                const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  return RepaintBoundary(
                    child: LoadCard(load: _filteredLoads[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndDropdownRow() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;

        return SizedBox(
          height: 48,
          width: maxWidth,
          child: Row(
            children: [
              // OUTER: only this width animates (48 → full)
              AnimatedContainer(
                duration: _animDuration,
                curve: Curves.easeOutCubic,
                width: _isSearchExpanded ? maxWidth : 48,
                height: 48,
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8ECF1),
                  borderRadius: BorderRadius.circular(12),
                ),
                // INNER: always full-width layout; clipped by outer
                // OverflowBox prevents layout overflow while outer is still 48
                child: OverflowBox(
                  minWidth: maxWidth,
                  maxWidth: maxWidth,
                  alignment: Alignment.centerLeft,
                  child: SizedBox(
                    width: maxWidth,
                    height: 48,
                    child: _buildSearchFieldInsideContainer(),
                  ),
                ),
              ),

              // Dropdown on the RIGHT (only when search is collapsed)
              if (_showDropdown) ...[
                const SizedBox(width: 10),
                Expanded(child: _buildDriverFilterButton()),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchFieldInsideContainer() {
    return Row(
      children: [
        // Icon stays in a fixed 48 slot — toggles search on tap
        SizedBox(
          width: 48,
          height: 48,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _toggleSearch, // ← Now toggles open/close
              borderRadius: BorderRadius.circular(12),
              // Remove splash and highlight effects
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              child: Center(
                child: Icon(
                  Icons.search_rounded,
                  size: 22,
                  color: _isSearchExpanded
                      ? const Color(0xFF1E3A5F)
                      : const Color(0xFF6B7280),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: IgnorePointer(
            ignoring: !_isSearchExpanded,
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              onChanged: _onSearchChanged,
              textInputAction: TextInputAction.search,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1E3A5F),
              ),
              decoration: const InputDecoration(
                hintText: 'Search by driver name...',
                hintStyle: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF9CA3AF),
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ),
        if (_searchQuery.isNotEmpty)
          IconButton(
            tooltip: 'Clear',
            onPressed: _clearSearchText,
            icon: const Icon(
              Icons.close_rounded,
              size: 18,
              color: Color(0xFF6B7280),
            ),
            // Remove splash effect from clear button
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
        IconButton(
          tooltip: 'Close search',
          onPressed: _closeSearch,
          icon: Icon(
            CupertinoIcons.arrow_uturn_left,
            size: 20,
            color: const Color(0xFF1E3A5F),
          ),
          // Remove splash effect from close button
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
      ],
    );
  }

  Widget _buildDriverFilterButton() {
    return Material(
      key: _driverFilterKey,
      color: Colors.transparent,
      child: InkWell(
        onTap: _openDriverDropdown,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFE8ECF1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                Icons.person_outline,
                size: 18,
                color: _selectedDriver == 'All Drivers'
                    ? const Color(0xFF6B7280)
                    : const Color(0xFF3B82F6),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _selectedDriver,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1E3A5F),
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_drop_down,
                color: Color(0xFF6B7280),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LoadCard extends StatelessWidget {
  final LoadModel load;

  const LoadCard({super.key, required this.load});

  String _getStatusText() {
    switch (load.status) {
      case LoadStatus.inProgress:
        return 'IN PROGRESS';
      case LoadStatus.completed:
        return 'Completed';
      case LoadStatus.missingPOD:
        return 'Missing POD';
    }
  }

  Color _getStatusBgColor() {
    switch (load.status) {
      case LoadStatus.inProgress:
        return const Color(0xFFEFF6FF);
      case LoadStatus.completed:
        return const Color(0xFFF0FDF4);
      case LoadStatus.missingPOD:
        return const Color(0xFFFFF7ED);
    }
  }

  Color _getStatusTextColor() {
    switch (load.status) {
      case LoadStatus.inProgress:
        return const Color(0xFF2563EB);
      case LoadStatus.completed:
        return const Color(0xFF16A34A);
      case LoadStatus.missingPOD:
        return const Color(0xFFEA580C);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, HH:mm');

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                load.id,
                style: const TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _getStatusBgColor(),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _getStatusText(),
                  style: TextStyle(
                    color: _getStatusTextColor(),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.person, size: 20, color: Color(0xFF6B7280)),
              const SizedBox(width: 8),
              Text(
                load.driverName,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      color: Color(0xFF3B82F6),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Container(
                    width: 2,
                    height: 40,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: CustomPaint(
                      painter: DottedLinePainter(
                        color: const Color(0xFFD1D5DB),
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF3B82F6),
                        width: 2,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            load.pickupLocation,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFF6B7280),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          dateFormat.format(load.pickupDateTime),
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            load.deliveryLocation,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFF6B7280),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          dateFormat.format(load.deliveryDateTime),
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(height: 1, color: const Color(0xFFF3F4F6)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'RATE',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${load.rate.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E3A5F),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {},
                    borderRadius: BorderRadius.circular(12),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                      child: Row(
                        children: [
                          Text(
                            'Details',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            Icons.chevron_right,
                            color: Colors.white,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class DottedLinePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  DottedLinePainter({required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    const dashWidth = 3.0;
    const dashSpace = 3.0;
    double startY = 0;

    while (startY < size.height) {
      canvas.drawLine(
        Offset(size.width / 2, startY),
        Offset(size.width / 2, startY + dashWidth),
        paint,
      );
      startY += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}