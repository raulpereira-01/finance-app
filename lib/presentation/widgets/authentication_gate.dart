import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

import '../../l10n/app_localizations.dart';

class AuthenticationGate extends StatefulWidget {
  final Widget child;

  const AuthenticationGate({super.key, required this.child});

  @override
  State<AuthenticationGate> createState() => _AuthenticationGateState();
}

class _AuthenticationGateState extends State<AuthenticationGate> {
  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _authorized = false;
  bool _loading = true;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _authenticate());
  }

  Future<void> _authenticate() async {
    setState(() {
      _loading = true;
      _failed = false;
    });

    try {
      final didAuthenticate = await _localAuth.authenticate(
        localizedReason:
            AppLocalizations.of(context).authenticationMessage,
        useErrorDialogs: true,
        stickyAuth: true,
        biometricOnly: false,
      );

      if (!mounted) return;

      setState(() {
        _authorized = didAuthenticate;
        _loading = false;
        _failed = !didAuthenticate;
      });
    } on PlatformException {
      if (!mounted) return;
      setState(() {
        _authorized = false;
        _loading = false;
        _failed = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_authorized) {
      return widget.child;
    }

    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_outline,
                size: 72,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.authenticationTitle,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.authenticationMessage,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              if (_loading)
                Column(
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 12),
                    Text(l10n.authenticationChecking),
                  ],
                )
              else ...[
                if (_failed)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      l10n.authenticationFailed,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ElevatedButton.icon(
                  onPressed: _authenticate,
                  icon: const Icon(Icons.fingerprint),
                  label: Text(l10n.authenticationRetry),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
