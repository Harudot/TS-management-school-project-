import 'package:flutter/material.dart';
import 'package:ts_management/services/auth_service.dart';
import 'package:ts_management/screens/login_screen.dart';
import 'package:ts_management/widgets/home_widgets/home_notifications.dart';
import 'package:ts_management/screens/student_detail_screen.dart';

class OxalisAppBar extends StatefulWidget {
  const OxalisAppBar({
    super.key,
    required this.subtitle,
    this.showBack = false,
    this.onMenuTap,
    this.notifications = const [],
  });

  final String subtitle;
  final bool showBack;
  final VoidCallback? onMenuTap;
  final List<NotificationItem> notifications;

  @override
  State<OxalisAppBar> createState() => _OxalisAppBarState();
}

class _OxalisAppBarState extends State<OxalisAppBar> {
  // Notification overlay
  final _bellLayerLink = LayerLink();
  OverlayEntry? _notifOverlay;

  // Menu state
  bool _menuOpen = false;

  // Which accordion section is open inside the menu (null = none)
  int? _openSection;

  // ── Static menu data ─────────────────────

  static const _sections = [
    ('Оюутан', Icons.person_outline_rounded),
    ('Хичээл', Icons.book_outlined),
    ('Тодорхойлолт', Icons.language_outlined),
  ];

  static const _sectionOptions = [
    [
      'Хувийн мэдээлэл',
      'Сурлагын төлөвлөгөө',
      'Сорил явцын оноо',
      'Дүнгийн мэдээлэл',
      'E, U шалгалтын хураарь',
    ],
    ['Хичээл сонголт 1', 'Хичээл сонголт 2'],
    ['Монгол', 'English'],
  ];

  // ── helpers ──────────────────────────────

