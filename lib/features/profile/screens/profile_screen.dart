import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/glassmorphism_card.dart';
import '../../activity/providers/activity_provider.dart';
import '../../chat/providers/chat_provider.dart';
import '../../home/providers/home_provider.dart';
import '../providers/profile_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  late final Future<String> _appVersionFuture;

  @override
  void initState() {
    super.initState();
    _appVersionFuture = _loadAppVersion();
  }

  @override
  Widget build(BuildContext context) {
    final ProfileState profile = ref.watch(profileControllerProvider);
    final AsyncValue<UserProfileInfo> userInfo =
        ref.watch(userProfileInfoProvider);
    final AsyncValue<WeeklySummaryData> summary =
        ref.watch(weeklySummaryProvider);
    final AsyncValue<List<AchievementStatus>> achievements =
        ref.watch(achievementsProvider);
    final WeeklySummaryData? summaryData = summary.valueOrNull;
    final UserProfileInfo? userInfoData = userInfo.valueOrNull;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: <Widget>[
          const _ProfileBackgroundGlow(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  userInfo.when(
                    data: (UserProfileInfo info) => _HeroHeader(
                      info: info,
                      avgDailySteps: summaryData?.avgDailySteps,
                      onAvatarTap: _pickAndSaveProfilePhoto,
                      onEditTap: () => _showEditProfileSheet(info),
                    ),
                    loading: () => const SizedBox(
                      height: 240,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                  if (summaryData != null) ...<Widget>[
                    const SizedBox(height: 16),
                    _WeeklySnapshotCard(
                      data: summaryData,
                      userInfo: userInfoData,
                    ),
                  ],
                  const SizedBox(height: 24),
                  summary.when(
                    data: (WeeklySummaryData data) => _HealthProfileSection(
                      userInfo: userInfo.value,
                      avgDailySteps: data.avgDailySteps,
                      onAddTap: () {
                        if (userInfo.value != null) {
                          _showEditProfileSheet(userInfo.value!);
                        }
                      },
                    ),
                    loading: () => const SizedBox(
                      height: 120,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 24),
                  summary.when(
                    data: (WeeklySummaryData data) =>
                        _WeeklySummarySection(data: data),
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 24),
                  achievements.when(
                    data: (List<AchievementStatus> data) =>
                        _AchievementsSection(
                      achievements: data,
                      onSeeAll: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) =>
                                AchievementsScreen(achievements: data),
                          ),
                        );
                      },
                      onTapAchievement: _showAchievementDialog,
                    ),
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 24),
                  _SettingsSection(
                    profile: profile,
                    appVersionFuture: _appVersionFuture,
                    onDailyGoalChange: (int goal) => ref
                        .read(profileControllerProvider.notifier)
                        .setDailyGoal(goal),
                    onDemoModeChange: (bool enabled) {
                      ref
                          .read(profileControllerProvider.notifier)
                          .setDemoMode(enabled);
                      ref.read(demomodeProvider.notifier).state = enabled;
                      ref.invalidate(homeControllerProvider);
                      ref.invalidate(activityProvider);
                      ref.invalidate(weeklySummaryProvider);
                    },
                    onNotificationsChange: (bool enabled) => ref
                        .read(profileControllerProvider.notifier)
                        .setNotificationsEnabled(enabled),
                    onWaterReminderChange: (int minutes) => ref
                        .read(profileControllerProvider.notifier)
                        .setWaterReminder(minutes),
                    onStepUnitChange: (StepUnit unit) => ref
                        .read(profileControllerProvider.notifier)
                        .setStepUnit(unit),
                    onExportData: () {
                      _exportHealthData();
                    },
                    onClearChat: () {
                      ref.read(chatControllerProvider.notifier).clearMessages();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Chat history cleared.')),
                      );
                    },
                    onDeleteAccount: () {
                      _confirmDeleteAccount();
                    },
                    onRateApp: () {
                      _launchExternal(
                        Uri.parse(
                            'https://play.google.com/store/apps/details?id=com.wearsync.app'),
                      );
                    },
                    onPrivacyPolicy: () {
                      _launchExternal(
                          Uri.parse('https://wearsync.app/privacy'));
                    },
                    onContactSupport: () {
                      _launchExternal(
                        Uri.parse(
                            'mailto:support@wearsync.app?subject=WearSync%20Support'),
                      );
                    },
                    onSignOut: () {
                      _showSignOutConfirmation();
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<String> _loadAppVersion() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    return 'WearSync v${info.version} (build ${info.buildNumber})';
  }

  Future<void> _pickAndSaveProfilePhoto() async {
    final XFile? file = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (file == null) {
      return;
    }

    final String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return;
    }

    await FirebaseFirestore.instance.collection('users').doc(uid).set(
      <String, dynamic>{
        'photoURL': file.path,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    ref.invalidate(userProfileInfoProvider);
  }

  Future<void> _showEditProfileSheet(UserProfileInfo info) async {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final TextEditingController nameController =
        TextEditingController(text: info.displayName);
    final TextEditingController ageController =
        TextEditingController(text: info.age?.toString() ?? '');
    final TextEditingController weightController =
        TextEditingController(text: info.weightKg?.toStringAsFixed(1) ?? '');
    final TextEditingController heightController =
        TextEditingController(text: info.heightCm?.toStringAsFixed(1) ?? '');

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      builder: (BuildContext context) {
        bool isSaving = false;
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text('Edit Profile',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
                    _DarkField(
                      controller: nameController,
                      label: 'Display Name',
                      validator: (String? value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Display name is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    _DarkField(
                      controller: ageController,
                      label: 'Age',
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 10),
                    _DarkField(
                      controller: weightController,
                      label: 'Weight (kg)',
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                    ),
                    const SizedBox(height: 10),
                    _DarkField(
                      controller: heightController,
                      label: 'Height (cm)',
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isSaving
                            ? null
                            : () async {
                                if (!formKey.currentState!.validate()) {
                                  return;
                                }

                                final String? uid =
                                    FirebaseAuth.instance.currentUser?.uid;
                                if (uid == null) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(this.context)
                                        .showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'You are not signed in. Please login again.'),
                                      ),
                                    );
                                  }
                                  return;
                                }

                                final String displayName =
                                    nameController.text.trim();
                                final int? age =
                                    int.tryParse(ageController.text.trim());
                                final double? weightKg = double.tryParse(
                                    weightController.text.trim());
                                final double? heightCm = double.tryParse(
                                    heightController.text.trim());

                                final Map<String, dynamic> payload =
                                    <String, dynamic>{
                                  'displayName': displayName,
                                  'updatedAt': FieldValue.serverTimestamp(),
                                  'age': age ?? FieldValue.delete(),
                                  'weightKg': weightKg ?? FieldValue.delete(),
                                  'heightCm': heightCm ?? FieldValue.delete(),
                                };
                                final NavigatorState bottomSheetNavigator =
                                    Navigator.of(context);

                                setState(() => isSaving = true);
                                bool didCloseSheet = false;
                                try {
                                  final Future<void> firestoreWrite =
                                      FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(uid)
                                          .set(
                                              payload, SetOptions(merge: true));

                                  bool firestoreSynced = false;
                                  try {
                                    await firestoreWrite
                                        .timeout(const Duration(seconds: 3));
                                    firestoreSynced = true;
                                  } on TimeoutException {
                                    // Continue without blocking the UI. Keep syncing in background.
                                    unawaited(
                                      firestoreWrite.then((_) {
                                        if (!mounted) {
                                          return;
                                        }
                                        ref.invalidate(userProfileInfoProvider);
                                      }).catchError((_) {}),
                                    );
                                  }

                                  // Keep auth profile sync best-effort so UI save never hangs.
                                  try {
                                    await FirebaseAuth.instance.currentUser
                                        ?.updateDisplayName(displayName)
                                        .timeout(const Duration(seconds: 6));
                                  } catch (_) {}

                                  if (!mounted) {
                                    return;
                                  }

                                  didCloseSheet = true;
                                  bottomSheetNavigator.pop();
                                  ref.invalidate(userProfileInfoProvider);
                                  ScaffoldMessenger.of(this.context)
                                      .showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        firestoreSynced
                                            ? 'Profile updated successfully.'
                                            : 'Profile saved. Syncing to cloud...',
                                      ),
                                    ),
                                  );
                                } catch (error) {
                                  if (!mounted) {
                                    return;
                                  }
                                  ScaffoldMessenger.of(this.context)
                                      .showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Failed to save profile: $error'),
                                    ),
                                  );
                                } finally {
                                  if (!didCloseSheet) {
                                    setState(() => isSaving = false);
                                  }
                                }
                              },
                        child: isSaving
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Save Changes'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _exportHealthData() async {
    final String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return;
    }

    final DateTime start = DateTime.now().subtract(const Duration(days: 30));
    final String filter = DateFormat('yyyy-MM-dd').format(start);
    final QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection('users')
        .doc(uid)
        .collection('health')
        .where('date', isGreaterThanOrEqualTo: filter)
        .get();

    final StringBuffer csv =
        StringBuffer('date,steps,calories,heartRate,water\n');
    for (final QueryDocumentSnapshot<Map<String, dynamic>> doc
        in snapshot.docs) {
      final Map<String, dynamic> data = doc.data();
      final String date = (data['date'] as String?) ?? doc.id;
      final int steps = (data['steps'] as num?)?.toInt() ?? 0;
      final int calories = (data['calories'] as num?)?.toInt() ?? 0;
      final int heartRate = (data['heartRate'] as num?)?.toInt() ?? 0;
      final int water =
          ((data['water'] ?? data['waterGlasses']) as num?)?.toInt() ?? 0;
      csv.writeln('$date,$steps,$calories,$heartRate,$water');
    }

    Directory target;
    if (Platform.isAndroid) {
      target = Directory('/storage/emulated/0/Download');
      if (!await target.exists()) {
        target = await getApplicationDocumentsDirectory();
      }
    } else {
      target = await getApplicationDocumentsDirectory();
    }

    final File output = File('${target.path}/wearsync_health.csv');
    await output.writeAsString(csv.toString());

    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Data exported to Downloads/wearsync_health.csv')),
    );
  }

  Future<void> _confirmDeleteAccount() async {
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTheme.surface,
          title: const Text('Delete Account'),
          content: const Text(
            'This will permanently delete your account and all health data. This cannot be undone.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete Forever'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    final User? user = FirebaseAuth.instance.currentUser;
    final String? uid = user?.uid;
    if (uid == null) {
      return;
    }

    Future<void> deleteCollection(
        CollectionReference<Map<String, dynamic>> col) async {
      final QuerySnapshot<Map<String, dynamic>> snap = await col.get();
      for (final QueryDocumentSnapshot<Map<String, dynamic>> doc in snap.docs) {
        await doc.reference.delete();
      }
    }

    try {
      await deleteCollection(
        FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('health'),
      );
      await deleteCollection(
        FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('achievements'),
      );
      await deleteCollection(
        FirebaseFirestore.instance
            .collection('workouts')
            .doc(uid)
            .collection('sessions'),
      );

      await FirebaseFirestore.instance.collection('workouts').doc(uid).delete();
      await FirebaseFirestore.instance.collection('users').doc(uid).delete();
      await user!.delete();

      if (!mounted) {
        return;
      }
      context.go('/login');
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Delete failed: $error')),
      );
    }
  }

  Future<void> _launchExternal(Uri uri) async {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _showSignOutConfirmation() async {
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        bool isProcessing = false;
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              backgroundColor: AppTheme.surface,
              title: const Text('Sign Out?'),
              content: const Text(
                "You'll need to sign in again to access your health data.",
              ),
              actions: <Widget>[
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF334155)),
                  ),
                  onPressed: isProcessing
                      ? null
                      : () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF4444),
                  ),
                  onPressed: isProcessing
                      ? null
                      : () async {
                          final NavigatorState dialogNavigator =
                              Navigator.of(dialogContext);
                          setState(() => isProcessing = true);
                          await FirebaseAuth.instance.signOut();
                          if (!mounted) {
                            return;
                          }
                          ref.invalidate(homeControllerProvider);
                          ref.invalidate(activityProvider);
                          ref.invalidate(chatControllerProvider);
                          ref.invalidate(profileControllerProvider);
                          ref.invalidate(weeklySummaryProvider);
                          ref.invalidate(userProfileInfoProvider);
                          dialogNavigator.pop();
                          this.context.go('/login');
                        },
                  child: isProcessing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Sign Out'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAchievementDialog(AchievementStatus achievement) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTheme.surface,
          title: Text('${achievement.emoji} ${achievement.name}'),
          content: Text(
            achievement.earnedAt == null
                ? achievement.description
                : 'Earned on ${DateFormat('MMM d, yyyy').format(achievement.earnedAt!)}\n\n${achievement.description}',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({
    required this.info,
    required this.avgDailySteps,
    required this.onAvatarTap,
    required this.onEditTap,
  });

  final UserProfileInfo info;
  final int? avgDailySteps;
  final VoidCallback onAvatarTap;
  final VoidCallback onEditTap;

  @override
  Widget build(BuildContext context) {
    final String initials = info.displayName
        .split(' ')
        .where((String p) => p.trim().isNotEmpty)
        .take(2)
        .map((String p) => p[0].toUpperCase())
        .join();
    final String memberSince = DateFormat('MMMM yyyy').format(info.memberSince);
    final bool hasPhoto = info.photoUrl.isNotEmpty;
    final bool hasLocalPhoto = hasPhoto && File(info.photoUrl).existsSync();

    final ImageProvider? avatarImage = !hasPhoto
        ? null
        : (hasLocalPhoto
            ? FileImage(File(info.photoUrl)) as ImageProvider
            : NetworkImage(info.photoUrl));

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Color(0xFF172554),
            Color(0xFF0F172A),
            Color(0xFF111827)
          ],
        ),
        border:
            Border.all(color: const Color(0xFF334155).withValues(alpha: 0.6)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: const Color(0xFF020617).withValues(alpha: 0.4),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Stack(
        children: <Widget>[
          Positioned(
            right: -30,
            top: -24,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF22D3EE).withValues(alpha: 0.09),
              ),
            ),
          ),
          Positioned(
            left: -40,
            bottom: -34,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF6366F1).withValues(alpha: 0.08),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  _ProfilePill(
                    icon: Icons.verified_rounded,
                    label: 'Member since',
                    value: memberSince,
                  ),
                  const Spacer(),
                  FilledButton.tonalIcon(
                    onPressed: onEditTap,
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text('Edit'),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  GestureDetector(
                    onTap: onAvatarTap,
                    child: Container(
                      width: 92,
                      height: 92,
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: <Color>[Color(0xFF22D3EE), Color(0xFF6366F1)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color:
                                const Color(0xFF22D3EE).withValues(alpha: 0.18),
                            blurRadius: 18,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF0F172A),
                          image: avatarImage == null
                              ? null
                              : DecorationImage(
                                  image: avatarImage, fit: BoxFit.cover),
                        ),
                        child: avatarImage == null
                            ? Center(
                                child: Text(
                                  initials.isEmpty ? 'U' : initials,
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              )
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          info.displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          info.email,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Tap the avatar to change your photo.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: <Widget>[
                  if (info.age != null)
                    _ProfileStatChip(
                      label: 'Age',
                      value: '${info.age}',
                      icon: Icons.cake_outlined,
                    ),
                  if (info.weightKg != null)
                    _ProfileStatChip(
                      label: 'Weight',
                      value: '${info.weightKg!.toStringAsFixed(1)} kg',
                      icon: Icons.monitor_weight_outlined,
                    ),
                  if (info.heightCm != null)
                    _ProfileStatChip(
                      label: 'Height',
                      value: '${info.heightCm!.toStringAsFixed(1)} cm',
                      icon: Icons.height_outlined,
                    ),
                  if (avgDailySteps != null)
                    _ProfileStatChip(
                      label: 'Avg steps',
                      value: '$avgDailySteps',
                      icon: Icons.directions_walk_rounded,
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileBackgroundGlow extends StatelessWidget {
  const _ProfileBackgroundGlow();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: <Widget>[
          Positioned(
            top: -90,
            left: -40,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: <Color>[
                    const Color(0xFF6366F1).withValues(alpha: 0.18),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 240,
            right: -60,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: <Color>[
                    const Color(0xFF22D3EE).withValues(alpha: 0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileStatChip extends StatelessWidget {
  const _ProfileStatChip({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: const Color(0xFF334155).withValues(alpha: 0.8)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 16, color: const Color(0xFF22D3EE)),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xFF94A3B8),
                  height: 1.1,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 1.15,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WeeklySnapshotCard extends StatelessWidget {
  const _WeeklySnapshotCard({
    required this.data,
    required this.userInfo,
  });

  final WeeklySummaryData data;
  final UserProfileInfo? userInfo;

  @override
  Widget build(BuildContext context) {
    final double? bmi = _bmi(userInfo?.weightKg, userInfo?.heightCm);
    final _BmiInfo bmiInfo = _bmiInfo(bmi);

    return GlassmorphismCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const _SectionHeader(
            title: 'Weekly Snapshot',
            subtitle: 'A quick overview of your activity and body metrics.',
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final bool compact = constraints.maxWidth < 330;
              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children: <Widget>[
                  _SnapshotTile(
                    icon: Icons.directions_walk_rounded,
                    label: 'Average steps',
                    value: '${data.avgDailySteps}',
                    accent: const Color(0xFF6366F1),
                    compact: compact,
                  ),
                  _SnapshotTile(
                    icon: Icons.emoji_events_outlined,
                    label: 'Best day',
                    value: '${data.bestDay}',
                    accent: const Color(0xFFFBBF24),
                    compact: compact,
                  ),
                  _SnapshotTile(
                    icon: Icons.favorite_rounded,
                    label: 'BMI',
                    value: bmi == null ? '--' : bmi.toStringAsFixed(1),
                    accent: bmiInfo.color,
                    compact: compact,
                    subtitle: bmiInfo.label,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ProfilePill extends StatelessWidget {
  const _ProfilePill({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: const Color(0xFF334155).withValues(alpha: 0.8),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 15, color: const Color(0xFF22D3EE)),
          const SizedBox(width: 8),
          Text(
            '$label $value',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _HealthProfileSection extends StatelessWidget {
  const _HealthProfileSection({
    required this.userInfo,
    required this.avgDailySteps,
    required this.onAddTap,
  });

  final UserProfileInfo? userInfo;
  final int avgDailySteps;
  final VoidCallback onAddTap;

  @override
  Widget build(BuildContext context) {
    final double? bmi = _bmi(userInfo?.weightKg, userInfo?.heightCm);
    final _BmiInfo bmiInfo = _bmiInfo(bmi);
    final _FitnessInfo fitnessInfo = _fitnessInfo(avgDailySteps);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const _SectionHeader(
          title: 'My Health Profile',
          subtitle: 'Body stats and activity level at a glance.',
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final bool stacked = constraints.maxWidth < 620;
            final Widget bodyStatsCard = _ProfileCard(
              title: 'Body Stats',
              icon: Icons.accessibility_new_rounded,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _MetricRow(
                      label: 'Age', value: userInfo?.age?.toString() ?? '--'),
                  _MetricRow(
                    label: 'Weight',
                    value: userInfo?.weightKg?.toStringAsFixed(1) == null
                        ? '--'
                        : '${userInfo?.weightKg?.toStringAsFixed(1)} kg',
                  ),
                  _MetricRow(
                    label: 'Height',
                    value: userInfo?.heightCm?.toStringAsFixed(1) == null
                        ? '--'
                        : '${userInfo?.heightCm?.toStringAsFixed(1)} cm',
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: bmiInfo.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: bmiInfo.color.withValues(alpha: 0.45),
                      ),
                    ),
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.monitor_weight_rounded,
                            color: bmiInfo.color, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                'BMI ${bmi == null ? '--' : bmi.toStringAsFixed(1)}',
                                style: TextStyle(
                                  color: bmiInfo.color,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                bmiInfo.label,
                                style: TextStyle(
                                  color: bmiInfo.color.withValues(alpha: 0.9),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (userInfo?.age == null ||
                      userInfo?.weightKg == null ||
                      userInfo?.heightCm == null) ...<Widget>[
                    const SizedBox(height: 10),
                    TextButton.icon(
                      onPressed: onAddTap,
                      icon: const Icon(Icons.add_circle_outline, size: 18),
                      label: const Text('Add missing info'),
                    ),
                  ],
                ],
              ),
            );

            final Widget fitnessCard = _ProfileCard(
              title: 'Fitness Level',
              icon: Icons.fitness_center_rounded,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: <Color>[
                          fitnessInfo.color.withValues(alpha: 0.20),
                          fitnessInfo.color.withValues(alpha: 0.08),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: fitnessInfo.color.withValues(alpha: 0.55),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          '${fitnessInfo.emoji} ${fitnessInfo.label}',
                          style: TextStyle(
                            color: fitnessInfo.color,
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          fitnessInfo.description,
                          style: const TextStyle(fontSize: 13, height: 1.35),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: <Widget>[
                      const Icon(Icons.auto_graph_rounded,
                          size: 16, color: Color(0xFF94A3B8)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Based on your 7-day average of $avgDailySteps steps',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );

            if (stacked) {
              return Column(
                children: <Widget>[
                  bodyStatsCard,
                  const SizedBox(height: 12),
                  fitnessCard,
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(child: bodyStatsCard),
                const SizedBox(width: 12),
                Expanded(child: fitnessCard),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _WeeklySummarySection extends StatelessWidget {
  const _WeeklySummarySection({required this.data});

  final WeeklySummaryData data;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const _SectionHeader(
          title: 'Weekly Summary',
          subtitle: 'Your 7-day trend in one place.',
        ),
        const SizedBox(height: 12),
        GlassmorphismCard(
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: _SummaryMetricCell(
                      icon: Icons.directions_walk,
                      value: '${data.avgDailySteps}',
                      label: 'Avg Daily Steps',
                    ),
                  ),
                  const _MetricDivider(),
                  Expanded(
                    child: _SummaryMetricCell(
                      icon: Icons.event_available,
                      value: '${data.activeDays}',
                      label: 'Active Days',
                    ),
                  ),
                  const _MetricDivider(),
                  Expanded(
                    child: _SummaryMetricCell(
                      icon: Icons.emoji_events,
                      value: '${data.bestDay}',
                      label: 'Best Day',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      'Total Steps This Week',
                      style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: <Widget>[
                        Text(
                          '${data.totalSteps}',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF6366F1),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text('steps'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 70,
                      child: BarChart(
                        BarChartData(
                          gridData: const FlGridData(show: false),
                          borderData: FlBorderData(show: false),
                          titlesData: const FlTitlesData(show: false),
                          barGroups: List<BarChartGroupData>.generate(
                            7,
                            (int i) => BarChartGroupData(
                              x: i,
                              barRods: <BarChartRodData>[
                                BarChartRodData(
                                  toY: data.dailySteps[i].toDouble(),
                                  width: 10,
                                  borderRadius: BorderRadius.circular(8),
                                  color: const Color(0xFF6366F1),
                                ),
                              ],
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
        ),
      ],
    );
  }
}

class _AchievementsSection extends StatelessWidget {
  const _AchievementsSection({
    required this.achievements,
    required this.onSeeAll,
    required this.onTapAchievement,
  });

  final List<AchievementStatus> achievements;
  final VoidCallback onSeeAll;
  final ValueChanged<AchievementStatus> onTapAchievement;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Achievements',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 2),
                  const Text(
                    'Unlocked by consistency and progress.',
                    style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                  ),
                ],
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: onSeeAll,
              icon: const Icon(Icons.arrow_forward_rounded, size: 16),
              label: const Text('See All'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: achievements.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (BuildContext context, int index) {
              final AchievementStatus a = achievements[index];
              return _AchievementBadge(
                achievement: a,
                onTap: a.unlocked ? () => onTapAchievement(a) : null,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.profile,
    required this.appVersionFuture,
    required this.onDailyGoalChange,
    required this.onDemoModeChange,
    required this.onNotificationsChange,
    required this.onWaterReminderChange,
    required this.onStepUnitChange,
    required this.onExportData,
    required this.onClearChat,
    required this.onDeleteAccount,
    required this.onRateApp,
    required this.onPrivacyPolicy,
    required this.onContactSupport,
    required this.onSignOut,
  });

  final ProfileState profile;
  final Future<String> appVersionFuture;
  final ValueChanged<int> onDailyGoalChange;
  final ValueChanged<bool> onDemoModeChange;
  final ValueChanged<bool> onNotificationsChange;
  final ValueChanged<int> onWaterReminderChange;
  final ValueChanged<StepUnit> onStepUnitChange;
  final VoidCallback onExportData;
  final VoidCallback onClearChat;
  final VoidCallback onDeleteAccount;
  final VoidCallback onRateApp;
  final VoidCallback onPrivacyPolicy;
  final VoidCallback onContactSupport;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const _SectionHeader(
          title: 'Settings',
          subtitle: 'Customize goals, app behavior, and support.',
        ),
        const SizedBox(height: 12),
        const _SectionLabel(title: 'Preferences'),
        const SizedBox(height: 8),
        _SettingsTile(
          icon: Icons.flag_outlined,
          title: 'Daily Step Goal',
          subtitle: '${profile.dailyStepGoal} steps',
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => _showGoalDialog(
              context, profile.dailyStepGoal, onDailyGoalChange),
        ),
        const SizedBox(height: 8),
        _SettingsTile(
          icon: Icons.water_drop_outlined,
          title: 'Water Reminder Interval',
          subtitle: '${profile.waterReminder} min intervals',
          trailing: DropdownButton<int>(
            value: profile.waterReminder,
            items: const <DropdownMenuItem<int>>[
              DropdownMenuItem(value: 30, child: Text('30 min')),
              DropdownMenuItem(value: 60, child: Text('1 hour')),
              DropdownMenuItem(value: 120, child: Text('2 hours')),
            ],
            onChanged: (int? value) {
              if (value != null) {
                onWaterReminderChange(value);
              }
            },
            underline: const SizedBox.shrink(),
          ),
        ),
        const SizedBox(height: 8),
        GlassmorphismCard(
          child: Row(
            children: <Widget>[
              const Icon(Icons.straighten, color: AppTheme.secondaryAccent),
              const SizedBox(width: 12),
              const Expanded(child: Text('Units (Steps/KM)')),
              SegmentedButton<StepUnit>(
                segments: const <ButtonSegment<StepUnit>>[
                  ButtonSegment<StepUnit>(
                      value: StepUnit.steps, label: Text('Steps')),
                  ButtonSegment<StepUnit>(
                      value: StepUnit.km, label: Text('KM')),
                ],
                selected: <StepUnit>{profile.stepUnit},
                onSelectionChanged: (Set<StepUnit> values) {
                  onStepUnitChange(values.first);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Divider(color: Color(0xFF1E293B)),
        const SizedBox(height: 8),
        const _SectionLabel(title: 'App'),
        const SizedBox(height: 8),
        _SettingsTile(
          icon: Icons.psychology_outlined,
          title: 'Demo Mode',
          subtitle: 'Use fake data for testing',
          trailing: Switch(
            value: profile.demoMode,
            onChanged: onDemoModeChange,
            activeThumbColor: AppTheme.primaryAccent,
          ),
        ),
        const SizedBox(height: 8),
        _SettingsTile(
          icon: Icons.notifications_outlined,
          title: 'Notifications',
          subtitle: 'Receive health alerts',
          trailing: Switch(
            value: profile.notificationsEnabled,
            onChanged: onNotificationsChange,
            activeThumbColor: AppTheme.primaryAccent,
          ),
        ),
        const SizedBox(height: 8),
        const _SettingsTile(
          icon: Icons.dark_mode,
          title: 'Theme',
          subtitle: 'Dark',
          trailing: Icon(Icons.lock, size: 16),
        ),
        const SizedBox(height: 8),
        FutureBuilder<String>(
          future: appVersionFuture,
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            return _SettingsTile(
              icon: Icons.info_outline,
              title: 'App Version',
              subtitle: snapshot.data ?? 'Loading...',
              subtitleStyle:
                  const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            );
          },
        ),
        const SizedBox(height: 16),
        const Divider(color: Color(0xFF1E293B)),
        const SizedBox(height: 8),
        const _SectionLabel(title: 'Data'),
        const SizedBox(height: 8),
        _SettingsTile(
          icon: Icons.download,
          title: 'Export Health Data',
          subtitle: 'Save last 30 days as CSV',
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: onExportData,
        ),
        const SizedBox(height: 8),
        _SettingsTile(
          icon: Icons.delete_outline,
          title: 'Clear Chat History',
          subtitle: 'Remove all messages',
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: onClearChat,
        ),
        const SizedBox(height: 8),
        _SettingsTile(
          icon: Icons.warning_amber_rounded,
          title: 'Delete Account',
          subtitle: 'Permanently delete account and data',
          titleColor: AppTheme.error,
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: onDeleteAccount,
        ),
        const SizedBox(height: 16),
        const Divider(color: Color(0xFF1E293B)),
        const SizedBox(height: 8),
        const _SectionLabel(title: 'Support'),
        const SizedBox(height: 8),
        _SettingsTile(
          icon: Icons.star_rate_outlined,
          title: 'Rate WearSync',
          subtitle: 'Leave a rating on Play Store',
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: onRateApp,
        ),
        const SizedBox(height: 8),
        _SettingsTile(
          icon: Icons.privacy_tip_outlined,
          title: 'Privacy Policy',
          subtitle: 'Read our policy',
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: onPrivacyPolicy,
        ),
        const SizedBox(height: 8),
        _SettingsTile(
          icon: Icons.support_agent,
          title: 'Contact Support',
          subtitle: 'support@wearsync.app',
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: onContactSupport,
        ),
        const SizedBox(height: 16),
        _SettingsTile(
          icon: Icons.logout,
          title: 'Sign Out',
          subtitle: 'Log out of your account',
          titleColor: AppTheme.error,
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: onSignOut,
        ),
      ],
    );
  }

  void _showGoalDialog(
    BuildContext context,
    int currentGoal,
    ValueChanged<int> onSave,
  ) {
    int selectedGoal = currentGoal;
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              backgroundColor: AppTheme.surface,
              title: const Text('Daily Step Goal'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    '$selectedGoal steps',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  Slider(
                    value: selectedGoal.toDouble(),
                    min: 1000,
                    max: 50000,
                    divisions: 98,
                    activeColor: AppTheme.primaryAccent,
                    onChanged: (double value) {
                      setState(() => selectedGoal = value.round());
                    },
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    onSave(selectedGoal);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.titleColor,
    this.subtitleStyle,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final Color? titleColor;
  final TextStyle? subtitleStyle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassmorphismCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: <Widget>[
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppTheme.secondaryAccent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: AppTheme.secondaryAccent),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: titleColor ?? Colors.white,
                        ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: subtitleStyle ??
                        Theme.of(context).textTheme.bodySmall?.copyWith(
                              height: 1.25,
                            ),
                  ),
                ],
              ),
            ),
            if (trailing != null) ...<Widget>[
              const SizedBox(width: 8),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    this.subtitle,
  });

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
        ),
        if (subtitle != null) ...<Widget>[
          const SizedBox(height: 3),
          Text(
            subtitle!,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF94A3B8),
              height: 1.3,
            ),
          ),
        ],
      ],
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GlassmorphismCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: const Color(0xFF1E293B),
                ),
                child: Icon(icon, color: const Color(0xFF22D3EE), size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: <Widget>[
          Text(
            '$label:',
            style: const TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SnapshotTile extends StatelessWidget {
  const _SnapshotTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.accent,
    required this.compact,
    this.subtitle,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color accent;
  final bool compact;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: compact
          ? double.infinity
          : (MediaQuery.of(context).size.width - 64) / 3,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: accent.withValues(alpha: 0.35)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: accent, size: 18),
                ),
                const Spacer(),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: TextStyle(
                      color: accent,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DarkField extends StatelessWidget {
  const _DarkField({
    required this.controller,
    required this.label,
    this.keyboardType,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: const Color(0xFF111827),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontWeight: FontWeight.w700,
        color: Color(0xFF94A3B8),
      ),
    );
  }
}

class _SummaryMetricCell extends StatelessWidget {
  const _SummaryMetricCell({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFF3730A3),
          ),
          child: Icon(icon, size: 18, color: Colors.white),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
        ),
      ],
    );
  }
}

class _MetricDivider extends StatelessWidget {
  const _MetricDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 80,
      color: const Color(0xFF1E293B),
      margin: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}

class _AchievementBadge extends StatelessWidget {
  const _AchievementBadge({required this.achievement, this.onTap});

  final AchievementStatus achievement;
  final VoidCallback? onTap;

  static const List<double> _greyScaleMatrix = <double>[
    0.2126,
    0.7152,
    0.0722,
    0,
    0,
    0.2126,
    0.7152,
    0.0722,
    0,
    0,
    0.2126,
    0.7152,
    0.0722,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
  ];

  @override
  Widget build(BuildContext context) {
    final Widget badge = Column(
      children: <Widget>[
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: achievement.unlocked
                ? Border.all(color: const Color(0xFFFBBF24), width: 2)
                : null,
          ),
          child: GlassmorphismCard(
            padding: const EdgeInsets.all(0),
            child: Center(
              child: Text(
                achievement.unlocked ? achievement.emoji : '?',
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 70,
          child: Text(
            achievement.unlocked ? achievement.name : '???',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 9),
          ),
        ),
      ],
    );

    final Widget shown = achievement.unlocked
        ? badge
        : ColorFiltered(
            colorFilter: const ColorFilter.matrix(_greyScaleMatrix),
            child: badge,
          );

    return GestureDetector(onTap: onTap, child: shown);
  }
}

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key, required this.achievements});

  final List<AchievementStatus> achievements;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('All Achievements')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: achievements.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (BuildContext context, int index) {
          final AchievementStatus a = achievements[index];
          return GlassmorphismCard(
            child: Row(
              children: <Widget>[
                Text(a.unlocked ? a.emoji : '❔',
                    style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(a.unlocked ? a.name : 'Locked'),
                      const SizedBox(height: 2),
                      Text(
                        a.unlocked
                            ? (a.earnedAt == null
                                ? a.description
                                : 'Earned ${DateFormat('MMM d, yyyy').format(a.earnedAt!)}')
                            : a.description,
                        style: const TextStyle(
                            fontSize: 12, color: Color(0xFF94A3B8)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _BmiInfo {
  const _BmiInfo({required this.label, required this.color});

  final String label;
  final Color color;
}

class _FitnessInfo {
  const _FitnessInfo({
    required this.label,
    required this.emoji,
    required this.description,
    required this.color,
  });

  final String label;
  final String emoji;
  final String description;
  final Color color;
}

double? _bmi(double? weightKg, double? heightCm) {
  if (weightKg == null || heightCm == null || heightCm <= 0) {
    return null;
  }
  final double meter = heightCm / 100;
  return weightKg / (meter * meter);
}

_BmiInfo _bmiInfo(double? bmi) {
  if (bmi == null) {
    return const _BmiInfo(label: '--', color: Color(0xFF94A3B8));
  }
  if (bmi < 18.5) {
    return const _BmiInfo(label: 'Underweight', color: Color(0xFF22C55E));
  }
  if (bmi < 25) {
    return const _BmiInfo(label: 'Normal', color: Color(0xFF6366F1));
  }
  if (bmi < 30) {
    return const _BmiInfo(label: 'Overweight', color: Color(0xFFF59E0B));
  }
  return const _BmiInfo(label: 'Obese', color: Color(0xFFEF4444));
}

_FitnessInfo _fitnessInfo(int avgSteps) {
  if (avgSteps < 3000) {
    return const _FitnessInfo(
      label: 'Sedentary',
      emoji: '🛋️',
      description: 'Try adding short walks throughout the day.',
      color: Color(0xFFEF4444),
    );
  }
  if (avgSteps < 7500) {
    return const _FitnessInfo(
      label: 'Lightly Active',
      emoji: '🚶',
      description: 'You are moving consistently. Keep it up.',
      color: Color(0xFFF59E0B),
    );
  }
  if (avgSteps < 10000) {
    return const _FitnessInfo(
      label: 'Active',
      emoji: '🏃',
      description: 'Strong weekly activity pattern.',
      color: Color(0xFF6366F1),
    );
  }
  return const _FitnessInfo(
    label: 'Very Active',
    emoji: '⚡',
    description: 'Excellent pace. You are in the top range.',
    color: Color(0xFF22C55E),
  );
}
