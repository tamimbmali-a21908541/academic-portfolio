import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/app_protection.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';

/// Activation Screen - Shown when app is not activated
///
/// Users must enter an activation code to use the app.
/// Even if they have the APK, they can't use it without the code.
class ActivationScreen extends StatefulWidget {
  final VoidCallback onActivated;

  const ActivationScreen({
    super.key,
    required this.onActivated,
  });

  @override
  State<ActivationScreen> createState() => _ActivationScreenState();
}

class _ActivationScreenState extends State<ActivationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _activationCodeController = TextEditingController();
  bool _isLoading = false;
  bool _showDeviceInfo = false;
  Map<String, String>? _deviceInfo;

  @override
  void initState() {
    super.initState();
    _loadDeviceInfo();
  }

  @override
  void dispose() {
    _activationCodeController.dispose();
    super.dispose();
  }

  Future<void> _loadDeviceInfo() async {
    final info = await AppProtection.getDeviceInfo();
    setState(() {
      _deviceInfo = info;
    });
  }

  Future<void> _activate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final code = _activationCodeController.text.trim();
    final success = await AppProtection.activate(code);

    setState(() {
      _isLoading = false;
    });

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('App activated successfully!'),
          backgroundColor: AppColors.successGreen,
        ),
      );
      widget.onActivated();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid activation code. Please contact support.'),
          backgroundColor: AppColors.errorRed,
        ),
      );
    }
  }

  Future<void> _copyDeviceId() async {
    if (_deviceInfo != null && _deviceInfo!.containsKey('Device ID')) {
      await Clipboard.setData(ClipboardData(text: _deviceInfo!['Device ID']!));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Device ID copied to clipboard'),
          backgroundColor: AppColors.primaryBlue,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Icon/Logo
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryBlue.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.asset(
                      'assets/icon/app_icon.png',
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Title
                const Text(
                  'PowerInvoice',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textWhite,
                  ),
                ),
                const SizedBox(height: 8),

                // Subtitle
                const Text(
                  'App Activation Required',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textGrey,
                  ),
                ),
                const SizedBox(height: 40),

                // Info Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDark,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primaryBlue.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: AppColors.primaryBlue,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'First Time Setup',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textWhite,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'This app requires a unique activation code to run. Contact the app administrator with your Device ID to receive your activation code.',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textGrey,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Activation Form
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _activationCodeController,
                        decoration: InputDecoration(
                          labelText: 'Activation Code',
                          hintText: 'XXXX-XXXX',
                          prefixIcon: const Icon(Icons.vpn_key),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        textCapitalization: TextCapitalization.characters,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          letterSpacing: 2,
                          fontWeight: FontWeight.bold,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter activation code';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Activate Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _activate,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Text(
                                  'Activate App',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Device Info Toggle
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _showDeviceInfo = !_showDeviceInfo;
                    });
                  },
                  icon: Icon(
                    _showDeviceInfo ? Icons.expand_less : Icons.expand_more,
                    color: AppColors.primaryBlue,
                  ),
                  label: const Text(
                    'Show Device Information',
                    style: TextStyle(color: AppColors.primaryBlue),
                  ),
                ),

                // Device Info (expandable)
                if (_showDeviceInfo && _deviceInfo != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceDark,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.surfaceGrey),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Device Information',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textWhite,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ..._deviceInfo!.entries.map((entry) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      '${entry.key}:',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textGrey,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: entry.key == 'Device ID'
                                        ? Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  entry.value,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: AppColors.textWhite,
                                                    fontFamily: 'monospace',
                                                  ),
                                                ),
                                              ),
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.copy,
                                                  size: 16,
                                                  color: AppColors.primaryBlue,
                                                ),
                                                onPressed: _copyDeviceId,
                                                tooltip: 'Copy Device ID',
                                              ),
                                            ],
                                          )
                                        : Text(
                                            entry.value,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: AppColors.textWhite,
                                            ),
                                          ),
                                  ),
                                ],
                              ),
                            )),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.primaryBlue.withOpacity(0.3),
                            ),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.email_outlined,
                                size: 16,
                                color: AppColors.primaryBlue,
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Send your Device ID to:\nthebinformatica@gmail.com',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textGrey,
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

                // Developer Credit
                const SizedBox(height: 32),
                Text(
                  'Developed by ${AppConstants.developerName}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textGrey,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'v${AppConstants.appVersion}',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textGrey.withOpacity(0.7),
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
