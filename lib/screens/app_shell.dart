import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

import '../data/agribridge_repository.dart';
import '../localization/app_strings.dart';
import '../theme/app_theme.dart';
import '../widgets/demo_widgets.dart';

const screenTitles = [
  'Launch screen',
  'Choose language',
  'Mobile number login',
  'OTP verification',
  'Choose your role',
  'Farmer dashboard',
  'Weather information',
  'Market prices',
  'Seeds & fertilizer',
  'Price comparison',
  'Machinery search',
  'Equipment results',
  'Equipment details',
  'Find a mechanic',
  'Nearby mechanics',
  'Mechanic profile',
  'Create group booking',
  'Suggested route & cost',
  'Used equipment search',
  'Equipment listings',
  'Listing details',
  'Retailer dashboard',
  'Add or edit product',
  'Manage products',
  'Customer enquiries',
  'Farmer community',
  'Saved items',
  'Booking history',
  'Profile & settings',
  'Notifications',
  'Retailer machinery listings',
];
const icons = [
  Icons.spa_rounded,
  Icons.language,
  Icons.phone_android,
  Icons.password,
  Icons.people_alt,
  Icons.home,
  Icons.cloud,
  Icons.trending_up,
  Icons.grass,
  Icons.compare_arrows,
  Icons.agriculture,
  Icons.search,
  Icons.info_outline,
  Icons.handyman,
  Icons.location_on,
  Icons.person_pin_circle,
  Icons.groups,
  Icons.route,
  Icons.search,
  Icons.storefront,
  Icons.inventory_2,
  Icons.store,
  Icons.add_box,
  Icons.inventory,
  Icons.chat,
  Icons.forum,
  Icons.bookmark,
  Icons.receipt_long,
  Icons.person,
  Icons.notifications,
  Icons.agriculture,
];

