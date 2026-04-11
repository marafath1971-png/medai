import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common_widgets.dart';

class Profile {
  final String id;
  final String name;
  final String? avatarUrl;
  final bool isActive;

  const Profile({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.isActive = false,
  });
}

class FamilyProfilesScreen extends StatefulWidget {
  const FamilyProfilesScreen({super.key});

  @override
  State<FamilyProfilesScreen> createState() => _FamilyProfilesScreenState();
}

class _FamilyProfilesScreenState extends State<FamilyProfilesScreen> {
  final List<Profile> _profiles = [
    const Profile(id: '1', name: 'Me', isActive: true),
    const Profile(id: '2', name: 'John (Father)'),
    const Profile(id: '3', name: 'Jane (Mother)'),
    const Profile(id: '4', name: 'Tommy (Son)'),
  ];

  void _addProfile() {
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text('Add Family Member'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Name',
            hintText: 'Enter name',
          ),
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Added ${nameController.text}')),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _editProfile(Profile profile) {
    final nameController = TextEditingController(text: profile.name);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text('Edit Profile'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Profile deleted')));
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Family Profiles'),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: _addProfile),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Manage your family members\' medication profiles',
            style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
              color: AppColors.mutedForeground,
            ),
          ),
          const SizedBox(height: 24),
          ...List.generate(_profiles.length, (index) {
            final profile = _profiles[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GlassCard(
                onTap: () => _editProfile(profile),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: profile.isActive
                            ? AppColors.primary
                            : AppColors.secondary,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Center(
                        child: Text(
                          profile.name.isNotEmpty
                              ? profile.name[0].toUpperCase()
                              : '?',
                          style: AppTheme.darkTheme.textTheme.titleLarge
                              ?.copyWith(
                                color: profile.isActive
                                    ? AppColors.primaryForeground
                                    : AppColors.mutedForeground,
                              ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                profile.name,
                                style: AppTheme.darkTheme.textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              if (profile.isActive) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.success.withValues(
                                      alpha: 0.2,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Active',
                                    style: AppTheme
                                        .darkTheme
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(color: AppColors.success),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          Text(
                            profile.isActive
                                ? 'Currently viewing'
                                : 'Tap to switch',
                            style: AppTheme.darkTheme.textTheme.bodySmall
                                ?.copyWith(color: AppColors.mutedForeground),
                          ),
                        ],
                      ),
                    ),
                    if (!profile.isActive)
                      const Icon(
                        Icons.chevron_right,
                        color: AppColors.mutedForeground,
                      ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 24),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.info_outline, color: AppColors.info),
                    const SizedBox(width: 12),
                    Text(
                      'About Profiles',
                      style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Each family member can have their own medication schedule and tracking. Switch between profiles to view and manage their medications.',
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
}