  String _initials() {
    final name = AuthService.currentUser?.name ?? '';
    final parts = name.trim().split(' ');
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  // ── notification overlay ─────────────────

  void _toggleNotifications() {
    if (_menuOpen)
      setState(() {
        _menuOpen = false;
        _openSection = null;
      });
    if (_notifOverlay != null) {
      _closeNotifications();
      return;
    }

    _notifOverlay = OverlayEntry(
      builder: (_) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _closeNotifications,
            ),
          ),
          CompositedTransformFollower(
            link: _bellLayerLink,
            showWhenUnlinked: false,
            offset: const Offset(-224, 44),
            child: Material(
              color: Colors.transparent,
              child: _NotificationDropdown(notifications: widget.notifications),
            ),
          ),
        ],
      ),
    );
    Overlay.of(context, rootOverlay: true).insert(_notifOverlay!);
    setState(() {});
  }

  void _closeNotifications() {
    _notifOverlay?.remove();
    _notifOverlay = null;
    if (mounted) setState(() {});
  }

  // ── menu toggle ──────────────────────────

  void _toggleMenu() {
    _closeNotifications();
    setState(() {
      _menuOpen = !_menuOpen;
      if (!_menuOpen) _openSection = null;
    });
  }

  // ── profile sheet ────────────────────────

  void _openProfileSheet() {
    _closeNotifications();
    setState(() {
      _menuOpen = false;
      _openSection = null;
    });
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (_) => _ProfileSheet(parentContext: context),
    );
  }

  @override
  void dispose() {
    _notifOverlay?.remove();
    _notifOverlay = null;
    super.dispose();
  }

  // ── build ────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final bellActive = _notifOverlay != null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Top row ──────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
          child: Row(
            children: [
              // Menu / back button
              if (widget.showBack)
                _PressScale(
                  onTap: () => Navigator.pop(context),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      children: [
                        Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white.withOpacity(0.7),
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Back',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                _PressScale(
                  onTap: _toggleMenu,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _menuOpen
                          ? const Color(0xFF7340E8).withOpacity(0.25)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      transitionBuilder: (child, anim) => RotationTransition(
                        turns: Tween(begin: 0.1, end: 0.0).animate(anim),
                        child: FadeTransition(opacity: anim, child: child),
                      ),
                      child: Icon(
                        _menuOpen ? Icons.close_rounded : Icons.menu_rounded,
                        key: ValueKey(_menuOpen),
                        color: _menuOpen
                            ? const Color(0xFF9B6BFF)
                            : Colors.white.withOpacity(0.7),
                        size: 24,
                      ),
                    ),
                  ),
                ),

              // Center title
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Oxalis Hub',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      widget.subtitle,
                      style: const TextStyle(
                        color: Color(0x73FFFFFF),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              // Bell + avatar
              Row(
                children: [
                  CompositedTransformTarget(
                    link: _bellLayerLink,
                    child: _PressScale(
                      onTap: _toggleNotifications,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: bellActive
                              ? const Color(0xFF7340E8).withOpacity(0.85)
                              : const Color(0xFF1E0D3A).withOpacity(0.9),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: bellActive
                                ? const Color(0xFF9B6BFF).withOpacity(0.6)
                                : Colors.white.withOpacity(0.08),
                          ),
                        ),
                        child: Stack(
                          children: [
                            Center(
                              child: Icon(
                                bellActive
                                    ? Icons.notifications_rounded
                                    : Icons.notifications_outlined,
                                color: bellActive
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.7),
                                size: 20,
                              ),
                            ),
                            if (!bellActive && widget.notifications.isNotEmpty)
                              Positioned(
                                top: 6,
                                right: 6,
                                child: Container(
                                  width: 7,
                                  height: 7,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF9B6BFF),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  _PressScale(
                    onTap: _openProfileSheet,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFF7340E8),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFF9B6BFF).withOpacity(0.5),
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          _initials(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // ── Slide-down menu panel ─────────────
        if (!widget.showBack)
          AnimatedSize(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeInOut,
            child: _menuOpen
                ? Container(
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF150828),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white.withOpacity(0.08)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ── Accordion sections ─────────
                            ...List.generate(_sections.length, (i) {
                              final (label, icon) = _sections[i];
                              final isOpen = _openSection == i;
                              return Column(
                                children: [
                                  // Section header
                                  _PressScale(
                                    onTap: () => setState(
                                      () => _openSection = isOpen ? null : i,
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 11,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isOpen
                                            ? const Color(
                                                0xFF7340E8,
                                              ).withOpacity(0.2)
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(12),
                                        border: isOpen
                                            ? Border.all(
                                                color: const Color(
                                                  0xFF9B6BFF,
                                                ).withOpacity(0.3),
                                              )
                                            : null,
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 30,
                                            height: 30,
                                            decoration: BoxDecoration(
                                              color: isOpen
                                                  ? const Color(
                                                      0xFF7340E8,
                                                    ).withOpacity(0.4)
                                                  : const Color(
                                                      0xFF7B4FD4,
                                                    ).withOpacity(0.15),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Icon(
                                              icon,
                                              color: isOpen
                                                  ? Colors.white
                                                  : const Color(0xFF9B6BFF),
                                              size: 16,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              label,
                                              style: TextStyle(
                                                color: isOpen
                                                    ? Colors.white
                                                    : Colors.white.withOpacity(
                                                        0.8,
                                                      ),
                                                fontSize: 14,
                                                fontWeight: isOpen
                                                    ? FontWeight.w600
                                                    : FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                          AnimatedRotation(
                                            turns: isOpen ? 0.5 : 0,
                                            duration: const Duration(
                                              milliseconds: 200,
                                            ),
                                            child: Icon(
                                              Icons.expand_more_rounded,
                                              color: isOpen
                                                  ? const Color(0xFF9B6BFF)
                                                  : Colors.white.withOpacity(
                                                      0.3,
                                                    ),
                                              size: 18,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  // Section content
                                  AnimatedSize(
                                    duration: const Duration(milliseconds: 220),
                                    curve: Curves.easeOut,
                                    child: isOpen
                                        ? Padding(
                                            padding: const EdgeInsets.only(
                                              top: 8,
                                              bottom: 4,
                                            ),
                                            child: Column(
                                              children: [
                                                ..._sectionOptions[i].asMap().entries.map(
                                                  (e) => _MenuOptionTile(
                                                    label: e.value,
                                                    onTap:
                                                        (i == 0 && e.key == 0)
                                                        ? () {
                                                            setState(() {
                                                              _menuOpen = false;
                                                              _openSection =
                                                                  null;
                                                            });
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder: (_) =>
                                                                    const StudentDetailScreen(),
                                                              ),
                                                            );
                                                          }
                                                        : null,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        : const SizedBox.shrink(),
                                  ),

                                  if (i < _sections.length - 1)
                                    Divider(
                                      color: Colors.white.withOpacity(0.06),
                                      height: 12,
                                    ),
                                ],
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Menu option tile
// ─────────────────────────────────────────────

class _MenuOptionTile extends StatelessWidget {
  const _MenuOptionTile({required this.label, this.onTap});
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap ?? () {},
          splashColor: const Color(0xFF7340E8).withOpacity(0.15),
          highlightColor: const Color(0xFF7340E8).withOpacity(0.08),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 5,
                  height: 5,
                  decoration: const BoxDecoration(
                    color: Color(0xFF9B6BFF),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.75),
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.white.withOpacity(0.25),
                  size: 15,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Press scale feedback wrapper
// ─────────────────────────────────────────────

class _PressScale extends StatefulWidget {
  const _PressScale({required this.child, required this.onTap});
  final Widget child;
  final VoidCallback onTap;

  @override
  State<_PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<_PressScale> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.85 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Notification Dropdown (overlay)
// ─────────────────────────────────────────────

class _NotificationDropdown extends StatelessWidget {
  const _NotificationDropdown({required this.notifications});
  final List<NotificationItem> notifications;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      constraints: const BoxConstraints(maxHeight: 360),
      decoration: BoxDecoration(
        color: const Color(0xFF1E0D3A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.55),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
              child: Row(
                children: [
                  Text(
                    'NOTIFICATIONS',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.45),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF9B6BFF).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${notifications.length}',
                      style: const TextStyle(
                        color: Color(0xFF9B6BFF),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(color: Colors.white.withOpacity(0.06), height: 1),
            Flexible(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 6),
                shrinkWrap: true,
                itemCount: notifications.length,
                separatorBuilder: (_, __) => Divider(
                  color: Colors.white.withOpacity(0.05),
                  height: 1,
                  indent: 14,
                  endIndent: 14,
                ),
                itemBuilder: (_, i) {
                  final n = notifications[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 9,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: const Color(0xFF7B4FD4).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: Icon(
                            n.icon,
                            color: const Color(0xFF9B6BFF),
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                n.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                n.subtitle,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.45),
                                  fontSize: 11,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 3),
                              Text(
                                n.time,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.3),
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Profile Sheet
// ─────────────────────────────────────────────

class _ProfileSheet extends StatefulWidget {
  const _ProfileSheet({required this.parentContext});
  final BuildContext parentContext;

  @override
  State<_ProfileSheet> createState() => _ProfileSheetState();
}

class _ProfileSheetState extends State<_ProfileSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _bioCtrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final u = AuthService.currentUser;
    _nameCtrl = TextEditingController(text: u?.name ?? '');
    _emailCtrl = TextEditingController(text: u?.email ?? '');
    _phoneCtrl = TextEditingController(text: u?.phone ?? '');
    _bioCtrl = TextEditingController(text: u?.bio ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    await AuthService.updateProfile(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      bio: _bioCtrl.text.trim(),
    );
    if (!mounted) return;
    setState(() => _saving = false);
    Navigator.pop(context);
    ScaffoldMessenger.of(widget.parentContext).showSnackBar(
      SnackBar(
        content: const Text('Profile updated'),
        backgroundColor: const Color(0xFF43E97B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _logout() async {
    await AuthService.signOut();
    if (!mounted) return;
    Navigator.pop(context);
    Navigator.of(widget.parentContext).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  String _initials() {
    final name = _nameCtrl.text.trim();
    final parts = name.split(' ');
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0.5, -0.8),
          radius: 1.2,
          colors: [Color(0xFF3D1A6E), Color(0xFF1E0D3A), Color(0xFF12071F)],
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xFF7340E8),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFF9B6BFF).withOpacity(0.5),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      _initials(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
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
                        _nameCtrl.text.isEmpty
                            ? 'Your Profile'
                            : _nameCtrl.text,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        _emailCtrl.text,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.45),
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Column(
                children: [
                  _Field(
                    label: 'Full name',
                    controller: _nameCtrl,
                    icon: Icons.person_outline_rounded,
                  ),
                  const SizedBox(height: 12),
                  _Field(
                    label: 'Email',
                    controller: _emailCtrl,
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 12),
                  _Field(
                    label: 'Phone number',
                    controller: _phoneCtrl,
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 12),
                  _Field(
                    label: 'Bio',
                    controller: _bioCtrl,
                    icon: Icons.edit_note_rounded,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _saving ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7340E8),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: _saving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Save changes',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: _logout,
                      icon: const Icon(Icons.logout_rounded, size: 18),
                      label: const Text(
                        'Log out',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFFF6B6B),
                        side: const BorderSide(
                          color: Color(0xFFFF6B6B),
                          width: 1.2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
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

// ─────────────────────────────────────────────
// Reusable text field
// ─────────────────────────────────────────────

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.controller,
    required this.icon,
    this.keyboardType,
    this.maxLines = 1,
  });

  final String label;
  final TextEditingController controller;
  final IconData icon;
  final TextInputType? keyboardType;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 12,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1E0D3A).withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.07)),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              prefixIcon: Icon(
                icon,
                color: Colors.white.withOpacity(0.35),
                size: 18,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 13,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