class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    required this.page,
    required this.role,
    required this.language,
    required this.languageChosen,
    required this.values,
    required this.onPage,
    required this.onLanguage,
    required this.onRole,
    required this.onLogout,
    required this.repository,
  });
  final int page;
  final String role, language;
  final bool languageChosen;
  final Map<String, String> values;
  final ValueChanged<int> onPage;
  final ValueChanged<String> onLanguage;
  final ValueChanged<String> onRole;
  final VoidCallback onLogout;
  final AgriBridgeRepository repository;
  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  String query = '';
  String category = 'All';
  String dataStatus = 'empty';
  String district = '';
  String block = '';
  String equipment = 'Tractor';
  bool flexibleDates = true;
  String profileName = '';
  final Map<int, List<AgriRecord>> recordsByScreen = {};
  AgriRecord? selectedRecord;
  final districtController = TextEditingController();
  final blockController = TextEditingController();
  final priceController = TextEditingController();
  final stockController = TextEditingController();
  final productNameController = TextEditingController();
  String productCategory = 'Seeds';
  DateTime? selectedRentalDate;

  String s(String english) => AppStrings.text(english, widget.language);
  String get connectionMessage => s(
    widget.repository.isConfigured
        ? 'Could not connect to live data'
        : 'Firebase is not configured. No live data is connected.',
  );

  @override
  void initState() {
    super.initState();
    _loadRecords(widget.page);
  }

  @override
  void didUpdateWidget(covariant AppShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.page != widget.page) {
      if (widget.page == 22 && widget.values['product_name'] != null) {
        productNameController.text = widget.values['product_name']!;
        priceController.text = widget.values['price'] ?? '';
        stockController.text = widget.values['stock'] ?? '';
      }
      _loadRecords(widget.page);
    }
  }

  Future<void> _loadRecords(int screen) async {
    final kind = dataKindForScreen(screen);
    if (kind == null) return;
    if (mounted) setState(() => dataStatus = 'loading');
    try {
      final records = await widget.repository.fetch(kind);
      if (!mounted || widget.page != screen) return;
      setState(() {
        recordsByScreen[screen] = records;
        dataStatus = widget.repository.isConfigured ? 'ready' : 'unconfigured';
      });
    } catch (_) {
      if (mounted && widget.page == screen) {
        setState(() => dataStatus = 'error');
      }
    }
  }

  @override
  void dispose() {
    priceController.dispose();
    stockController.dispose();
    productNameController.dispose();
    districtController.dispose();
    blockController.dispose();
    super.dispose();
  }

  void go(int i) {
    setState(() {
      query = '';
      category = 'All';
      if (![12, 15, 20].contains(i)) selectedRecord = null;
    });
    widget.onPage(i);
  }

  @override
  Widget build(BuildContext context) {
    final i = widget.page;
    final landing = i == 0 || i == 1 || i == 2 || i == 3 || i == 4;
    return Scaffold(
      appBar: landing
          ? null
          : AppBar(
              leading: i == 5 || i == 21
                  ? null
                  : BackButton(
                      onPressed: () => go(
                        i <= 4
                            ? 5
                            : i == 11
                            ? 10
                            : i == 12
                            ? 11
                            : i == 14
                            ? 13
                            : i == 15
                            ? 14
                            : i == 17
                            ? 16
                            : i == 19
                            ? 18
                            : i == 20
                            ? 19
                            : i == 22
                            ? 21
                            : i == 23
                            ? 21
                            : i == 24 || i == 30
                            ? 21
                            : 5,
                      ),
                    ),
              title: Text(
                s(screenTitles[i]),
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                ),
              ),
              actions: [
                IconButton(
                  tooltip: 'Notifications',
                  onPressed: () => go(29),
                  icon: const Icon(Icons.notifications_none_rounded),
                ),
                const SizedBox(width: 6),
              ],
            ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: landing ? _onboarding(i) : _content(i),
          ),
        ),
      ),
      bottomNavigationBar: landing
          ? null
          : NavigationBar(
              height: 68,
              selectedIndex: _navIndex(i),
              onDestinationSelected: (n) => go(
                [
                  widget.role == 'Farmer' ? 5 : 21,
                  widget.role == 'Farmer' ? 10 : 23,
                  27,
                  26,
                  28,
                ][n],
              ),
              destinations: [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home),
                  label: s('Home'),
                ),
                NavigationDestination(
                  icon: Icon(Icons.search),
                  label: s('Explore'),
                ),
                NavigationDestination(
                  icon: Icon(Icons.receipt_long_outlined),
                  label: s('Bookings'),
                ),
                NavigationDestination(
                  icon: Icon(Icons.bookmark_border),
                  label: s('Saved'),
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline),
                  label: s('Profile'),
                ),
              ],
            ),
    );
  }

  int _navIndex(int i) => i == 26
      ? 3
      : i == 27
      ? 2
      : i == 28
      ? 4
      : (i == 10 ||
                i == 11 ||
                i == 18 ||
                i == 19 ||
                i == 23 ||
                i == 24 ||
                i == 30
            ? 1
            : 0);
  Widget _onboarding(int i) => Padding(
    padding: const EdgeInsets.fromLTRB(22, 12, 22, 12),
    child: Column(
      children: [
        if (i > 1)
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: () => go(i - 1),
              icon: const Icon(Icons.arrow_back),
            ),
          ),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (i == 0) ...[
                  const SizedBox(height: 54),
                  const Icon(Icons.eco_rounded, size: 92, color: green),
                  const Text(
                    'AgriBridge',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: darkGreen,
                    ),
                  ),
                  Text(
                    s(
                      'Connecting farmers. Sharing resources. Growing together.',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                if (i == 1) ...[
                  const SizedBox(height: 20),
                  const Icon(Icons.eco_rounded, size: 64, color: green),
                  const SizedBox(height: 4),
                  const Text(
                    'AgriBridge',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: darkGreen,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    s('Choose your language'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.w800,
                      color: darkGreen,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    s('Farmer-first services for your village'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, color: muted),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: _languageCard(
                          'தமிழ்',
                          '1 — தமிழ்',
                          Icons.translate_rounded,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _languageCard(
                          'English',
                          '2 — English',
                          Icons.language_rounded,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: () => SemanticsService.sendAnnouncement(
                      View.of(context),
                      widget.language == 'தமிழ்'
                          ? 'AgriBridge. மொழியைத் தேர்ந்தெடுக்கவும். தமிழைத் தேர்ந்தெடுக்க ஒன்று அழுத்தவும். ஆங்கிலத்தைத் தேர்ந்தெடுக்க இரண்டு அழுத்தவும்.'
                          : 'AgriBridge. Choose your language. Select one for Tamil or two for English.',
                      TextDirection.ltr,
                    ),
                    icon: const Icon(Icons.volume_up_rounded),
                    label: Text(s('Listen to language options')),
                  ),
                ],
                if (i == 2) ...[
                  const SizedBox(height: 36),
                  Icon(Icons.phone_iphone_rounded, size: 58, color: green),
                  Text(
                    s('Mobile number'),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: darkGreen,
                    ),
                  ),
                  Text(
                    s(
                      'Use your phone number to continue. Demo only; no OTP will be sent.',
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    key: const Key('phone'),
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      prefixText: '+91  ',
                      labelText: s('Phone number'),
                    ),
                  ),
                ],
                if (i == 3) ...[
                  const SizedBox(height: 36),
                  const Icon(Icons.sms_outlined, size: 58, color: green),
                  Text(
                    s('OTP verification'),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: darkGreen,
                    ),
                  ),
                  DemoNotice(s('Demo only. No OTP was sent or verified.')),
                  const SizedBox(height: 20),
                  TextField(
                    key: const Key('otp'),
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    decoration: InputDecoration(
                      labelText: s('Enter any 6 digits for UI preview'),
                      counterText: '',
                    ),
                  ),
                ],
                if (i == 4) ...[
                  const SizedBox(height: 36),
                  Text(
                    s('How will you use AgriBridge?'),
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: darkGreen,
                    ),
                  ),
                  Text(s('Choose your experience. You can change this later.')),
                  const SizedBox(height: 20),
                  ChoiceTile(
                    title: s('Farmer'),
                    icon: Icons.agriculture_outlined,
                    selected: widget.role == 'Farmer',
                    onTap: () => widget.onRole('Farmer'),
                  ),
                  ChoiceTile(
                    title: s('Retailer'),
                    icon: Icons.storefront_outlined,
                    selected: widget.role == 'Retailer',
                    onTap: () => widget.onRole('Retailer'),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        FilledButton.icon(
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(56)),
          onPressed: i == 1 && !widget.languageChosen
              ? null
              : () => i < 4 ? go(i + 1) : go(widget.role == 'Farmer' ? 5 : 21),
          icon: Icon(
            i == 2
                ? Icons.visibility
                : i == 4
                ? Icons.check
                : Icons.arrow_forward,
          ),
          label: Text(switch (i) {
            0 => s('Get started'),
            1 => s('Continue'),
            2 => s('Preview OTP screen'),
            3 => s('Continue to role selection'),
            _ => '${s('Continue as')} ${s(widget.role)}',
          }),
        ),
        if (i == 2 || i == 3)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              s('Authentication will be added later.'),
              textAlign: TextAlign.center,
              style: const TextStyle(color: muted),
            ),
          ),
      ],
    ),
  );

  Widget _languageCard(String value, String label, IconData icon) {
    final selected = widget.languageChosen && widget.language == value;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: Material(
        color: selected ? const Color(0xFFE5F0E3) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => widget.onLanguage(value),
          child: Container(
            height: 172,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: selected ? green : const Color(0xFFE3E7DB),
                width: selected ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label.startsWith('1') ? '1' : '2',
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    color: green,
                  ),
                ),
                Icon(icon, color: green, size: 27),
                const SizedBox(height: 5),
                Text(
                  value,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: darkGreen,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _content(int i) {
    final title = s(screenTitles[i]);
    final allData = _items(i);
    final data = i == 11
        ? allData
              .where(
                (item) => item.toLowerCase().contains(equipment.toLowerCase()),
              )
              .toList()
        : allData;
    final searching = [
      7,
      8,
      9,
      10,
      11,
      13,
      14,
      18,
      19,
      23,
      24,
      25,
      26,
      27,
      29,
      30,
    ].contains(i);
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 28),
      children: [
        if (dataStatus == 'loading' && dataKindForScreen(i) != null)
          _repositoryStatus(),
        if (dataStatus == 'error' && dataKindForScreen(i) != null)
          _repositoryStatus(),
        if (i == 5) _machineryHero(),
        if (i == 5 || i == 21) _welcomeCard(i),
        if (i == 5) _farmerServiceGrid(),
        if ([
          6,
          7,
          8,
          9,
          10,
          11,
          13,
          14,
          18,
          19,
          23,
          24,
          25,
          26,
          27,
          29,
        ].contains(i)) ...[
          if (searching)
            TextField(
              onChanged: (v) => setState(() => query = v),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search ${title.toLowerCase()}...',
                suffixIcon: query.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () => setState(() => query = ''),
                        icon: const Icon(Icons.close),
                      ),
              ),
            ),
          if ([7, 8, 9, 10, 13, 18, 23, 24, 27].contains(i)) ...[
            const SizedBox(height: 12),
            _filterRow(i),
          ],
        ],
        if (i == 11) _resultScope(),
        if (i == 10 || i == 13 || i == 18) _filterForm(i),
        if (i == 12 || i == 15 || i == 16 || i == 17 || i == 20)
          _detailBlock(i),
        if (i == 22) _productForm(),
        if (i == 16) _groupForm(),
        if (i == 17) _routeCard(),
        if (i == 25) _communityComposer(),
        if (i == 28) _settings(),
        if (i == 27) _bookingStatus(),
        if (i == 6)
          _emptyState(
            message: 'No weather service is connected',
            action: 'Explore services',
          ),
        if (data.isNotEmpty && i != 27) ...[
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: Text(
                  i == 5
                      ? s('More farm services')
                      : i == 21
                      ? s('Recent enquiries')
                      : _sectionHeading(i),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: darkGreen,
                  ),
                ),
              ),
              if (i == 5 || i == 21)
                TextButton(
                  onPressed: () => go(i == 5 ? 10 : 23),
                  child: Text(s('View all')),
                ),
            ],
          ),
          ...data
              .where(
                (e) =>
                    (query.isEmpty ||
                        e.toLowerCase().contains(query.toLowerCase())) &&
                    _matchesCategory(e, i),
              )
              .map((e) => _itemCard(e, i)),
          if (data
              .where(
                (e) =>
                    (query.isEmpty ||
                        e.toLowerCase().contains(query.toLowerCase())) &&
                    _matchesCategory(e, i),
              )
              .isEmpty)
            _emptyState(screen: i),
        ],
        if (i == 21) _retailerExtras(),
        if (i != 5 &&
            i != 10 &&
            i != 13 &&
            i != 18 &&
            i != 21 &&
            i != 22 &&
            i != 16 &&
            i != 17 &&
            i != 28 &&
            data.isEmpty &&
            i != 6)
          _emptyState(screen: i),
        if (i == 21 && data.isEmpty) _emptyState(message: 'No enquiries yet'),
      ],
    );
  }

  String _sectionHeading(int i) => s(screenTitles[i]);
  bool _matchesCategory(String item, int i) {
    if (category == 'All') return true;
    if (i == 27) {
      return category == 'Pending'
          ? item.toLowerCase().contains('pending')
          : category == 'Approved'
          ? item.toLowerCase().contains('approved')
          : category == 'Completed'
          ? item.toLowerCase().contains('completed')
          : category == 'Cancelled'
          ? item.toLowerCase().contains('cancelled')
          : true;
    }
    if (category == 'Rent') return true;
    if (category == 'Buy used') return true;
    if (category == 'New') return item.contains('New');
    if (category == 'Replied') return item.contains('Replied');
    if (category == 'Seeds') {
      return item.toLowerCase().contains('seed') ||
          item.toLowerCase().contains('maize');
    }
    if (category == 'Fertilizers') {
      return item.toLowerCase().contains('urea') ||
          item.toLowerCase().contains('dap');
    }
    if (category == 'Pesticides') {
      return item.toLowerCase().contains('pesticide');
    }
    return item.toLowerCase().contains(category.toLowerCase());
  }

  List<String> _items(int i) {
    final records =
        recordsByScreen[i]?.map((record) => record.title).toList() ??
        <String>[];
    if (i == 23 && widget.values['product_name'] != null) {
      records.add(
        '${widget.values['product_name']} · ₹${widget.values['price']} · Stock ${widget.values['stock']}',
      );
    }
    if (i == 27 && widget.values['rental_request_status'] != null) {
      records.add(s('Rental request · Session-only draft'));
    }
    if (i == 27 && widget.values['group_request_status'] != null) {
      records.add(s('Group request · Session-only draft'));
    }
    return records;
  }

  Widget _farmerServiceGrid() {
    final services =
        <
          ({
            String label,
            IconData icon,
            Color color,
            int page,
            String? category,
          })
        >[
          (
            label: 'Weather information',
            icon: Icons.wb_cloudy_rounded,
            color: const Color(0xFF4D8797),
            page: 6,
            category: null,
          ),
          (
            label: 'Market prices',
            icon: Icons.show_chart_rounded,
            color: const Color(0xFFB46B45),
            page: 7,
            category: null,
          ),
          (
            label: 'Seeds',
            icon: Icons.grass_rounded,
            color: const Color(0xFF56834C),
            page: 8,
            category: 'Seeds',
          ),
          (
            label: 'Fertilizers',
            icon: Icons.compost_rounded,
            color: const Color(0xFF8B7445),
            page: 8,
            category: 'Fertilizers',
          ),
          (
            label: 'Find a mechanic',
            icon: Icons.handyman_rounded,
            color: const Color(0xFF557080),
            page: 13,
            category: null,
          ),
          (
            label: 'Farmer community',
            icon: Icons.groups_rounded,
            color: const Color(0xFF80619A),
            page: 25,
            category: null,
          ),
          (
            label: 'Group booking',
            icon: Icons.route_rounded,
            color: const Color(0xFFB46B45),
            page: 16,
            category: null,
          ),
          (
            label: 'Used equipment',
            icon: Icons.inventory_2_outlined,
            color: const Color(0xFF58766A),
            page: 18,
            category: null,
          ),
          (
            label: 'My bookings',
            icon: Icons.calendar_month_rounded,
            color: const Color(0xFF4D8797),
            page: 27,
            category: null,
          ),
          (
            label: 'Saved items',
            icon: Icons.bookmark_border_rounded,
            color: const Color(0xFFB46B45),
            page: 26,
            category: null,
          ),
          (
            label: 'Notifications',
            icon: Icons.notifications_none_rounded,
            color: const Color(0xFF68785B),
            page: 29,
            category: null,
          ),
        ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 10),
          child: Text(
            s('Farm services'),
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: darkGreen,
            ),
          ),
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            final tileWidth = (constraints.maxWidth - 12) / 2;
            return GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: tileWidth / 132,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: services.map((service) {
                return Semantics(
                  button: true,
                  label: s(service.label),
                  child: Card(
                    margin: EdgeInsets.zero,
                    color: Colors.white,
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () {
                        go(service.page);
                        if (service.category != null) {
                          setState(() => category = service.category!);
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(13),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(service.icon, color: service.color, size: 30),
                            const SizedBox(height: 9),
                            Text(
                              s(service.label),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.visible,
                              style: const TextStyle(
                                fontSize: 15,
                                height: 1.2,
                                fontWeight: FontWeight.w700,
                                color: darkGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _welcomeCard(int i) => Card(
    color: green,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Color(0x33FFFFFF),
            child: Icon(Icons.agriculture, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  i == 5 ? s('Farmer workspace') : s('Retailer workspace'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  s(profileName.isEmpty ? 'Profile not set up' : profileName),
                  style: const TextStyle(color: Color(0xFFDDEBDD)),
                ),
                const SizedBox(height: 8),
                Text(
                  connectionMessage,
                  style: TextStyle(
                    color: Color(0xFFFFDCA8),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: .7,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            i == 5 ? Icons.agriculture_outlined : Icons.storefront_outlined,
            color: const Color(0xFFFFD37A),
            size: 30,
          ),
        ],
      ),
    ),
  );
  Widget _resultScope() => Card(
    color: const Color(0xFFE8F2E3),
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Text(
        '${s('Search equipment near your village')}: ${s(equipment)} · ${district.isEmpty ? s('District not selected') : district}, ${block.isEmpty ? s('Block / Taluk not selected') : block}',
        style: const TextStyle(color: darkGreen, fontWeight: FontWeight.w700),
      ),
    ),
  );

  String _dateLabel(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

  IconData _equipmentIcon(String label) {
    final value = label.toLowerCase();
    if (value.contains('tractor')) return Icons.agriculture_rounded;
    if (value.contains('harvester')) return Icons.agriculture_rounded;
    if (value.contains('rotavator')) return Icons.settings_rounded;
    if (value.contains('tiller')) return Icons.precision_manufacturing_rounded;
    if (value.contains('sprayer')) return Icons.water_drop_rounded;
    if (value.contains('seed') ||
        value.contains('paddy') ||
        value.contains('maize')) {
      return Icons.grass_rounded;
    }
    if (value.contains('urea') ||
        value.contains('fertilizer') ||
        value.contains('dap')) {
      return Icons.compost_rounded;
    }
    if (value.contains('weather') || value.contains('cloud')) {
      return Icons.cloud_rounded;
    }
    if (value.contains('price')) return Icons.trending_up_rounded;
    if (value.contains('mechanic')) return Icons.handyman_rounded;
    if (value.contains('group')) return Icons.groups_rounded;
    if (value.contains('community')) return Icons.forum_rounded;
    if (value.contains('notification')) return Icons.notifications_rounded;
    if (value.contains('booking')) return Icons.receipt_long_rounded;
    return Icons.eco_rounded;
  }

  String _localizeRecord(String record) {
    var result = record;
    for (final name in [
      'Tractor',
      'Harvester',
      'Rotavator',
      'Power tiller',
      'Sprayer',
      'Seed drill',
      'Seeds',
      'Fertilizers',
    ]) {
      result = result.replaceAll(name, s(name));
    }
    return s(result);
  }

  Widget _machineryHero() => Card(
    color: darkGreen,
    clipBehavior: Clip.antiAlias,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s('Rent farm machinery'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        height: 1.2,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      s('Find equipment near your village'),
                      style: const TextStyle(
                        color: Color(0xFFE2F0E3),
                        fontSize: 16,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 128,
                height: 108,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF5DE),
                  borderRadius: BorderRadius.circular(18),
                ),
                alignment: Alignment.center,
                child: const TractorIllustration(width: 118, height: 86),
              ),
            ],
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            key: const Key('hero_search_machinery'),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFF0B14F),
              foregroundColor: darkGreen,
              minimumSize: const Size.fromHeight(54),
            ),
            onPressed: () => go(10),
            icon: const Icon(Icons.search_rounded),
            label: Text(
              s('Search machinery'),
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    ),
  );
  Widget _filterRow(int i) => Wrap(
    spacing: 8,
    runSpacing: 6,
    children:
        (i == 27
                ? ['All', 'Pending', 'Approved', 'Completed', 'Cancelled']
                : i == 24
                ? ['All', 'New', 'Replied']
                : i == 23
                ? ['All', 'Seeds', 'Fertilizers', 'Pesticides']
                : i == 7
                ? ['All', 'Paddy', 'Vegetables']
                : i == 8
                ? ['All', 'Seeds', 'Fertilizers']
                : ['All', 'Rent', 'Buy used'])
            .map(
              (c) => ChoiceChip(
                label: Text(s(c)),
                selected: category == c,
                onSelected: (_) => setState(() => category = c),
              ),
            )
            .toList(),
  );
  Widget _filterForm(int i) => Card(
    color: Colors.white,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            s('Search filters'),
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: darkGreen,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: districtController,
            decoration: InputDecoration(labelText: s('District')),
            onChanged: (value) => setState(() => district = value.trim()),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: blockController,
            decoration: InputDecoration(labelText: s('Block / Taluk')),
            onChanged: (value) => setState(() => block = value.trim()),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            initialValue: equipment,
            decoration: InputDecoration(labelText: s('Equipment type')),
            items:
                ['Tractor', 'Rotavator', 'Harvester', 'Power tiller', 'Sprayer']
                    .map((v) => DropdownMenuItem(value: v, child: Text(s(v))))
                    .toList(),
            onChanged: (value) {
              if (value != null) setState(() => equipment = value);
            },
          ),
          if (i == 10 || i == 18) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: Text(s('Flexible dates')),
                  selected: flexibleDates,
                  onSelected: (_) => setState(() {
                    flexibleDates = true;
                    selectedRentalDate = null;
                  }),
                ),
                ChoiceChip(
                  label: Text(s('Specific date')),
                  selected: !flexibleDates,
                  onSelected: (_) => setState(() => flexibleDates = false),
                ),
              ],
            ),
            if (!flexibleDates)
              TextField(
                decoration: InputDecoration(
                  labelText: s('Dates'),
                  hintText: selectedRentalDate == null
                      ? s('Select rental dates')
                      : _dateLabel(selectedRentalDate!),
                ),
                readOnly: true,
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: selectedRentalDate ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) setState(() => selectedRentalDate = date);
                },
              ),
          ],
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: () => go(
              i == 10
                  ? 11
                  : i == 13
                  ? 14
                  : i == 18
                  ? 19
                  : i,
            ),
            icon: const Icon(Icons.search),
            label: Text(i == 13 ? s('Find mechanics') : s('Search')),
          ),
        ],
      ),
    ),
  );
  Widget _detailBlock(int i) {
    final hasRecord = selectedRecord != null;
    final title = hasRecord
        ? selectedRecord!.title
        : i == 16
        ? 'Group machinery booking'
        : i == 17
        ? 'Suggested multi-day route'
        : screenTitles[i];
    final body = hasRecord
        ? selectedRecord!.subtitle
        : i == 16
        ? 'Choose equipment and dates. This creates a local draft only; equipment owner approval is required before confirmation.'
        : i == 17
        ? 'No route is confirmed. Compatible requests and owner approvals are required first.'
        : 'No compatible listing is selected.';
    final canSubmitDraft = i == 16;
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 38,
                backgroundColor: const Color(0xFFE8F2E3),
                child: Icon(icons[i], color: green, size: 38),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              _localizeRecord(title),
              style: const TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w900,
                color: darkGreen,
              ),
            ),
            const SizedBox(height: 8),
            Text(s(body)),
            const SizedBox(height: 12),
            DemoNotice(
              hasRecord
                  ? connectionMessage
                  : s('No compatible listing is selected.'),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: canSubmitDraft || hasRecord ? () => _action(i) : null,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
              child: Text(
                s(
                  i == 12
                      ? 'Request rental'
                      : i == 15
                      ? 'Contact mechanic'
                      : i == 17
                      ? 'Request owner approval'
                      : i == 20
                      ? 'Request rent / sale'
                      : 'Create draft request',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _productForm() => Card(
    color: Colors.white,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: productNameController,
            key: const Key('product_name'),
            decoration: InputDecoration(
              labelText: widget.language == 'தமிழ்'
                  ? 'பொருளின் பெயர்'
                  : 'Product name',
              hintText: widget.values['product_name'] ?? '',
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: priceController,
            key: const Key('product_price'),
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: s('Price'),
              prefixText: '₹',
              hintText: widget.values['price'] ?? '',
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: stockController,
            key: const Key('product_stock'),
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: s('Stock quantity'),
              hintText: widget.values['stock'] ?? '',
            ),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            initialValue: productCategory,
            decoration: InputDecoration(
              labelText: widget.language == 'தமிழ்' ? 'வகை' : 'Category',
            ),
            items: ['Seeds', 'Fertilizers', 'Pesticides', 'Tools']
                .map(
                  (value) =>
                      DropdownMenuItem(value: value, child: Text(s(value))),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) setState(() => productCategory = value);
            },
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: () {
              final price = int.tryParse(priceController.text.trim());
              final stock = int.tryParse(stockController.text.trim());
              final name = productNameController.text.trim();
              if (name.isEmpty ||
                  price == null ||
                  price < 1 ||
                  stock == null ||
                  stock < 0) {
                _snack(
                  s(
                    'Enter a product name, price and stock to save a local draft.',
                  ),
                );
                return;
              }
              setState(
                () => widget.values.addAll({
                  'product_name': name,
                  'product_category': productCategory,
                  'price': '$price',
                  'stock': '$stock',
                }),
              );
              _snack(
                '${s('Product draft saved during this session only. Not published.')} · ₹$price · ${s('Stock quantity')} $stock',
              );
            },
            icon: const Icon(Icons.save),
            label: Text(s('Save product locally')),
          ),
        ],
      ),
    ),
  );
  Widget _groupForm() => Card(
    color: Colors.white,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            initialValue: 'Rotavator',
            decoration: const InputDecoration(labelText: 'Equipment'),
            items: [
              'Rotavator',
              'Tractor',
              'Harvester',
            ].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
            onChanged: (_) {},
          ),
          const SizedBox(height: 10),
          TextField(
            decoration: const InputDecoration(
              labelText: 'Date range',
              hintText: 'Choose dates',
            ),
            readOnly: true,
            onTap: () => showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            ),
          ),
          const SizedBox(height: 10),
          const TextField(
            key: Key('farmers'),
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Expected farmers'),
          ),
          const SizedBox(height: 8),
          Text(
            s(
              'Create a draft to share requests with farmers nearby. Owners approve equipment before any route is confirmed.',
            ),
            style: TextStyle(color: muted),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () {
              setState(() {
                widget.values['group_request_status'] = 'draft';
              });
              _snack(
                s(
                  'Request draft for this session only. It has not been submitted.',
                ),
              );
            },
            child: Text(s('Create draft group request')),
          ),
        ],
      ),
    ),
  );
  Widget _routeCard() => Card(
    color: const Color(0xFFE8F2E3),
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          const Icon(Icons.route_outlined, size: 36, color: green),
          const SizedBox(height: 10),
          Text(
            s('No compatible route can be suggested yet'),
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: darkGreen,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            s(
              'No route is confirmed. Compatible requests and owner approvals are required first.',
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
  Widget _communityComposer() => Card(
    color: Colors.white,
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          const Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Share a question with farmers',
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            tooltip: s('Post question'),
            onPressed: () => _snack(
              s('Community posting is not connected. No post was submitted.'),
            ),
            icon: const Icon(Icons.send, color: green),
          ),
        ],
      ),
    ),
  );
  Widget _settings() => Column(
    children: [
      Card(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              CircleAvatar(
                radius: 38,
                backgroundColor: const Color(0xFFE5F0E3),
                child: const Icon(Icons.person_rounded, color: green, size: 42),
              ),
              const SizedBox(height: 10),
              Text(
                profileName.isEmpty ? s('Profile not set up') : profileName,
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                  color: darkGreen,
                ),
              ),
              Text(s(widget.role), style: const TextStyle(color: muted)),
              const SizedBox(height: 14),
              _profileFact(
                Icons.phone_android,
                s('Mobile number'),
                s('Not provided'),
              ),
              _profileFact(
                Icons.verified_user_outlined,
                s('Phone verification'),
                s('Demo only · not verified'),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                  ),
                  onPressed: _editProfileName,
                  icon: const Icon(Icons.edit_outlined),
                  label: Text(s('Edit profile')),
                ),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 12),
      Card(
        color: Colors.white,
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.translate, color: green),
              title: Text(s('Change language')),
              trailing: DropdownButton<String>(
                value: widget.language,
                items: ['தமிழ்', 'English']
                    .map(
                      (value) =>
                          DropdownMenuItem(value: value, child: Text(value)),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) widget.onLanguage(value);
                },
              ),
            ),
            ListTile(
              leading: const Icon(Icons.notifications, color: green),
              title: Text(s('Notifications')),
              onTap: () => go(29),
            ),
            ListTile(
              leading: const Icon(Icons.help_outline, color: green),
              title: Text(s('Help & support')),
              onTap: () => _snack(
                widget.language == 'தமிழ்'
                    ? 'உதவி வசதி பின்னர் சேர்க்கப்படும்.'
                    : 'Support contact will be added later.',
              ),
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: green),
              title: Text(s('Logout')),
              onTap: widget.onLogout,
            ),
          ],
        ),
      ),
    ],
  );

  Widget _profileFact(IconData icon, String label, String value) => ListTile(
    dense: false,
    minLeadingWidth: 28,
    leading: Icon(icon, color: green),
    title: Text(label, style: const TextStyle(fontSize: 14)),
    subtitle: Text(
      value,
      style: const TextStyle(fontWeight: FontWeight.w700, color: darkGreen),
    ),
  );

  Future<void> _editProfileName() async {
    final controller = TextEditingController(text: profileName);
    final value = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(s('Edit profile')),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            labelText: widget.language == 'தமிழ்' ? 'பெயர்' : 'Name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(s('Cancel')),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(dialogContext, controller.text.trim()),
            child: Text(s('Save changes')),
          ),
        ],
      ),
    );
    if (value != null && value.isNotEmpty && mounted) {
      setState(() => profileName = value);
    }
    controller.dispose();
  }

  Widget _bookingStatus() => Column(
    children: [
      Align(
        alignment: Alignment.centerLeft,
        child: Text(
          s('My bookings'),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: darkGreen,
          ),
        ),
      ),
      const SizedBox(height: 8),
      for (final item in _items(
        27,
      ).where((item) => category == 'All' || _matchesCategory(item, 27)))
        Card(
          color: Colors.white,
          child: ListTile(
            minVerticalPadding: 10,
            leading: Icon(
              item.toLowerCase().contains('approved')
                  ? Icons.check_circle_outline
                  : item.toLowerCase().contains('completed')
                  ? Icons.task_alt
                  : item.toLowerCase().contains('cancelled')
                  ? Icons.cancel_outlined
                  : Icons.pending_actions,
              color: item.toLowerCase().contains('approved') ? green : orange,
            ),
            title: Text(
              _localizeRecord(item),
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: Text(
              item == s('Rental request · Session-only draft') ||
                      item == s('Group request · Session-only draft')
                  ? s(
                      'Request draft for this session only. It has not been submitted.',
                    )
                  : _recordFor(27, item)?.subtitle ?? connectionMessage,
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _snack(connectionMessage),
          ),
        ),
    ],
  );
  Widget _retailerExtras() => Column(
    children: [
      FilledButton.icon(
        onPressed: () => go(22),
        icon: const Icon(Icons.add),
        label: Text(s('Add a product')),
      ),
      _navCard(s('Manage listings'), Icons.inventory, 23),
      _navCard(s('Machinery listings'), Icons.agriculture, 30),
      _navCard(s('Customer enquiries'), Icons.chat, 24),
    ],
  );
  Widget _navCard(String text, IconData icon, int p) => Card(
    color: Colors.white,
    child: ListTile(
      leading: Icon(icon, color: green),
      title: Text(text),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => go(p),
    ),
  );
  Widget _itemCard(String text, int i) {
    AgriRecord? record;
    for (final candidate in recordsByScreen[i] ?? const <AgriRecord>[]) {
      if (candidate.title == text) {
        record = candidate;
        break;
      }
    }
    final localProduct = i == 23 && widget.values['product_name'] != null;
    final subtitle = record?.subtitle.isNotEmpty == true
        ? record!.subtitle
        : localProduct
        ? 'Saved during this session only. Not published to customers.'
        : null;
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        leading: i == 11
            ? Container(
                width: 54,
                height: 54,
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F2E3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _equipmentIcon(text),
                  color: green,
                  size: 34,
                  semanticLabel: text.split('·').first.trim(),
                ),
              )
            : CircleAvatar(
                backgroundColor: const Color(0xFFE8F2E3),
                child: Icon(
                  _equipmentIcon(text),
                  color: green,
                  size: 24,
                  semanticLabel: text.split('·').first.trim(),
                ),
              ),
        title: Text(
          _localizeRecord(text),
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
        subtitle: subtitle == null
            ? null
            : Text(
                s(subtitle),
                style: const TextStyle(fontSize: 13, color: muted),
              ),
        trailing: i == 30
            ? null
            : i == 11
            ? TextButton(
                onPressed: () => _rowAction(i, text),
                child: Text(s('View details')),
              )
            : i == 24
            ? IconButton(
                tooltip: s('Reply'),
                onPressed: () => _rowAction(i, text),
                icon: const Icon(Icons.reply_rounded, color: green),
              )
            : IconButton(
                tooltip: s('View details'),
                onPressed: () => _rowAction(i, text),
                icon: const Icon(Icons.chevron_right, color: green),
              ),
        onTap: i == 30 ? null : () => _rowAction(i, text),
      ),
    );
  }

  Widget _emptyState({
    int? screen,
    String? message,
    String? action,
    VoidCallback? onAction,
  }) => Container(
    margin: const EdgeInsets.symmetric(vertical: 16),
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
    ),
    child: Column(
      children: [
        const Icon(Icons.search_off, color: muted, size: 38),
        const SizedBox(height: 8),
        Text(
          s(message ?? _emptyMessage(screen)),
          style: const TextStyle(fontWeight: FontWeight.w700, color: darkGreen),
        ),
        Text(
          connectionMessage,
          style: const TextStyle(color: muted),
          textAlign: TextAlign.center,
        ),
        if (action != null ||
            screen == 11 ||
            screen == 14 ||
            screen == 19 ||
            screen == 20 ||
            screen == 23)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: OutlinedButton.icon(
              onPressed: onAction ?? () => go(_emptyActionTarget(screen)),
              icon: const Icon(Icons.arrow_forward_rounded),
              label: Text(s(action ?? _emptyActionLabel(screen))),
            ),
          ),
      ],
    ),
  );

  String _emptyMessage(int? screen) => switch (screen) {
    6 => 'No weather service is connected',
    7 || 9 => 'No market data available yet',
    8 => 'No listings available yet',
    11 || 19 || 20 || 30 => 'No listings available yet',
    14 || 15 => 'No mechanic profiles available yet',
    23 => 'No product listings yet',
    24 => 'No enquiries yet',
    25 => 'No community posts yet',
    26 => 'No saved items yet',
    27 => 'No booking requests yet',
    29 => 'No notifications yet',
    _ => 'No listings available yet',
  };

  String _emptyActionLabel(int? screen) => switch (screen) {
    11 => 'Change search filters',
    14 => 'Change search filters',
    19 => 'Change search filters',
    20 => 'Return to listings',
    23 => 'Add the first product',
    _ => 'Explore services',
  };

  int _emptyActionTarget(int? screen) => switch (screen) {
    11 => 10,
    14 => 13,
    19 => 18,
    20 => 19,
    23 => 22,
    _ => 5,
  };
  void _rowAction(int i, [String? itemTitle]) {
    if (i == 5) {
      final item = (itemTitle ?? '').toLowerCase();
      if (item.contains('weather') || itemTitle == s('Weather information')) {
        go(6);
      } else if (item.contains('price') || itemTitle == s('Market prices')) {
        go(7);
      } else if (itemTitle == s('Seeds & fertilizer')) {
        go(8);
      } else if (item.contains('mechanic') ||
          itemTitle == s('Find a mechanic')) {
        go(13);
      } else if (item.contains('group') ||
          itemTitle == s('Create group booking')) {
        go(16);
      } else if (item.contains('used equipment') ||
          itemTitle == s('Used equipment search')) {
        go(18);
      } else if (item.contains('booking') || itemTitle == s('My bookings')) {
        go(27);
      } else if (item.contains('notification') ||
          itemTitle == s('Notifications')) {
        go(29);
      } else {
        go(25);
      }
      return;
    }
    if (i == 11) {
      selectedRecord = _recordFor(11, itemTitle);
      go(12);
    } else if (i == 14) {
      selectedRecord = _recordFor(14, itemTitle);
      go(15);
    } else if (i == 19) {
      selectedRecord = _recordFor(19, itemTitle);
      go(20);
    } else if (i == 24) {
      _snack(s('Messaging is not connected. No reply was sent.'));
    } else if (i == 29) {
      _snack(connectionMessage);
    } else if (i == 7) {
      go(9);
    } else if (i == 10) {
      go(11);
    } else if (i == 13) {
      go(14);
    } else if (i == 18) {
      go(19);
    } else if (i == 23) {
      go(22);
    } else {
      _snack(connectionMessage);
    }
  }

  AgriRecord? _recordFor(int screen, String? title) {
    for (final record in recordsByScreen[screen] ?? const <AgriRecord>[]) {
      if (record.title == title) return record;
    }
    return null;
  }

  void _action(int i) {
    if (i == 12) {
      setState(() => widget.values['rental_request_status'] = 'draft');
      _snack(
        s('Request draft for this session only. It has not been submitted.'),
      );
    } else if (i == 15) {
      _snack(
        'Contact actions are placeholders. No call or message was placed.',
      );
    } else if (i == 17) {
      _snack(
        s('Request draft for this session only. It has not been submitted.'),
      );
    } else if (i == 20) {
      _snack(
        s('Request draft for this session only. It has not been submitted.'),
      );
    } else {
      _snack(
        s('Request draft for this session only. It has not been submitted.'),
      );
    }
  }

  Widget _repositoryStatus() => Card(
    color: Colors.white,
    child: ListTile(
      leading: dataStatus == 'loading'
          ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.cloud_off_outlined, color: orange),
      title: Text(
        dataStatus == 'loading'
            ? s('Loading listings')
            : s('Could not load listings'),
      ),
      subtitle: Text(connectionMessage),
      trailing: dataStatus == 'error'
          ? IconButton(
              tooltip: s('Retry'),
              onPressed: () => _loadRecords(widget.page),
              icon: const Icon(Icons.refresh),
            )
          : null,
    ),
  );

  void _snack(String text) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(text), behavior: SnackBarBehavior.floating),
  );
}
