import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FirebaseAuthGate extends StatelessWidget {
  final Widget authenticatedChild;

  const FirebaseAuthGate({super.key, required this.authenticatedChild});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Error al verificar sesión: ${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }

        if (snapshot.data != null) {
          return authenticatedChild;
        }

        return const _EmailPasswordAuthScreen();
      },
    );
  }
}

/// Observa el ciclo de vida de la app y cierra la sesión de Firebase cuando
/// la app pasa a segundo plano o se cierra, forzando un nuevo inicio de sesión
/// o la autenticación biométrica en el siguiente arranque.
class SessionLifecycleSignOut extends StatefulWidget {
  final Widget child;

  const SessionLifecycleSignOut({super.key, required this.child});

  @override
  State<SessionLifecycleSignOut> createState() => _SessionLifecycleSignOutState();
}

class _SessionLifecycleSignOutState extends State<SessionLifecycleSignOut>
    with WidgetsBindingObserver {
  bool _signingOut = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      _signOut();
    }
  }

  Future<void> _signOut() async {
    if (_signingOut) return;
    _signingOut = true;
    try {
      await FirebaseAuth.instance.signOut();
    } finally {
      _signingOut = false;
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _EmailPasswordAuthScreen extends StatefulWidget {
  const _EmailPasswordAuthScreen();

  @override
  State<_EmailPasswordAuthScreen> createState() => _EmailPasswordAuthScreenState();
}

class _EmailPasswordAuthScreenState extends State<_EmailPasswordAuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isRegisterMode = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      if (email.isEmpty || password.isEmpty) {
        throw FirebaseAuthException(
          code: 'empty-fields',
          message: 'Ingresa correo y contraseña para continuar.',
        );
      }

      if (_isRegisterMode) {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
      } else {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      }
    } on FirebaseAuthException catch (error) {
      setState(() {
        _error = error.message ?? 'No se pudo completar la operación.';
      });
    } catch (_) {
      setState(() {
        _error = 'No se pudo completar la operación.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _signInAnonymously() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await FirebaseAuth.instance.signInAnonymously();
    } on FirebaseAuthException catch (error) {
      setState(() {
        _error = error.message ?? 'No se pudo iniciar sesión anónima.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = _isRegisterMode ? 'Crear cuenta' : 'Iniciar sesión';
    final actionLabel = _isRegisterMode ? 'Registrarme' : 'Entrar';
    final toggleLabel = _isRegisterMode ? '¿Ya tienes cuenta? Inicia sesión' : '¿Aún no tienes cuenta? Regístrate';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                decoration: const InputDecoration(
                  labelText: 'Correo electrónico',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                autofillHints: const [AutofillHints.password],
                decoration: const InputDecoration(
                  labelText: 'Contraseña (6+ caracteres)',
                ),
              ),
              const SizedBox(height: 12),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    _error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              FilledButton.icon(
                onPressed: _loading ? null : _submit,
                icon: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.lock_open),
                label: Text(actionLabel),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _loading
                    ? null
                    : () {
                        setState(() {
                          _isRegisterMode = !_isRegisterMode;
                          _error = null;
                        });
                      },
                child: Text(toggleLabel),
              ),
              const Divider(height: 32),
              OutlinedButton.icon(
                onPressed: _loading ? null : _signInAnonymously,
                icon: const Icon(Icons.person),
                label: const Text('Entrar sin cuenta (anónimo)'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
