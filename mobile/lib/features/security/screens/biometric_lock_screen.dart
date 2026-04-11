import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../core/constants/app_constants.dart';

class BiometricLockScreen extends StatefulWidget {
  final VoidCallback onUnlocked;

  const BiometricLockScreen({super.key, required this.onUnlocked});

  @override
  State<BiometricLockScreen> createState() => _BiometricLockScreenState();
}

class _BiometricLockScreenState extends State<BiometricLockScreen> {
  final LocalAuthentication _localAuth = LocalAuthentication();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  bool _isAuthenticating = false;
  String? _errorMessage;
  List<BiometricType> _availableBiometrics = [];

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      if (canCheck) {
        final biometrics = await _localAuth.getAvailableBiometrics();
        setState(() => _availableBiometrics = biometrics);
      }
    } catch (e) {
      debugPrint('Error checking biometrics: $e');
    }
  }

  Future<void> _authenticate() async {
    if (_isAuthenticating) return;

    setState(() {
      _isAuthenticating = true;
      _errorMessage = null;
    });

    try {
      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Authenticate to access MedTrack AI',
        biometricOnly: false,
      );

      if (authenticated) {
        widget.onUnlocked();
      } else {
        setState(() => _errorMessage = 'Authentication failed');
      }
    } catch (e) {
      setState(() => _errorMessage = 'Error: ${e.toString()}');
    } finally {
      setState(() => _isAuthenticating = false);
    }
  }

  Future<void> _authenticateWithPin() async {
    final storedPin = await _storage.read(key: AppConstants.pinKey);
    if (storedPin == null) {
      setState(() => _errorMessage = 'No PIN set. Please set up in Settings.');
      return;
    }

    _showPinDialog();
  }

  void _showPinDialog() {
    final pinController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text('Enter PIN'),
        content: TextField(
          controller: pinController,
          keyboardType: TextInputType.number,
          obscureText: true,
          maxLength: 6,
          decoration: const InputDecoration(
            hintText: 'Enter 6-digit PIN',
            counterText: '',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final storedPin = await _storage.read(key: AppConstants.pinKey);
              if (pinController.text == storedPin) {
                if (ctx.mounted) Navigator.pop(ctx);
                widget.onUnlocked();
              } else {
                setState(() => _errorMessage = 'Incorrect PIN');
              }
            },
            child: const Text('Unlock'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: const Icon(
                  Icons.lock_rounded,
                  size: 50,
                  color: AppColors.primaryForeground,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'MedTrack AI',
                style: AppTheme.darkTheme.textTheme.displaySmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Locked',
                style: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(
                  color: AppColors.mutedForeground,
                ),
              ),
              const SizedBox(height: 48),
              if (_errorMessage != null) ...[
                GlassCard(
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: AppColors.error),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: AppTheme.darkTheme.textTheme.bodyMedium
                              ?.copyWith(color: AppColors.error),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isAuthenticating ? null : _authenticate,
                  icon: _isAuthenticating
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.fingerprint),
                  label: Text(
                    _isAuthenticating
                        ? 'Authenticating...'
                        : 'Unlock with Biometrics',
                  ),
                ),
              ),
              if (_availableBiometrics.contains(BiometricType.strong) ||
                  _availableBiometrics.contains(BiometricType.fingerprint)) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _authenticateWithPin,
                    icon: const Icon(Icons.pin),
                    label: const Text('Unlock with PIN'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
