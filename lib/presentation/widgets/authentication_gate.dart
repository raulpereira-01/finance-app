// Barrera de autenticación biométrica o PIN que protege el acceso a la app.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:local_auth/local_auth.dart';

import '../../l10n/app_localizations.dart';

enum _AuthState {
  checking,
  available,
  unsupported,
  noBiometrics,
  lockedOut,
  failed,
}

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
  _AuthState _state = _AuthState.checking;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _authenticate());
  }

  Future<void> _authenticate() async {
    setState(() {
      _loading = true;
      _state = _AuthState.checking;
    });

    try {
      final supported = await _localAuth.isDeviceSupported();
      if (!mounted) return;

      if (!supported) {
        setState(() {
          _authorized = false;
          _loading = false;
          _state = _AuthState.unsupported;
        });
        return;
      }

      final didAuthenticate = await _localAuth.authenticate(
        localizedReason: AppLocalizations.of(context).authenticationMessage,
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );

      if (!mounted) return;

      setState(() {
        _authorized = didAuthenticate;
        _loading = false;
        _state = didAuthenticate ? _AuthState.available : _AuthState.failed;
      });
    } on PlatformException catch (error) {
      if (!mounted) return;

      _AuthState derivedState = _AuthState.failed;
      if (error.code == auth_error.lockedOut ||
          error.code == auth_error.permanentlyLockedOut) {
        derivedState = _AuthState.lockedOut;
      } else if (error.code == auth_error.notEnrolled ||
          error.code == auth_error.notAvailable) {
        derivedState = _AuthState.noBiometrics;
      }

      setState(() {
        _authorized = false;
        _loading = false;
        _state = derivedState;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_authorized) {
      return widget.child;
    }

    final l10n = AppLocalizations.of(context);
    final String? message;

    switch (_state) {
      case _AuthState.unsupported:
        message = l10n.authenticationNotSupported;
        break;
      case _AuthState.noBiometrics:
        message = l10n.authenticationNoBiometrics;
        break;
      case _AuthState.lockedOut:
        message = l10n.authenticationLockedOut;
        break;
      case _AuthState.failed:
        message = l10n.authenticationFailed;
        break;
      default:
        message = null;
        break;
    }

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
                if (message != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      message,
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
