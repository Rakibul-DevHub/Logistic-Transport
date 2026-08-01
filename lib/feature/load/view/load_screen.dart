import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:tag/core/network/auth_session.dart';
import 'package:tag/core/network/secure_storage_service.dart';
import 'package:tag/core/theme/app_colors.dart';
import 'package:tag/feature/bill_of_loading/model/add_load_data.dart';
import 'package:tag/feature/load/cubit/load_list_cubit.dart';
import 'package:tag/feature/load/model/load_list_data.dart';
import 'package:tag/feature/load/view/load_details_screen.dart';
import 'package:tag/feature/profile/view/manage_drivers/cubit/driver_screen_cubit.dart';
import 'package:tag/feature/profile/view/manage_drivers/model/driver_data.dart';
import 'package:tag/shared/widget/immersive_safe_area.dart';

class LoadScreen extends StatefulWidget {
  const LoadScreen({super.key});

  @override
  State<LoadScreen> createState() => _LoadScreenState();
}

class _LoadScreenState extends State<LoadScreen> {
  String _selectedFilter = 'All';
  String _selectedScope = 'All';
  String _searchQuery = '';
  String _listType = LoadListType.all;

  bool _isSearchExpanded = false;
  bool _showDropdown = true;

  /// true = owner → show search + scope dropdown
  bool _isParentDriver = false;
  bool _roleLoaded = false;

  List<String> _scopeList = const ['All', 'My Loads', 'All Drivers'];
  final Map<String, String> _driverNamesById = {};
  String? _currentUserId;
  String? _currentUserName;

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final GlobalKey _driverFilterKey = GlobalKey();
  final DriverService _driverService = DriverService();
  final ScrollController _scrollController = ScrollController();
  late final LoadListCubit _loadListCubit;

  final List<String> _filters = [
    'All',
    'In Progress',
    'Completed',
    'Missing POD',
  ];

  static const Duration _animDuration = Duration(milliseconds: 280);

  static const String _scopeAll = 'All';
  static const String _scopeMyLoads = 'My Loads';
  static const String _scopeAllDrivers = 'All Drivers';

  bool get _showOwnerFilters => _roleLoaded && _isParentDriver == true;

  bool get _isDriverScope {
    return _selectedScope != _scopeAll &&
        _selectedScope != _scopeMyLoads &&
        _selectedScope != _scopeAllDrivers;
  }

  @override
  void initState() {
    super.initState();
    _loadListCubit = LoadListCubit();
    _scrollController.addListener(_onScroll);
    _resolveParentDriverFlag();
  }

  Future<void> _resolveParentDriverFlag() async {
    bool isParent;
    if (AuthSession.isParentDriver != null) {
      isParent = AuthSession.isParentDriver!;
    } else {
      isParent = await SecureStorageService.instance.getIsParentDriver();
      AuthSession.isParentDriver = isParent;
      AuthSession.isOwner = isParent;
    }

    if (!mounted) return;
    setState(() {
      _isParentDriver = isParent;
      _roleLoaded = true;
      _listType = isParent ? LoadListType.all : LoadListType.self;
      _selectedScope = isParent ? _scopeAll : _scopeMyLoads;
    });

    await _resolveCurrentUser();
    _loadListCubit.fetchLoads(type: _listType);

    if (isParent) {
      if (_driverService.hasCache) {
        _applyDriverCache(_driverService.cachedDrivers);
      }
      _loadDriverNamesFromService();
    }
  }

  Future<void> _resolveCurrentUser() async {
    final storage = SecureStorageService.instance;
    final id = await storage.getUserId();
    final name = await storage.getUserName();
    if (!mounted) return;
    setState(() {
      _currentUserId = id;
      _currentUserName = name;
      if (id != null &&
          id.isNotEmpty &&
          name != null &&
          name.trim().isNotEmpty) {
        _driverNamesById[id] = name.trim();
      }
    });
  }

  void _applyDriverCache(List<Driver> drivers) {
    for (final driver in drivers) {
      final id = driver.id.trim();
      final name = driver.name.trim();
      if (id.isNotEmpty && name.isNotEmpty) {
        _driverNamesById[id] = name;
      }
    }
    setState(() {
      _scopeList = [
        _scopeAll,
        _scopeMyLoads,
        _scopeAllDrivers,
        ..._driverService.cachedDriverNames,
      ];
    });
  }

  Future<void> _loadDriverNamesFromService() async {
    try {
      final drivers = await _driverService.fetchDrivers(
        forceRefresh: !_driverService.hasCache,
      );
      if (!mounted) return;
      _applyDriverCache(drivers);
      if (!_scopeList.contains(_selectedScope)) {
        setState(() => _selectedScope = _scopeAll);
      }
    } catch (_) {}
  }

