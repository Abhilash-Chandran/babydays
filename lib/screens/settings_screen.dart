import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          // ── Appearance section ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Text(
              'Appearance',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          _ThemeTile(
            title: 'System default',
            subtitle: 'Follow your device setting',
            icon: Icons.brightness_auto,
            selected: themeProvider.mode == ThemeMode.system,
            onTap: () => themeProvider.setMode(ThemeMode.system),
          ),
          _ThemeTile(
            title: 'Light',
            subtitle: 'Always use light theme',
            icon: Icons.light_mode,
            selected: themeProvider.mode == ThemeMode.light,
            onTap: () => themeProvider.setMode(ThemeMode.light),
          ),
          _ThemeTile(
            title: 'Dark',
            subtitle: 'Always use dark theme',
            icon: Icons.dark_mode,
            selected: themeProvider.mode == ThemeMode.dark,
            onTap: () => themeProvider.setMode(ThemeMode.dark),
          ),
          const Divider(height: 32),
          // ── Color palette section ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Text(
              'Color Palette',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          SizedBox(
            height: 130,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: AppPalette.values.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final palette = AppPalette.values[index];
                final data = AppTheme.palettes[palette]!;
                final selected = themeProvider.palette == palette;
                return _PaletteCard(
                  palette: palette,
                  data: data,
                  selected: selected,
                  onTap: () => themeProvider.setPalette(palette),
                );
              },
            ),
          ),
          const Divider(height: 32),
          // ── Sync section ──
          _buildSyncSection(context, theme),
          const Divider(height: 32),
          // ── About section ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Text(
              'About',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('BabyDays'),
            subtitle: const Text('Version 1.0.0'),
          ),
        ],
      ),
    );
  }

  Widget _buildSyncSection(BuildContext context, ThemeData theme) {
    // AuthService is only provided when Firebase is configured.
    final authService = context.watch<AuthService?>();

    if (authService == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Text(
              'Cloud Sync',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          const ListTile(
            leading: Icon(Icons.cloud_off),
            title: Text('Local storage only'),
            subtitle: Text('Firebase not configured'),
          ),
        ],
      );
    }

    final isAnonymous = authService.isAnonymous;
    final email = authService.email;
    final name = authService.displayName;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Text(
            'Cloud Sync',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        ListTile(
          leading: Icon(
            authService.isSignedIn ? Icons.cloud_done : Icons.cloud_off,
            color: authService.isSignedIn ? theme.colorScheme.primary : null,
          ),
          title: Text(
            isAnonymous
                ? 'Signed in anonymously'
                : 'Signed in as ${name ?? email ?? 'unknown'}',
          ),
          subtitle: Text(
            isAnonymous
                ? 'Sign in to sync across devices'
                : 'Data syncs across all your devices',
          ),
        ),
        if (isAnonymous) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _SignInButtons(authService: authService),
          ),
        ],
        if (!isAnonymous)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextButton.icon(
              onPressed: () => authService.signOut(),
              icon: const Icon(Icons.logout),
              label: const Text('Sign out'),
            ),
          ),
      ],
    );
  }
}

class _PaletteCard extends StatelessWidget {
  final AppPalette palette;
  final ColorPaletteData data;
  final bool selected;
  final VoidCallback onTap;

  const _PaletteCard({
    required this.palette,
    required this.data,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 100,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? data.primary : theme.dividerColor,
            width: selected ? 2.5 : 1,
          ),
        ),
        padding: const EdgeInsets.all(8),
        clipBehavior: Clip.hardEdge,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Color swatches row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _dot(data.primary),
                _dot(data.breastFeedLight),
                _dot(data.formulaLight),
              ],
            ),
            const SizedBox(height: 3),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _dot(data.diaperLight),
                _dot(data.sleepLight),
                _dot(data.lightBg),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              palette.label,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? data.primary : null,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (selected)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(Icons.check_circle, size: 14, color: data.primary),
              ),
          ],
        ),
      ),
    );
  }

  Widget _dot(Color color) {
    return Container(
      width: 16,
      height: 16,
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black12, width: 0.5),
      ),
    );
  }
}

class _ThemeTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, color: selected ? theme.colorScheme.primary : null),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          color: selected ? theme.colorScheme.primary : null,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: selected
          ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
          : null,
      onTap: onTap,
    );
  }
}

// ── Sign-in buttons ─────────────────────────────────────────────────────────

class _SignInButtons extends StatelessWidget {
  final AuthService authService;

  const _SignInButtons({required this.authService});

  bool get _showApple => !kIsWeb && (Platform.isIOS || Platform.isMacOS);

  Future<void> _handleError(BuildContext context, Object e) async {
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Sign-in failed: $e')));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Google
        OutlinedButton.icon(
          onPressed: () async {
            try {
              await authService.signInWithGoogle();
            } catch (e) {
              if (context.mounted) {
                _handleError(context, e);
              }
            }
          },
          icon: const Icon(Icons.g_mobiledata, size: 24),
          label: const Text('Continue with Google'),
        ),
        const SizedBox(height: 8),
        // Apple (only on Apple platforms)
        if (_showApple) ...[
          OutlinedButton.icon(
            onPressed: () async {
              try {
                await authService.signInWithApple();
              } catch (e) {
                if (context.mounted) {
                  _handleError(context, e);
                }
              }
            },
            icon: const Icon(Icons.apple, size: 22),
            label: const Text('Continue with Apple'),
          ),
          const SizedBox(height: 8),
        ],
        // Email / password
        OutlinedButton.icon(
          onPressed: () => _showEmailDialog(context),
          icon: const Icon(Icons.email_outlined, size: 20),
          label: const Text('Continue with Email'),
        ),
      ],
    );
  }

  void _showEmailDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => _EmailSignInDialog(authService: authService),
    );
  }
}

// ── Email sign-in dialog ────────────────────────────────────────────────────

class _EmailSignInDialog extends StatefulWidget {
  final AuthService authService;

  const _EmailSignInDialog({required this.authService});

  @override
  State<_EmailSignInDialog> createState() => _EmailSignInDialogState();
}

class _EmailSignInDialogState extends State<_EmailSignInDialog> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isRegister = false;
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    String? error;
    if (_isRegister) {
      error = await widget.authService.registerWithEmail(email, password);
    } else {
      error = await widget.authService.signInWithEmail(email, password);
    }

    if (!mounted) return;

    if (error != null) {
      setState(() {
        _error = error;
        _isLoading = false;
      });
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() => _error = 'Enter your email address first');
      return;
    }
    final error = await widget.authService.resetPassword(email);
    if (!mounted) return;
    if (error != null) {
      setState(() => _error = error);
    } else {
      setState(() => _error = null);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset email sent')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isRegister ? 'Create Account' : 'Sign In'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'Email'),
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _passwordController,
            decoration: const InputDecoration(labelText: 'Password'),
            obscureText: true,
            autofillHints: const [AutofillHints.password],
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => setState(() {
            _isRegister = !_isRegister;
            _error = null;
          }),
          child: Text(
            _isRegister ? 'Have an account? Sign in' : 'New? Register',
          ),
        ),
        if (!_isRegister)
          TextButton(
            onPressed: _isLoading ? null : _resetPassword,
            child: const Text('Forgot password?'),
          ),
        FilledButton(
          onPressed: _isLoading ? null : _submit,
          child: _isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(_isRegister ? 'Register' : 'Sign In'),
        ),
      ],
    );
  }
}
