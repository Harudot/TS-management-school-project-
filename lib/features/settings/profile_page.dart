import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ts_management/core/theme/app_theme.dart';
import 'package:ts_management/core/widgets/building_tile.dart';
import 'package:ts_management/core/widgets/section_header.dart';
import 'package:ts_management/core/widgets/settings_tile.dart';
import 'package:ts_management/core/widgets/stat_triple.dart';
import 'package:ts_management/data/models/app_user.dart';
import 'package:ts_management/data/models/building.dart';
import 'package:ts_management/data/repositories/repositories.dart';
import 'package:ts_management/features/auth/auth_providers.dart';
import 'package:ts_management/features/dashboard/home_page.dart'
    show allBuildingsProvider;

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});
  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  void _openEdit(AppUser? user) {
    final nameCtrl = TextEditingController(text: user?.name ?? '');
    final formKey = GlobalKey<FormState>();
    bool saving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => StatefulBuilder(
        builder: (sheetCtx, setSheetState) => Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(sheetCtx).viewInsets.bottom),
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFF1A1A22),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 36),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Handle
                  Center(
                    child: Container(
                      width: 40, height: 4,
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Edit Profile',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
                  const SizedBox(height: 4),
                  const Text('Change your display name.',
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                  const SizedBox(height: 22),

                  // Name field
                  TextFormField(
                    controller: nameCtrl,
                    textCapitalization: TextCapitalization.words,
                    autofocus: true,
                    style: const TextStyle(color: AppTheme.textPrimary),
                    decoration: InputDecoration(
                      labelText: 'Display Name',
                      labelStyle: const TextStyle(color: AppTheme.textSecondary),
                      prefixIcon: const Icon(Icons.person_outline_rounded, color: AppTheme.textSecondary),
                      filled: true,
                      fillColor: AppTheme.surfaceVariant,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
                      ),
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Name cannot be empty' : null,
                  ),
                  const SizedBox(height: 12),

                  // Email (read-only)
                  if (user?.email.isNotEmpty == true)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(children: [
                        const Icon(Icons.mail_outline_rounded,
                            size: 20, color: AppTheme.textSecondary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            const Text('Email',
                                style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                            Text(user!.email,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 14,
                                    color: AppTheme.textPrimary)),
                          ]),
                        ),
                      ]),
                    ),
                  const SizedBox(height: 24),

                  // Save button
                  FilledButton(
                    onPressed: saving
                        ? null
                        : () async {
                            if (!formKey.currentState!.validate()) return;
                            if (user == null) return;
                            final newName = nameCtrl.text.trim();
                            setSheetState(() => saving = true);
                            try {
                              // Use ref from the outer ConsumerState — always valid
                              final repo = ref.read(usersRepositoryProvider);
                              await repo.upsert(AppUser(
                                uid: user.uid,
                                name: newName,
                                email: user.email,
                                photoUrl: user.photoUrl,
                                role: user.role,
                                themePreference: user.themePreference,
                                fcmToken: user.fcmToken,
                                followedBuildings: user.followedBuildings,
                              ));
                              if (mounted) {
                                Navigator.pop(sheetCtx);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text('Profile updated!'),
                                    backgroundColor: AppTheme.success,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12)),
                                  ),
                                );
                              }
                            } catch (e) {
                              setSheetState(() => saving = false);
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error: $e'),
                                    backgroundColor: AppTheme.danger,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            }
                          },
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: AppTheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: saving
                        ? const SizedBox(
                            width: 20, height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Text('Save changes',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider).asData?.value;
    final isAdmin = ref.watch(isAdminProvider).asData?.value ?? false;
    final buildings =
        ref.watch(allBuildingsProvider).asData?.value ?? const <Building>[];
    final followedIds = user?.followedBuildings ?? const <String>[];
    final followed = buildings.where((b) => followedIds.contains(b.id)).toList();
    final initial =
        (user?.name.isNotEmpty == true ? user!.name[0] : 'U').toUpperCase();

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          Row(children: [
            const Text('Profile',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            const Spacer(),
            GestureDetector(
              onTap: () => _openEdit(user),
              child: Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.surfaceVariant),
                ),
                child: const Icon(Icons.edit_outlined,
                    size: 18, color: AppTheme.textPrimary),
              ),
            ),
          ]),
          const SizedBox(height: 22),
          Center(
            child: Column(children: [
              GestureDetector(
                onTap: () => _openEdit(user),
                child: Stack(children: [
                  Container(
                    width: 70, height: 70,
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(
                        color: AppTheme.primary.withValues(alpha: 0.3),
                        blurRadius: 16, offset: const Offset(0, 4),
                      )],
                    ),
                    child: Center(child: Text(initial,
                        style: const TextStyle(
                            color: AppTheme.onPrimary,
                            fontSize: 26, fontWeight: FontWeight.w800))),
                  ),
                  Positioned(
                    bottom: 0, right: 0,
                    child: Container(
                      width: 22, height: 22,
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceVariant,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.bg, width: 2),
                      ),
                      child: const Icon(Icons.edit_rounded,
                          size: 11, color: AppTheme.textSecondary),
                    ),
                  ),
                ]),
              ),
              const SizedBox(height: 12),
              Text(user?.name ?? '—',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(user?.email ?? '',
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 13)),
            ]),
          ),
          const SizedBox(height: 22),
          StatTriple(items: [
            (value: '${followed.length}', label: 'Following'),
            (value: '0', label: 'Saved places'),
            (value: '0', label: 'Visits / month'),
          ]),
          const SizedBox(height: 22),
          SectionHeader(title: 'Followed buildings'),
          const SizedBox(height: 10),
          if (followed.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 18),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(AppTheme.cardRadius),
              ),
              child: const Text('No followed buildings yet',
                  style: TextStyle(color: AppTheme.textSecondary)),
            )
          else
            for (final b in followed)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: BuildingTile(
                  compact: true,
                  name: b.name,
                  subtitle: '${b.floorCount} floors · Campus',
                  statusLabel: 'Inside',
                  statusColor: AppTheme.success,
                  onTap: () => context.push('/building/${b.id}'),
                ),
              ),
          const SizedBox(height: 22),
          SectionHeader(title: 'Settings'),
          const SizedBox(height: 10),
          SettingsGroup(children: [
            SettingsTile(
              icon: Icons.notifications_outlined,
              iconColor: AppTheme.primary,
              title: 'Notifications',
              value: 'On',
              onTap: () => context.push('/settings/notifications'),
            ),
            SettingsTile(
              icon: Icons.language_rounded,
              iconColor: AppTheme.success,
              title: 'Language',
              value: 'English',
              onTap: () => context.push('/settings/language'),
            ),
            SettingsTile(
              icon: Icons.dark_mode_rounded,
              iconColor: AppTheme.live,
              title: 'Appearance',
              value: 'Dark',
              onTap: () => context.push('/settings'),
            ),
            SettingsTile(
              icon: Icons.accessibility_rounded,
              iconColor: AppTheme.warning,
              title: 'Accessibility',
              onTap: () => context.push('/settings/accessibility'),
            ),
            SettingsTile(
              icon: Icons.lock_outline_rounded,
              iconColor: AppTheme.textSecondary,
              title: 'Privacy',
              onTap: () => context.push('/settings/privacy'),
            ),
            SettingsTile(
              icon: Icons.help_outline_rounded,
              iconColor: AppTheme.primary,
              title: 'Help & feedback',
              onTap: () => context.push('/settings/help'),
            ),
            if (isAdmin)
              SettingsTile(
                icon: Icons.admin_panel_settings_rounded,
                iconColor: AppTheme.primary,
                title: 'Admin Dashboard',
                onTap: () => context.go('/admin/overview'),
              ),
          ]),
          const SizedBox(height: 14),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(AppTheme.cardRadius),
            ),
            child: SettingsTile(
              icon: Icons.logout_rounded,
              iconColor: AppTheme.danger,
              title: 'Sign out',
              danger: true,
              onTap: () => ref.read(authServiceProvider).signOut(),
            ),
          ),
          const SizedBox(height: 22),
          const Center(
            child: Text('Smart Campus v1.0.0',
                style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
