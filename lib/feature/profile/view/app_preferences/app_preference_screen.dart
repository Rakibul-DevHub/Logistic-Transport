import 'package:flutter/material.dart';

class AppPreferencesScreen extends StatefulWidget {
  const AppPreferencesScreen({super.key});

  @override
  State<AppPreferencesScreen> createState() =>
      _AppPreferencesScreenState();
}

class _AppPreferencesScreenState
    extends State<AppPreferencesScreen> {
  bool notificationEnabled = true;
  bool isMilesSelected = true;

  String selectedDateFormat = 'MM/DD/YYYY';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),

      // ================= APP BAR =================
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: const Color(0xFFF5F5F7),
        centerTitle: true,
        leadingWidth: 70,
        leading: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              height: 42,
              width: 42,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: Color(0xFF1D2433),
              ),
            ),
          ),
        ),
        title: const Text(
          'App Preferences',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1D2433),
          ),
        ),
      ),

      // ================= BODY =================
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
        ),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            // HEADER
            const Text(
              'App Preferences',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1D2433),
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              'Configure your workspace and regional display\nsettings.',
              style: TextStyle(
                fontSize: 14,
                height: 1.3,
                color: Color(0xFF7C869C),
              ),
            ),

            const SizedBox(height: 20),

            // ================= MAIN CARD =================
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFE4E7EC),
                ),
              ),
              child: Column(
                children: [
                  // LANGUAGE
                  _buildLanguageTile(),

                  _divider(),

                  // DISTANCE UNITS
                  _buildDistanceTile(),

                  _divider(),

                  // DATE FORMAT
                  _buildDateFormatTile(),

                  _divider(),

                  // NOTIFICATION
                  _buildNotificationTile(),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ================= LANGUAGE TILE =================
  Widget _buildLanguageTile() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          _leadingIcon(Icons.language),

          const SizedBox(width: 14),

          const Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  'Language',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1D2433),
                  ),
                ),

                SizedBox(height: 4),

                Text(
                  'English (United States)',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF73809A),
                  ),
                ),
              ],
            ),
          ),

          const Icon(
            Icons.chevron_right_rounded,
            color: Color(0xFF7B8499),
            size: 24,
          ),
        ],
      ),
    );
  }

  // ================= DISTANCE TILE =================
  Widget _buildDistanceTile() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              _leadingIcon(Icons.straighten),

              const SizedBox(width: 14),

              const Expanded(
                child: Text(
                  'Distance Units',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1D2433),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Container(
            height: 46,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F2F4),
              borderRadius:
              BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        isMilesSelected = true;
                      });
                    },
                    child: AnimatedContainer(
                      duration:
                      const Duration(
                        milliseconds: 250,
                      ),
                      decoration: BoxDecoration(
                        color: isMilesSelected
                            ? Colors.white
                            : Colors.transparent,
                        borderRadius:
                        BorderRadius.circular(
                          8,
                        ),
                        boxShadow: isMilesSelected
                            ? [
                          BoxShadow(
                            color: Colors.black
                                .withOpacity(
                              0.04,
                            ),
                            blurRadius: 5,
                            offset:
                            const Offset(
                              0,
                              2,
                            ),
                          ),
                        ]
                            : [],
                      ),
                      child: Center(
                        child: Text(
                          'Miles',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight:
                            FontWeight.w600,
                            color:
                            isMilesSelected
                                ? const Color(
                              0xFF1D2433,
                            )
                                : const Color(
                              0xFF7C869C,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        isMilesSelected = false;
                      });
                    },
                    child: AnimatedContainer(
                      duration:
                      const Duration(
                        milliseconds: 250,
                      ),
                      decoration: BoxDecoration(
                        color: !isMilesSelected
                            ? Colors.white
                            : Colors.transparent,
                        borderRadius:
                        BorderRadius.circular(
                          8,
                        ),
                        boxShadow: !isMilesSelected
                            ? [
                          BoxShadow(
                            color: Colors.black
                                .withOpacity(
                              0.04,
                            ),
                            blurRadius: 5,
                            offset:
                            const Offset(
                              0,
                              2,
                            ),
                          ),
                        ]
                            : [],
                      ),
                      child: Center(
                        child: Text(
                          'Kilometers',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight:
                            FontWeight.w600,
                            color:
                            !isMilesSelected
                                ? const Color(
                              0xFF1D2433,
                            )
                                : const Color(
                              0xFF7C869C,
                            ),
                          ),
                        ),
                      ),
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

  // ================= DATE FORMAT TILE =================
  Widget _buildDateFormatTile() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          _leadingIcon(Icons.calendar_month),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                const Text(
                  'Date Format',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1D2433),
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  selectedDateFormat,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF73809A),
                  ),
                ),
              ],
            ),
          ),

          PopupMenuButton<String>(
            shape: RoundedRectangleBorder(
              borderRadius:
              BorderRadius.circular(12),
            ),
            onSelected: (value) {
              setState(() {
                selectedDateFormat = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'MM/DD/YYYY',
                child: Text('MM/DD/YYYY'),
              ),
              const PopupMenuItem(
                value: 'DD/MM/YYYY',
                child: Text('DD/MM/YYYY'),
              ),
              const PopupMenuItem(
                value: 'YYYY/MM/DD',
                child: Text('YYYY/MM/DD'),
              ),
            ],
            child: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Color(0xFF7B8499),
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  // ================= NOTIFICATION TILE =================
  Widget _buildNotificationTile() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          _leadingIcon(Icons.notifications_none),

          const SizedBox(width: 14),

          const Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  'Notification Sounds',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1D2433),
                  ),
                ),

                SizedBox(height: 4),

                Text(
                  'Audible alerts for dispatch',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF73809A),
                  ),
                ),
              ],
            ),
          ),

          Transform.scale(
            scale: 0.9,
            child: Switch(
              value: notificationEnabled,
              onChanged: (value) {
                setState(() {
                  notificationEnabled = value;
                });
              },
              activeColor: Colors.white,
              activeTrackColor:
              const Color(0xFF155EEF),
              inactiveThumbColor: Colors.white,
              inactiveTrackColor:
              const Color(0xFFD0D5DD),
            ),
          ),
        ],
      ),
    );
  }

  // ================= COMMON ICON =================
  Widget _leadingIcon(IconData icon) {
    return Container(
      height: 38,
      width: 38,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F4F8),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        icon,
        size: 20,
        color: const Color(0xFF223B63),
      ),
    );
  }

  // ================= DIVIDER =================
  Widget _divider() {
    return const Divider(
      height: 1,
      thickness: 1,
      color: Color(0xFFF0F2F5),
    );
  }
}