  String _driverNameFor(AddLoadData load) {
    return LoadDisplayHelper.driverName(
      load,
      namesByUserId: _driverNamesById,
      currentUserId: _currentUserId,
      currentUserName: _currentUserName,
    );
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 200) {
      _loadListCubit.loadMore();
    }
  }

  List<AddLoadData> _applyLocalFilters(List<AddLoadData> loads) {
    var result = loads;

    if (_selectedFilter != 'All') {
      result = result
          .where((load) =>
      LoadDisplayHelper.filterBucket(load) == _selectedFilter)
          .toList();
    }

    final query = _searchQuery.trim().toLowerCase();
    if (query.isNotEmpty) {
      result = result.where((load) {
        final driver = _driverNameFor(load).toLowerCase();
        final loadId = (load.loadId ?? '').toLowerCase();
        return driver.contains(query) || loadId.contains(query);
      }).toList();
    }

    if (_isDriverScope) {
      final driverFilter = _selectedScope.toLowerCase();
      result = result.where((load) {
        return _driverNameFor(load).toLowerCase() == driverFilter;
      }).toList();
    }

    return result;
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _loadListCubit.close();
    super.dispose();
  }

  void _applyFilter(String filter) {
    setState(() => _selectedFilter = filter);
  }

  void _applyScopeFilter(String scope) {
    String nextType;
    if (scope == _scopeAll) {
      nextType = LoadListType.all;
    } else if (scope == _scopeMyLoads) {
      nextType = LoadListType.self;
    } else {
      // All Drivers + any single driver → assigned API
      nextType = LoadListType.assigned;
    }

    final shouldRefetch = nextType != _listType;

    setState(() {
      _selectedScope = scope;
      _listType = nextType;
    });

    if (shouldRefetch) {
      _loadListCubit.fetchLoads(type: nextType);
    }
  }

  void _onSearchChanged(String value) {
    setState(() => _searchQuery = value);
  }

  Future<void> _openSearch() async {
    if (_isSearchExpanded) return;
    setState(() => _showDropdown = false);
    await Future.delayed(const Duration(milliseconds: 16));
    if (!mounted) return;
    setState(() => _isSearchExpanded = true);
    await Future.delayed(_animDuration);
    if (!mounted) return;
    _searchFocusNode.requestFocus();
  }

  Future<void> _closeSearch() async {
    if (!_isSearchExpanded && _showDropdown) return;
    _searchFocusNode.unfocus();
    setState(() {
      _isSearchExpanded = false;
      _searchController.clear();
      _searchQuery = '';
    });
    await Future.delayed(_animDuration);
    if (!mounted) return;
    setState(() => _showDropdown = true);
  }

  void _clearSearchText() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
    });
    _searchFocusNode.requestFocus();
  }

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

    final specialScopes = [_scopeAll, _scopeMyLoads, _scopeAllDrivers];
    final driverNames = _scopeList
        .where((s) => !specialScopes.contains(s))
        .toList();

    PopupMenuItem<String> scopeItem(String scope, {required bool isSpecial}) {
      final isSelected = scope == _selectedScope;
      return PopupMenuItem<String>(
        value: scope,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(
          children: [
            Icon(
              scope == _scopeMyLoads
                  ? Icons.inventory_2_outlined
                  : Icons.person_outline,
              size: 18,
              color: isSpecial
                  ? const Color(0xFF6B7280)
                  : const Color(0xFF3B82F6),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                scope,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
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
    }

    final menuItems = <PopupMenuEntry<String>>[
      ...specialScopes.map((s) => scopeItem(s, isSpecial: true)),
      if (driverNames.isNotEmpty) PopupMenuDivider(height: 8),
      ...driverNames.map((s) => scopeItem(s, isSpecial: false)),
    ];

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
      items: menuItems,
    );

    if (selected != null) {
      _applyScopeFilter(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final topInset = immersiveSafeTopInset(context);

    return BlocProvider.value(
      value: _loadListCubit,
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: Padding(
          padding: EdgeInsets.only(top: topInset + 12),
          child: Column(
            children: [
              if (_showOwnerFilters) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildSearchAndDropdownRow(),
                ),
                const SizedBox(height: 6),
              ],
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
                                  color: Colors.black.withValues(
                                    alpha: 0.05,
                                  ),
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
              const SizedBox(height: 8),
              Expanded(
                child: BlocBuilder<LoadListCubit, LoadListState>(
                  builder: (context, state) {
                    if (state is LoadListLoading || state is LoadListInitial) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryColor,
                        ),
                      );
                    }

                    if (state is LoadListFailure) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                state.errorMessage,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextButton(
                                onPressed: () =>
                                    _loadListCubit.fetchLoads(type: _listType),
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    if (state is! LoadListSuccess) {
                      return const SizedBox.shrink();
                    }

                    final filtered = _applyLocalFilters(state.loads);

                    return RefreshIndicator(
                      color: AppColors.primaryColor,
                      onRefresh: () =>
                          _loadListCubit.fetchLoads(type: _listType),
                      child: filtered.isEmpty
                          ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(
                            height:
                            MediaQuery.of(context).size.height * 0.4,
                            child: Center(
                              child: Column(
                                mainAxisAlignment:
                                MainAxisAlignment.center,
                                children: [
                                  SvgPicture.asset('assets/icons/empty.svg'),
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
                                        ? 'No matches for "$_searchQuery"'
                                        : 'Try changing your filters',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      )
                          : ListView.separated(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 0,
                        ).copyWith(
                          bottom: 20,
                        ),
                        itemCount:
                        filtered.length + (state.isLoadingMore ? 1 : 0),
                        separatorBuilder: (_, __) =>
                        const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          if (index >= filtered.length) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Center(
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                            );
                          }
                          return RepaintBoundary(
                            child: LoadCard(
                              load: filtered[index],
                              driverName: _driverNameFor(filtered[index]),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
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
              onTap: _toggleSearch,
              borderRadius: BorderRadius.circular(12),
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
                hintText: 'Search by driver or load ID...',
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
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
        IconButton(
          tooltip: 'Close search',
          onPressed: _closeSearch,
          icon: const Icon(
            CupertinoIcons.arrow_uturn_left,
            size: 20,
            color: Color(0xFF1E3A5F),
          ),
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
      ],
    );
  }

  Widget _buildDriverFilterButton() {
    return Material(
      key: _driverFilterKey,
      color: const Color(0xFFE8ECF1),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: _openDriverDropdown,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Icon(
                _selectedScope == _scopeMyLoads
                    ? Icons.inventory_2_outlined
                    : Icons.person_outline,
                size: 18,
                color: _isDriverScope
                    ? const Color(0xFF3B82F6)
                    : const Color(0xFF6B7280),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _selectedScope,
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
  final AddLoadData load;
  final String driverName;

  const LoadCard({
    super.key,
    required this.load,
    required this.driverName,
  });

  String _getStatusText() => LoadDisplayHelper.statusLabel(load).toUpperCase();

  Color _getStatusBgColor() {
    final label = LoadDisplayHelper.statusLabel(load);
    switch (label) {
      case 'Completed':
        return const Color(0xFFF0FDF4);
      case 'Missing POD':
        return const Color(0xFFFFF7ED);
      case 'In Progress':
        return const Color(0xFFEFF6FF);
      default:
        return const Color(0xFFFFF7ED);
    }
  }

  Color _getStatusTextColor() {
    return LoadDisplayHelper.statusColor(load);
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, HH:mm');
    final pickupDate = LoadDisplayHelper.pickupDate(load);
    final deliveryDate = LoadDisplayHelper.deliveryDate(load);
    final pickupText =
        pickupDate != null ? dateFormat.format(pickupDate) : '—';

    final status = (load.status ?? '').toLowerCase().trim();
    final isCompleted = status == 'completed' || status == 'delivered';
    // Delivery row: show delivery date when completed (or when API sent one).
    final deliveryText = isCompleted || deliveryDate != null
        ? (deliveryDate != null ? dateFormat.format(deliveryDate) : '—')
        : '—';
    final rate = load.rate?.toDouble() ?? 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Load Number + Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                LoadDisplayHelper.loadNumber(load),
                style: const TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _getStatusBgColor(),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  _getStatusText(),
                  style: TextStyle(
                    color: _getStatusTextColor(),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Row 2: Driver Name
          Row(
            children: [
              const Icon(Icons.person, size: 16, color: Color(0xFF6B7280)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  driverName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // Company Name
          Padding(
            padding: const EdgeInsets.only(left: 22),
            child: Text(
              LoadDisplayHelper.company(load),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF6B7280),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 16),

          // Route: Pickup -> Delivery
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Color(0xFF3B82F6),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Container(
                    width: 2,
                    height: 28,
                    margin: const EdgeInsets.symmetric(vertical: 3),
                    child: CustomPaint(
                      painter: DottedLinePainter(
                        color: const Color(0xFFD1D5DB),
                        strokeWidth: 1.5,
                      ),
                    ),
                  ),
                  Container(
                    width: 10,
                    height: 10,
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
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Pickup
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            LoadDisplayHelper.pickupAddress(load),
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF6B7280),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          pickupText,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Delivery
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            LoadDisplayHelper.deliveryAddress(load),
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF6B7280),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          deliveryText,
                          style: const TextStyle(
                            fontSize: 13,
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
          const SizedBox(height: 16),

          // Divider
          Container(height: 1, color: const Color(0xFFF3F4F6)),
          const SizedBox(height: 14),

          // Bottom: Rate + Details Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'RATE',
                    style: TextStyle(
                      fontSize: 10,
                      color: Color(0xFF6B7280),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '\$${rate.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E3A5F),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LoadDetailsScreen(load: load),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          Text(
                            'Details',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 2),
                          Icon(
                            Icons.chevron_right,
                            color: Colors.white,
                            size: 18,
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

  const DottedLinePainter({
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    const double dashWidth = 3.0;
    const double dashSpace = 3.0;
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