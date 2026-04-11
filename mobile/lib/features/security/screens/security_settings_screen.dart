import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../core/constants/app_constants.dart';
import '../../auth/providers/auth_provider.dart';

class SecuritySettingsScreen extends StatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  State<SecuritySettingsScreen> createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends State<SecuritySettingsScreen> {
  final LocalAuthentication _localAuth = LocalAuthentication();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  bool _biometricEnabled = false;
  bool _biometricAvailable = false;
  List<BiometricType> _availableBiometrics = [];

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _checkBiometrics();
  }

  Future<void> _loadSettings() async {
    final biometricEnabled = await _storage.read(
      key: AppConstants.biometricEnabledKey,
    );
    setState(() => _biometricEnabled = biometricEnabled == 'true');
  }

  Future<void> _checkBiometrics() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      if (canCheck) {
        final biometrics = await _localAuth.getAvailableBiometrics();
        setState(() {
          _availableBiometrics = biometrics;
          _biometricAvailable = biometrics.isNotEmpty;
        });
      }
    } catch (e) {
      debugPrint('Error checking biometrics: $e');
    }
  }

  Future<void> _toggleBiometric(bool value) async {
    if (value) {
      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Verify your identity to enable biometric lock',
        biometricOnly: true,
      );

      if (authenticated) {
        await _storage.write(
          key: AppConstants.biometricEnabledKey,
          value: 'true',
        );
        setState(() => _biometricEnabled = true);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Biometric lock enabled')),
          );
        }
      }
    } else {
      await _storage.write(
        key: AppConstants.biometricEnabledKey,
        value: 'false',
      );
      setState(() => _biometricEnabled = false);
    }
  }

  void _showSetPinDialog() {
    final pinController = TextEditingController();
    final confirmController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text('Set PIN'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: pinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 6,
              decoration: const InputDecoration(
                labelText: 'Enter 6-digit PIN',
                counterText: '',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmController,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 6,
              decoration: const InputDecoration(
                labelText: 'Confirm PIN',
                counterText: '',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (pinController.text.length != 6) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('PIN must be 6 digits')),
                );
                return;
              }
              if (pinController.text != confirmController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('PINs do not match')),
                );
                return;
              }
              await _storage.write(
                key: AppConstants.pinKey,
                value: pinController.text,
              );
              if (ctx.mounted) Navigator.pop(ctx);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('PIN set successfully')),
                );
              }
            },
            child: const Text('Set PIN'),
          ),
        ],
      ),
    );
  }

  void _showChangePinDialog() {
    final currentController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text('Change PIN'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentController,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 6,
              decoration: const InputDecoration(
                labelText: 'Current PIN',
                counterText: '',
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: newController,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 6,
              decoration: const InputDecoration(
                labelText: 'New PIN',
                counterText: '',
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: confirmController,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 6,
              decoration: const InputDecoration(
                labelText: 'Confirm New PIN',
                counterText: '',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final currentPin = await _storage.read(key: AppConstants.pinKey);
              if (currentController.text != currentPin) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Current PIN is incorrect')),
                );
                return;
              }
              if (newController.text.length != 6) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('PIN must be 6 digits')),
                );
                return;
              }
              if (newController.text != confirmController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('PINs do not match')),
                );
                return;
              }
              await _storage.write(
                key: AppConstants.pinKey,
                value: newController.text,
              );
              if (ctx.mounted) Navigator.pop(ctx);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('PIN changed successfully')),
                );
              }
            },
            child: const Text('Change'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Security')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Biometric Lock',
                  style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Use fingerprint or face recognition to unlock the app',
                  style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                    color: AppColors.mutedForeground,
                  ),
                ),
                const SizedBox(height: 16),
                if (_biometricAvailable)
                  SwitchListTile(
                    title: const Text('Enable Biometrics'),
                    subtitle: Text(
                      _availableBiometrics.contains(BiometricType.fingerprint)
                          ? 'Fingerprint available'
                          : _availableBiometrics.contains(BiometricType.face)
                          ? 'Face ID available'
                          : 'Biometrics available',
                    ),
                    value: _biometricEnabled,
                    onChanged: _toggleBiometric,
                    activeThumbColor: AppColors.primary,
                    contentPadding: EdgeInsets.zero,
                  )
                else
                  Text(
                    'Biometric authentication not available on this device',
                    style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                      color: AppColors.error,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PIN Lock',
                  style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Set up a PIN as a backup unlock method',
                  style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                    color: AppColors.mutedForeground,
                  ),
                ),
                const SizedBox(height: 16),
                FutureBuilder<String?>(
                  future: _storage.read(key: AppConstants.pinKey),
                  builder: (context, snapshot) {
                    final hasPin = snapshot.data != null;
                    return Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.pin),
                          title: Text(hasPin ? 'Change PIN' : 'Set PIN'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: hasPin
                              ? _showChangePinDialog
                              : _showSetPinDialog,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Session Security',
                  style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.logout, color: AppColors.error),
                  title: const Text('Lock App Now'),
                  onTap: () {
                    context.read<AuthProvider>().logout();
                  },
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
