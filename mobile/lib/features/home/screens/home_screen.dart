import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../core/utils/helpers.dart';
import '../../auth/providers/auth_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/scan'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.primaryForeground,
        icon: const Icon(Icons.camera_alt),
        label: const Text('Scan'),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          _DashboardTab(),
          _MedicationsTab(),
          _HistoryTab(),
          _InsightsTab(),
          _SettingsTab(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.border, width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.medication_outlined),
              activeIcon: Icon(Icons.medication),
              label: 'Meds',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_outlined),
              activeIcon: Icon(Icons.history),
              label: 'History',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.insights_outlined),
              activeIcon: Icon(Icons.insights),
              label: 'Insights',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardTab extends StatelessWidget {
  const _DashboardTab();

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: true,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateTimeUtils.getGreeting(),
                style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                  color: AppColors.mutedForeground,
                ),
              ),
              Text(
                user?.fullName.isNotEmpty == true ? user!.fullName : 'User',
                style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.qr_code_scanner),
              onPressed: () {},
            ),
          ],
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAdherenceCard(),
                const SizedBox(height: 16),
                _buildTodaySchedule(),
                const SizedBox(height: 16),
                _buildQuickActions(),
                const SizedBox(height: 16),
                _buildLowStockAlert(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAdherenceCard() {
    return GlassCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Today\'s Adherence',
                  style: AppTheme.darkTheme.textTheme.titleSmall?.copyWith(
                    color: AppColors.mutedForeground,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      '85%',
                      style: AppTheme.darkTheme.textTheme.displaySmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Good',
                      style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '17 of 20 doses taken',
                  style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                    color: AppColors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
          CircularProgress(
            value: 0.85,
            size: 80,
            strokeWidth: 8,
            progressColor: AppColors.success,
          ),
        ],
      ),
    );
  }

  Widget _buildTodaySchedule() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Today\'s Schedule',
              style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton(onPressed: () {}, child: const Text('See All')),
          ],
        ),
        const SizedBox(height: 8),
        // Sample dose logs for display
        _buildDoseLogItem('Metformin', '500mg', '08:00 AM', 'taken'),
        _buildDoseLogItem('Lisinopril', '10mg', '08:00 AM', 'taken'),
        _buildDoseLogItem('Vitamin D', '1000 IU', '12:00 PM', 'pending'),
      ],
    );
  }

  Widget _buildDoseLogItem(
    String name,
    String dosage,
    String time,
    String status,
  ) {
    Color statusColor;
    IconData statusIcon;

    switch (status) {
      case 'taken':
        statusColor = AppColors.taken;
        statusIcon = Icons.check_circle;
        break;
      case 'missed':
        statusColor = AppColors.missed;
        statusIcon = Icons.cancel;
        break;
      case 'snoozed':
        statusColor = AppColors.snoozed;
        statusIcon = Icons.snooze;
        break;
      default:
        statusColor = AppColors.pending;
        statusIcon = Icons.schedule;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GlassCard(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(statusIcon, color: statusColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: AppTheme.darkTheme.textTheme.titleSmall),
                  Text(
                    dosage,
                    style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                      color: AppColors.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              time,
              style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                color: statusColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Builder(
      builder: (ctx) {
        final r = GoRouter.of(ctx);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: GlassCard(
                    onTap: () => r.push('/scan'),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Column(
                      children: [
                        Icon(
                          Icons.camera_alt,
                          size: 28,
                          color: AppColors.primary,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Scan Rx',
                          style: AppTheme.darkTheme.textTheme.labelMedium,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GlassCard(
                    onTap: () => r.push('/medication/add'),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Column(
                      children: [
                        Icon(
                          Icons.add_circle_outline,
                          size: 28,
                          color: AppColors.primary,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add Med',
                          style: AppTheme.darkTheme.textTheme.labelMedium,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GlassCard(
                    onTap: () => r.push('/dose/log'),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Column(
                      children: [
                        Icon(
                          Icons.edit_note,
                          size: 28,
                          color: AppColors.primary,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Log Dose',
                          style: AppTheme.darkTheme.textTheme.labelMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildLowStockAlert() {
    return GlassCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              color: AppColors.warning,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Low Stock Alert',
                  style: AppTheme.darkTheme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Atorvastatin - 5 pills remaining',
                  style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                    color: AppColors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
          TextButton(onPressed: () {}, child: const Text('Refill')),
        ],
      ),
    );
  }
}

class _MedicationsTab extends StatelessWidget {
  const _MedicationsTab();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        const SliverAppBar(
          floating: true,
          title: Text('Medications'),
          actions: [IconButton(icon: Icon(Icons.add), onPressed: null)],
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildMedicationCard(
                name: 'Metformin',
                dosage: '500mg',
                frequency: 'Twice daily',
                pillCount: 45,
                isLowStock: false,
              ),
              const SizedBox(height: 12),
              _buildMedicationCard(
                name: 'Lisinopril',
                dosage: '10mg',
                frequency: 'Once daily',
                pillCount: 12,
                isLowStock: true,
              ),
              const SizedBox(height: 12),
              _buildMedicationCard(
                name: 'Atorvastatin',
                dosage: '20mg',
                frequency: 'Once daily at bedtime',
                pillCount: 5,
                isLowStock: true,
              ),
              const SizedBox(height: 12),
              _buildMedicationCard(
                name: 'Vitamin D3',
                dosage: '1000 IU',
                frequency: 'Once daily',
                pillCount: 90,
                isLowStock: false,
              ),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildMedicationCard({
    required String name,
    required String dosage,
    required String frequency,
    required int pillCount,
    required bool isLowStock,
  }) {
    return MedicationCard(
      name: name,
      dosage: dosage,
      frequency: frequency,
      pillCount: pillCount,
      isLowStock: isLowStock,
      onTap: () {},
      onLog: () {},
    );
  }
}

class _HistoryTab extends StatelessWidget {
  const _HistoryTab();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        const SliverAppBar(floating: true, title: Text('History')),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildDateSection('Today'),
              _buildHistoryItem('Metformin', '500mg', '08:00 AM', 'taken'),
              _buildHistoryItem('Lisinopril', '10mg', '08:00 AM', 'taken'),
              _buildHistoryItem('Vitamin D', '1000 IU', '12:00 PM', 'pending'),
              const SizedBox(height: 24),
              _buildDateSection('Yesterday'),
              _buildHistoryItem('Metformin', '500mg', '08:00 AM', 'taken'),
              _buildHistoryItem('Lisinopril', '10mg', '08:00 AM', 'taken'),
              _buildHistoryItem('Vitamin D', '1000 IU', '12:00 PM', 'taken'),
              _buildHistoryItem('Metformin', '500mg', '08:00 PM', 'taken'),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildDateSection(String date) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        date,
        style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildHistoryItem(
    String name,
    String dosage,
    String time,
    String status,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: DoseLogCard(
        medicationName: name,
        dosage: dosage,
        scheduledTime: DateTime.now(),
        status: status,
      ),
    );
  }
}

class _InsightsTab extends StatelessWidget {
  const _InsightsTab();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        const SliverAppBar(floating: true, title: Text('Insights')),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildStatGrid(),
              const SizedBox(height: 16),
              _buildAIInsights(),
              const SizedBox(height: 16),
              _buildBodyImpact(),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildStatGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: const [
        StatCard(
          title: 'Current Streak',
          value: '12 days',
          subtitle: 'Longest: 45 days',
          icon: Icons.local_fire_department,
          iconColor: AppColors.warning,
        ),
        StatCard(
          title: 'Adherence Rate',
          value: '92%',
          subtitle: 'Last 30 days',
          icon: Icons.trending_up,
          iconColor: AppColors.success,
        ),
        StatCard(
          title: 'Total Doses',
          value: '180',
          subtitle: 'This month',
          icon: Icons.medication,
          iconColor: AppColors.info,
        ),
        StatCard(
          title: 'Missed Doses',
          value: '8',
          subtitle: 'This month',
          icon: Icons.cancel_outlined,
          iconColor: AppColors.error,
        ),
      ],
    );
  }

  Widget _buildAIInsights() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.psychology,
                  color: AppColors.info,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'AI Coach',
                style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Great job maintaining your medication routine! Your adherence has improved by 15% this month. Keep up the good work.',
            style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
              color: AppColors.mutedForeground,
            ),
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 12),
          Text(
            'Recommendations',
            style: AppTheme.darkTheme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          _buildRecommendation(
            'Schedule Metformin with breakfast',
            'Higher adherence when taken with food',
          ),
          _buildRecommendation(
            'Refill Lisinopril soon',
            'Only 12 pills remaining',
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendation(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(
            Icons.lightbulb_outline,
            size: 16,
            color: AppColors.warning,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                    color: AppColors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBodyImpact() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Body Impact Score',
                style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Excellent',
                  style: AppTheme.darkTheme.textTheme.labelSmall?.copyWith(
                    color: AppColors.success,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: 0.88,
            backgroundColor: AppColors.border,
            valueColor: const AlwaysStoppedAnimation(AppColors.success),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 8),
          Text(
            '88/100',
            style: AppTheme.darkTheme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsTab extends StatelessWidget {
  const _SettingsTab();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        const SliverAppBar(floating: true, title: Text('Settings')),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildSettingsSection('Account', [
                _buildSettingsTile(
                  icon: Icons.person_outline,
                  title: 'Profile',
                  subtitle: 'Manage your profile',
                ),
                _buildSettingsTile(
                  icon: Icons.lock_outline,
                  title: 'Security',
                  subtitle: 'Password, 2FA, biometrics',
                ),
                _buildSettingsTile(
                  icon: Icons.notifications_outlined,
                  title: 'Notifications',
                  subtitle: 'Reminder settings',
                ),
              ]),
              const SizedBox(height: 16),
              _buildSettingsSection('Family', [
                _buildSettingsTile(
                  icon: Icons.people_outline,
                  title: 'Family Members',
                  subtitle: 'Manage profiles',
                  onTap: () => context.push('/family-profiles'),
                ),
                _buildSettingsTile(
                  icon: Icons.share_outlined,
                  title: 'Caregiver Access',
                  subtitle: 'Share access with caregivers',
                ),
              ]),
              const SizedBox(height: 16),
              _buildSettingsSection('Security', [
                _buildSettingsTile(
                  icon: Icons.lock_outline,
                  title: 'Security',
                  subtitle: 'Biometric, PIN',
                  onTap: () => context.push('/security'),
                ),
              ]),
              const SizedBox(height: 16),
              _buildSettingsSection('App', [
                _buildSettingsTile(
                  icon: Icons.palette_outlined,
                  title: 'Appearance',
                  subtitle: 'Theme, display',
                ),
                _buildSettingsTile(
                  icon: Icons.language,
                  title: 'Language',
                  subtitle: 'English',
                ),
                _buildSettingsTile(
                  icon: Icons.help_outline,
                  title: 'Help & Support',
                  subtitle: 'FAQ, contact us',
                ),
              ]),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  context.read<AuthProvider>().logout();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.destructive,
                  foregroundColor: AppColors.destructiveForeground,
                ),
                icon: const Icon(Icons.logout),
                label: const Text('Sign Out'),
              ),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        GlassCard(
          padding: EdgeInsets.zero,
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.mutedForeground),
      title: Text(title),
      subtitle: Text(
        subtitle,
        style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
          color: AppColors.mutedForeground,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: AppColors.mutedForeground,
      ),
      onTap: onTap ?? () {},
    );
  }
}
