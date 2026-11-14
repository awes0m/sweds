import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../core/constants/wedding_config.dart';
import '../../core/theme/lux.dart';
import '../../core/widgets/cursor.dart';
import '../../core/widgets/glass_panel.dart';

/// The /menu page: displays the auspicious feast menu for Wedding and Reception.
/// Items are fetched from the Firebase 'menu' collection in real-time,
/// with an authentic Bengali royal banquet preview if the collection is not yet populated.
class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  late int _selectedTab;

  @override
  void initState() {
    super.initState();
    // Default tab based on event day:
    // If on or after Dec 14, 2026, default to Reception Feast; else Wedding Feast.
    final now = DateTime.now();
    final weddingCutoff = DateTime(2026, 12, 13, 23, 59, 59);
    _selectedTab = now.isAfter(weddingCutoff) ? 1 : 0;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final wide = size.width >= 900;
    final isWedding = _selectedTab == 0;

    return Scaffold(
      backgroundColor: Lux.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: Column(
              children: [
                // ── Top Header ──────────────────────────────────────────────
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: wide ? 24 : 16,
                    vertical: 14,
                  ),
                  child: Row(
                    children: [
                      CursorHover(
                        child: GestureDetector(
                          onTap: () {
                            if (Navigator.of(context).canPop()) {
                              Navigator.of(context).pop();
                            } else {
                              // Return to home
                              Navigator.of(context).pushReplacementNamed('/');
                            }
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Lux.crimson.withValues(alpha: 0.08),
                              border: Border.all(
                                color: Lux.gold.withValues(alpha: 0.7),
                                width: 1.2,
                              ),
                            ),
                            child: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 17,
                              color: Lux.crimson,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'THE ROYAL FEAST · শুভ ভোজ',
                              style: LuxText.eyebrow(Lux.crimson)
                                  .copyWith(fontSize: 12, letterSpacing: 3),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${WeddingConfig.bride} & ${WeddingConfig.groom}',
                              style: LuxText.serif(
                                19,
                                style: FontStyle.italic,
                                color: Lux.dark,
                                weight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Lux.gold.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Lux.gold.withValues(alpha: 0.7),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.restaurant_menu_rounded,
                              size: 15,
                              color: Lux.crimson,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Menu',
                              style: LuxText.serif(
                                12.5,
                                style: FontStyle.normal,
                                color: Lux.crimson,
                                weight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Gold Accent Line
                Container(
                  height: 1.5,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(colors: [
                      Colors.transparent,
                      Lux.gold,
                      Lux.crimson,
                      Lux.gold,
                      Colors.transparent,
                    ]),
                  ),
                ),

                const SizedBox(height: 14),

                // ── Event Day Tabs (Wedding vs Reception) ───────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Lux.dark.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: Lux.gold.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _TabButton(
                            label: 'Wedding Feast',
                            sublabel: '13 Dec · Midnapore',
                            icon: Icons.favorite_rounded,
                            isActive: isWedding,
                            onTap: () => setState(() => _selectedTab = 0),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: _TabButton(
                            label: 'Reception Gala',
                            sublabel: '15 Dec · Haldia',
                            icon: Icons.celebration_rounded,
                            isActive: !isWedding,
                            onTap: () => setState(() => _selectedTab = 1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // ── Stream / Future Menu Items List ─────────────────────────
                Expanded(
                  child: _MenuContent(
                    isWedding: isWedding,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.sublabel,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final String sublabel;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: isActive ? Lux.crimson : Colors.transparent,
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: Lux.crimson.withValues(alpha: 0.28),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
          border: Border.all(
            color: isActive ? Lux.gold : Colors.transparent,
            width: 1.2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 15,
                  color: isActive ? Lux.goldLight : Lux.crimson,
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: LuxText.serif(
                    15,
                    style: FontStyle.normal,
                    weight: isActive ? FontWeight.w700 : FontWeight.w600,
                    color: isActive ? Colors.white : Lux.dark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              sublabel,
              style: LuxText.body(
                11,
                color: isActive ? Lux.champagne : Lux.goldDeep,
                opacity: 0.95,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuContent extends StatelessWidget {
  const _MenuContent({required this.isWedding});
  final bool isWedding;

  @override
  Widget build(BuildContext context) {
    final eventKey = isWedding ? 'wedding' : 'reception';

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('menu')
          .snapshots(),
      builder: (context, snapshot) {
        List<String> items = [];
        bool isPlaceholder = false;

        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          final docs = snapshot.data!.docs;

          // Attempt 1: Check for document ID 'wedding' or 'reception'
          final targetDoc = docs.where((d) => d.id.toLowerCase() == eventKey).firstOrNull;
          if (targetDoc != null && targetDoc.data().containsKey('items')) {
            final rawItems = targetDoc.data()['items'];
            if (rawItems is List) {
              items = rawItems.map((e) => e.toString().trim()).where((s) => s.isNotEmpty).toList();
            }
          }

          // Attempt 2: If no doc by ID, check if docs have an 'event' or 'day' field
          if (items.isEmpty) {
            final matchingDocs = docs.where((d) {
              final ev = (d.data()['event'] ?? d.data()['day'] ?? '').toString().toLowerCase();
              return ev == eventKey || (isWedding && ev.contains('wed')) || (!isWedding && ev.contains('rec'));
            }).toList();

            for (final d in matchingDocs) {
              final val = (d.data()['item'] ?? d.data()['name'] ?? d.data()['title'] ?? '').toString().trim();
              if (val.isNotEmpty) {
                items.add(val);
              }
            }
          }

          // Attempt 3: If still empty, check if docs are simply an ordered list
          if (items.isEmpty) {
            for (final d in docs) {
              final val = (d.data()['item'] ?? d.data()['name'] ?? d.data()['title'] ?? '').toString().trim();
              if (val.isNotEmpty) {
                items.add(val);
              }
            }
          }
        }

        // If Firestore collection has no items yet, provide the traditional Bengali wedding feast placeholder
        if (items.isEmpty) {
          items = isWedding ? _defaultWeddingMenu : _defaultReceptionMenu;
          isPlaceholder = true;
        }

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
          physics: const BouncingScrollPhysics(),
          children: [
            // Banner Card
            GlassPanel(
              radius: 24,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Lux.crimson.withValues(alpha: 0.12),
                          border: Border.all(
                            color: Lux.gold.withValues(alpha: 0.6),
                          ),
                        ),
                        child: const Icon(
                          Icons.soup_kitchen_rounded,
                          color: Lux.crimson,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isWedding
                                  ? 'Traditional Bengali Wedding Bhoj'
                                  : 'Grand Bou Bhaat Gala Dinner',
                              style: LuxText.serif(
                                17,
                                style: FontStyle.normal,
                                weight: FontWeight.w700,
                                color: Lux.crimson,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isWedding
                                  ? 'Midnapore · 13 December 2026'
                                  : 'Haldia · 15 December 2026',
                              style: LuxText.body(
                                12,
                                color: Lux.goldDeep,
                                opacity: 0.9,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (isPlaceholder) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Lux.gold.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.auto_awesome_rounded,
                            size: 14,
                            color: Lux.goldDeep,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Grand Feast Preview (will update live from Firebase)',
                              style: LuxText.serif(
                                12,
                                style: FontStyle.italic,
                                color: Lux.goldDeep,
                                weight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Section Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: Row(
                children: [
                  Container(
                    width: 3,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Lux.crimson,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'CURATED DELICACIES (${items.length} ITEMS)',
                    style: LuxText.eyebrow(Lux.crimson)
                        .copyWith(fontSize: 12, letterSpacing: 2),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // List of menu items in exact collection order
            for (var i = 0; i < items.length; i++)
              _MenuItemTile(
                index: i + 1,
                item: items[i],
              ),

            const SizedBox(height: 20),

            // Footer blessing
            Center(
              child: Text(
                'Aapnar Upasthiti Kamona Kori · #SomKiSayantika',
                style: LuxText.serif(
                  13.5,
                  style: FontStyle.italic,
                  color: Lux.goldDeep,
                  spacing: 1.5,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _MenuItemTile extends StatelessWidget {
  const _MenuItemTile({required this.index, required this.item});
  final int index;
  final String item;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        color: Lux.ivory.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Lux.gold.withValues(alpha: 0.45),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Lux.dark.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Lux.crimson.withValues(alpha: 0.1),
              border: Border.all(
                color: Lux.gold.withValues(alpha: 0.7),
                width: 1,
              ),
            ),
            child: Center(
              child: Text(
                '$index',
                style: LuxText.serif(
                  13,
                  style: FontStyle.normal,
                  weight: FontWeight.w700,
                  color: Lux.crimson,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              item,
              style: LuxText.serif(
                16.5,
                style: FontStyle.normal,
                weight: FontWeight.w600,
                color: Lux.dark,
              ),
            ),
          ),
          const Icon(
            Icons.auto_awesome,
            size: 14,
            color: Lux.gold,
          ),
        ],
      ),
    );
  }
}

// ── Default Authentic Bengali Wedding & Reception Delicacies ─────────────────

const _defaultWeddingMenu = <String>[
  'Welcome Drink · Gandharaj Lebur Shorbot & Rose Cooler',
  'Starters · Crispy Postor Bora & Kolkata Bhetki Fish Fry',
  'Paneer Pasinda with Fresh Coriander Chutney',
  'Koraishutir Kochuri (Green Peas Stuffed Puri)',
  'Chholar Dal with Coconut Slivers & Hing Tadka',
  'Royal Bengali Basanti Pulao with Cashews & Raisins',
  'Bhetki Paturi steamed in fresh Banana Leaf with Mustard Paste',
  'Golda Chingri Malaikari in Creamy Coconut Milk Gravy',
  'Kochi Pathar Jhol · Traditional Bengali Mutton Curry',
  'Aamsotto Khejur Chutney & Roasted Papad',
  'Warm Baked Rosogolla in Earthen Pots',
  'Nolen Gurer Jalbhora Sandesh & Authentic Mishti Doi',
  'Banarasi Pan & Mukhwas',
];

const _defaultReceptionMenu = <String>[
  'Welcome Refreshment · Kesar Badam Milk & Aam Panna Cooler',
  'Starters · Golden Fried Crispy Prawns with Tartar Dip',
  'Gondhoraj Chicken Cutlet with Mustard Kasundi',
  'Dhokar Dalna Croquette & Crispy Mochar Chop',
  'Fluffy Radhaballabhi with Kashmiri Dum Aloo',
  'Authentic Kolkata Mutton Dum Biryani with Golden Potato & Egg',
  'Mughlai Chicken Chaap cooked in Rich Poppy Seed Paste',
  'Katla Kalia · Royal Bengali Fish Delicacy',
  'Navratan Vegetable Korma & Dal Makhani',
  'Pineapple & Plastic Chutney with Crisp Papad',
  'Hot Gulab Jamun served with Rabri',
  'Kacha Golla & Mango Kulfi Ice Cream',
  'Assorted Royal Sweet Paan',
];
