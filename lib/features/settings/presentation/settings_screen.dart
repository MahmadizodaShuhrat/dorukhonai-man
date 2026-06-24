import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/locale_provider.dart';
import '../../../app/theme_mode_provider.dart';
import '../../../core/api/api_result.dart';
import '../../../core/config/api_config.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/app_scaffold.dart';
import '../../../shared/app_toast.dart';
import '../../../shared/empty_state.dart';
import '../../../shared/loading_state.dart';
import '../../../shared/status_chip.dart';
import '../../auth/data/auth_models.dart';
import '../../auth/presentation/auth_provider.dart';
import '../data/users_repository.dart';
import 'settings_provider.dart';

/// Settings screen (TZ_03 §C.7). Real, sectioned settings: server URL, expiry
/// alerts, markup placeholder, printer placeholder, and the current-user /
/// logout block (plus an Admin user list). [SettingsScreen] is the class wired
/// into `router.dart`; only its internals are reworked.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final user = ref.watch(authControllerProvider).user;
    final isAdmin = user?.role == UserRole.admin;
    return AppScaffold(
      title: l.settingsTitle,
      icon: Icons.settings,
      subtitle: l.settingsSubtitle,
      body: ListView(
        children: [
          const _AppearanceSection(),
          const SizedBox(height: 16),
          const _LanguageSection(),
          const SizedBox(height: 16),
          const _ServerSection(),
          const SizedBox(height: 16),
          const _AlertSection(),
          const SizedBox(height: 16),
          const _MarkupSection(),
          const SizedBox(height: 16),
          const _PrinterSection(),
          const SizedBox(height: 16),
          const _UserSection(),
          if (isAdmin) ...[
            const SizedBox(height: 16),
            const _UsersAdminSection(),
          ],
          const SizedBox(height: 16),
          const _AboutSection(),
        ],
      ),
    );
  }
}

/// A bordered, titled settings card (flat-bordered, TZ_03 §B.6).
class _SettingsCard extends StatelessWidget {
  const _SettingsCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: theme.colorScheme.primary),
              const SizedBox(width: 10),
              Text(
                title.toUpperCase(),
                style: theme.textTheme.titleSmall?.copyWith(
                  letterSpacing: 0.4,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// НАМУДИ НАМОИШ (theme)
// ---------------------------------------------------------------------------

class _AppearanceSection extends ConsumerWidget {
  const _AppearanceSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final mode = ref.watch(themeModeControllerProvider);
    final controller = ref.read(themeModeControllerProvider.notifier);
    return _SettingsCard(
      title: l.settingsAppearance,
      icon: Icons.brightness_6_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.settingsThemeLabel,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          SegmentedButton<ThemeMode>(
            segments: [
              ButtonSegment(
                value: ThemeMode.system,
                label: Text(l.settingsThemeSystem),
                icon: const Icon(Icons.brightness_auto_outlined),
              ),
              ButtonSegment(
                value: ThemeMode.light,
                label: Text(l.settingsThemeLight),
                icon: const Icon(Icons.light_mode_outlined),
              ),
              ButtonSegment(
                value: ThemeMode.dark,
                label: Text(l.settingsThemeDark),
                icon: const Icon(Icons.dark_mode_outlined),
              ),
            ],
            selected: {mode},
            onSelectionChanged: (s) => controller.set(s.first),
          ),
          const SizedBox(height: 8),
          Text(
            l.settingsThemeHint,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// ЗАБОН / ЯЗЫК (language)
// ---------------------------------------------------------------------------

/// Language selector (Тоҷикӣ / Русский), mirroring [_AppearanceSection]. Flips
/// the app locale via [localeControllerProvider] (persisted via AppPreferences).
class _LanguageSection extends ConsumerWidget {
  const _LanguageSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final locale = ref.watch(localeControllerProvider);
    final controller = ref.read(localeControllerProvider.notifier);
    final code = locale.languageCode == 'ru' ? 'ru' : 'tg';
    return _SettingsCard(
      title: l.settingsLanguage,
      icon: Icons.translate_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.settingsLanguageLabel,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          SegmentedButton<String>(
            segments: [
              ButtonSegment(
                value: 'tg',
                label: Text(l.settingsLanguageTajik),
                icon: const Icon(Icons.language_outlined),
              ),
              ButtonSegment(
                value: 'ru',
                label: Text(l.settingsLanguageRussian),
                icon: const Icon(Icons.language_outlined),
              ),
            ],
            selected: {code},
            onSelectionChanged: (s) => controller.setCode(s.first),
          ),
          const SizedBox(height: 8),
          Text(
            l.settingsLanguageHint,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// СЕРВЕР
// ---------------------------------------------------------------------------

class _ServerSection extends ConsumerStatefulWidget {
  const _ServerSection();

  @override
  ConsumerState<_ServerSection> createState() => _ServerSectionState();
}

class _ServerSectionState extends ConsumerState<_ServerSection> {
  late final TextEditingController _urlController;

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController(
      text: ref.read(serverConfigProvider).baseUrl,
    );
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final controller = ref.read(serverConfigProvider.notifier);
    final config = ref.watch(serverConfigProvider);
    final locked = controller.isLocked;
    final testState = ref.watch(connectionTestProvider);

    // Keep the field in sync when the config changes elsewhere (e.g. reset).
    if (_urlController.text != config.baseUrl &&
        !_urlController.value.isComposingRangeValid) {
      _urlController.text = config.baseUrl;
    }

    return _SettingsCard(
      title: l.settingsServer,
      icon: Icons.dns_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                l.settingsServerCurrentUrl,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Expanded(
                child: Text(
                  config.baseUrl,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _urlController,
            enabled: !locked,
            decoration: InputDecoration(
              labelText: l.settingsServerField,
              prefixIcon: const Icon(Icons.link, size: 16),
              isDense: true,
              helperText: locked
                  ? l.settingsServerLocked
                  : l.settingsServerExample,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              FilledButton.icon(
                onPressed: locked ? null : () => _save(controller),
                icon: const Icon(Icons.save_outlined, size: 18),
                label: Text(l.commonSave),
              ),
              OutlinedButton.icon(
                onPressed: testState == ConnectionTestState.testing
                    ? null
                    : () => ref.read(connectionTestProvider.notifier).test(),
                icon: const Icon(Icons.wifi_tethering, size: 18),
                label: Text(l.settingsTestConnection),
              ),
              TextButton.icon(
                onPressed: locked ? null : () => _reset(controller),
                icon: const Icon(Icons.restart_alt, size: 18),
                label: Text(l.commonRestore),
              ),
              _testBadge(testState),
            ],
          ),
        ],
      ),
    );
  }

  Widget _testBadge(ConnectionTestState state) {
    final l = AppLocalizations.of(context);
    return switch (state) {
      ConnectionTestState.idle => const SizedBox.shrink(),
      ConnectionTestState.testing => const SizedBox(
        height: 18,
        width: 18,
        child: CircularProgressIndicator(strokeWidth: 2.5),
      ),
      ConnectionTestState.ok => StatusChip(
        label: l.settingsConnected,
        tone: StatusTone.ok,
        icon: Icons.check_circle_outline,
      ),
      ConnectionTestState.failed => StatusChip(
        label: l.settingsNotConnected,
        tone: StatusTone.danger,
        icon: Icons.error_outline,
      ),
    };
  }

  Future<void> _save(ServerConfigController controller) async {
    final normalized = await controller.update(_urlController.text);
    if (!mounted) return;
    final l = AppLocalizations.of(context);
    if (normalized == null) {
      AppToast.error(context, l.settingsInvalidUrl);
    } else {
      _urlController.text = normalized;
      ref.read(connectionTestProvider.notifier).reset();
      AppToast.success(context, l.settingsUrlSaved);
    }
  }

  Future<void> _reset(ServerConfigController controller) async {
    await controller.reset();
    if (!mounted) return;
    final l = AppLocalizations.of(context);
    _urlController.text = ref.read(serverConfigProvider).baseUrl;
    ref.read(connectionTestProvider.notifier).reset();
    AppToast.info(context, l.settingsUrlReset);
  }
}

// ---------------------------------------------------------------------------
// ОГОҲӢ
// ---------------------------------------------------------------------------

class _AlertSection extends ConsumerWidget {
  const _AlertSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final settings = ref.watch(settingsControllerProvider);
    final controller = ref.read(settingsControllerProvider.notifier);
    const options = [30, 60, 90];
    // The server may store an out-of-range value; snap to the nearest segment so
    // the SegmentedButton's selected set is always a valid subset.
    final selected = options.contains(settings.alertDays)
        ? settings.alertDays
        : options.reduce(
            (a, b) => (settings.alertDays - a).abs() <=
                    (settings.alertDays - b).abs()
                ? a
                : b,
          );
    return _SettingsCard(
      title: l.settingsAlert,
      icon: Icons.notifications_active_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.settingsAlertHorizon,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          SegmentedButton<int>(
            segments: [
              ButtonSegment(value: 30, label: Text(l.settingsAlertDays(30))),
              ButtonSegment(value: 60, label: Text(l.settingsAlertDays(60))),
              ButtonSegment(value: 90, label: Text(l.settingsAlertDays(90))),
            ],
            selected: {selected},
            onSelectionChanged: (s) => controller.setAlertDays(s.first),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// НАРХ (placeholder)
// ---------------------------------------------------------------------------

class _MarkupSection extends ConsumerStatefulWidget {
  const _MarkupSection();

  @override
  ConsumerState<_MarkupSection> createState() => _MarkupSectionState();
}

class _MarkupSectionState extends ConsumerState<_MarkupSection> {
  late final TextEditingController _markupController;

  @override
  void initState() {
    super.initState();
    _markupController = TextEditingController(
      text: ref
          .read(settingsControllerProvider)
          .markupPercent
          .toStringAsFixed(0),
    );
  }

  @override
  void dispose() {
    _markupController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return _SettingsCard(
      title: l.settingsMarkup,
      icon: Icons.percent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.settingsMarkupLabel,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              SizedBox(
                width: 160,
                child: TextField(
                  controller: _markupController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                  ],
                  decoration: InputDecoration(
                    labelText: l.settingsMarkupField,
                    isDense: true,
                    suffixText: '%',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              FilledButton.tonal(
                onPressed: () {
                  final value =
                      double.tryParse(_markupController.text.trim()) ?? 0;
                  ref
                      .read(settingsControllerProvider.notifier)
                      .setMarkupPercent(value);
                  AppToast.success(context, l.settingsMarkupSaved);
                },
                child: Text(l.commonSave),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            l.settingsMarkupHint,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// ПРИНТЕР (placeholder)
// ---------------------------------------------------------------------------

class _PrinterSection extends StatelessWidget {
  const _PrinterSection();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return _SettingsCard(
      title: l.settingsPrinter,
      icon: Icons.print_outlined,
      child: Row(
        children: [
          Expanded(
            child: Text(
              l.settingsPrinterHint,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const SizedBox(width: 12),
          StatusChip(label: l.settingsSystem, tone: StatusTone.info),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// КОРБАР (current user + logout)
// ---------------------------------------------------------------------------

class _UserSection extends ConsumerWidget {
  const _UserSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final user = ref.watch(authControllerProvider).user;
    return _SettingsCard(
      title: l.settingsUser,
      icon: Icons.account_circle_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(child: Text(_initials(user?.fullName ?? '?'))),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user?.fullName ?? l.shellUserFallback,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    '@${user?.userName ?? '—'}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(width: 14),
              if (user != null)
                StatusChip(label: user.role.wire, tone: StatusTone.info),
            ],
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () async {
              await ref.read(authControllerProvider.notifier).logout();
              if (context.mounted) context.go('/login');
            },
            icon: const Icon(Icons.logout, size: 18),
            label: Text(l.settingsLogout),
          ),
        ],
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return (parts.first.characters.first + parts[1].characters.first)
        .toUpperCase();
  }
}

// ---------------------------------------------------------------------------
// КОРБАРОН (Admin user list)
// ---------------------------------------------------------------------------

class _UsersAdminSection extends ConsumerWidget {
  const _UsersAdminSection();

  Future<void> _create(BuildContext context, WidgetRef ref) async {
    final form = await UserFormDialog.show(context);
    if (form == null) return;
    final repo = ref.read(usersRepositoryProvider);
    final result = await repo.create(
      fullName: form.fullName,
      userName: form.userName,
      password: form.password ?? '',
      role: form.role,
    );
    if (!context.mounted) return;
    final l = AppLocalizations.of(context);
    switch (result) {
      case Success():
        ref.invalidate(usersListProvider);
        AppToast.success(context, l.settingsUserAdded);
      case Error(:final failure):
        AppToast.error(context, failure.message);
    }
  }

  Future<void> _edit(BuildContext context, WidgetRef ref, User user) async {
    final form = await UserFormDialog.show(context, existing: user);
    if (form == null) return;
    final repo = ref.read(usersRepositoryProvider);
    final result = await repo.update(
      id: user.id,
      fullName: form.fullName,
      role: form.role,
    );
    if (!context.mounted) return;
    final l = AppLocalizations.of(context);
    switch (result) {
      case Success():
        ref.invalidate(usersListProvider);
        AppToast.success(context, l.settingsUserUpdated);
      case Error(:final failure):
        AppToast.error(context, failure.message);
    }
  }

  Future<void> _deactivate(BuildContext context, WidgetRef ref, User user) async {
    final l = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.settingsDeactivateTitle),
        content: Text(l.settingsDeactivateBody(user.fullName)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l.commonConfirm),
          ),
        ],
      ),
    );
    if (ok != true) return;
    final repo = ref.read(usersRepositoryProvider);
    final result = await repo.deactivate(user.id);
    if (!context.mounted) return;
    switch (result) {
      case Success():
        ref.invalidate(usersListProvider);
        AppToast.success(context, l.settingsUserDeactivated);
      case Error(:final failure):
        AppToast.error(context, failure.message);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final async = ref.watch(usersListProvider);
    return _SettingsCard(
      title: l.settingsUsers,
      icon: Icons.group_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: () => _create(context, ref),
              icon: const Icon(Icons.person_add_alt, size: 18),
              label: Text(l.settingsNewUser),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 260,
            child: async.when(
              loading: () => const LoadingState(),
              error: (err, _) => EmptyState(
                icon: Icons.error_outline,
                title: l.commonError,
                message: err is Failure ? err.message : l.commonLoadFailed,
                action: FilledButton.tonalIcon(
                  onPressed: () => ref.invalidate(usersListProvider),
                  icon: const Icon(Icons.refresh),
                  label: Text(l.commonRetry),
                ),
              ),
              data: (users) {
                if (users.isEmpty) {
                  return EmptyState(message: l.settingsNoUsers);
                }
                return ListView.separated(
                  itemCount: users.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final u = users[i];
                    return ListTile(
                      dense: true,
                      leading: const Icon(Icons.person_outline),
                      title: Text(u.fullName),
                      subtitle: Text('@${u.userName}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          StatusChip(label: u.role.wire, tone: StatusTone.info),
                          IconButton(
                            tooltip: l.settingsEditTooltip,
                            icon: const Icon(Icons.edit_outlined, size: 18),
                            onPressed: () => _edit(context, ref, u),
                          ),
                          IconButton(
                            tooltip: l.settingsDeactivateTooltip,
                            icon: const Icon(Icons.person_off_outlined, size: 18),
                            onPressed: () => _deactivate(context, ref, u),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Result of the [UserFormDialog]: the entered fields. [password] is only set on
/// create (edit does not change the password per the contract).
class UserFormResult {
  const UserFormResult({
    required this.fullName,
    required this.userName,
    required this.role,
    this.password,
  });

  final String fullName;
  final String userName;
  final UserRole role;
  final String? password;
}

/// Create / edit user form (Admin). On create all fields are editable; on edit
/// the username is locked and the password field is hidden (PUT only changes
/// fullName/role per the contract).
class UserFormDialog extends StatefulWidget {
  const UserFormDialog({super.key, this.existing});

  final User? existing;

  static Future<UserFormResult?> show(BuildContext context, {User? existing}) {
    return showDialog<UserFormResult>(
      context: context,
      builder: (_) => UserFormDialog(existing: existing),
    );
  }

  @override
  State<UserFormDialog> createState() => _UserFormDialogState();
}

class _UserFormDialogState extends State<UserFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _fullName;
  late final TextEditingController _userName;
  final _password = TextEditingController();
  late UserRole _role;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    _fullName = TextEditingController(text: widget.existing?.fullName ?? '');
    _userName = TextEditingController(text: widget.existing?.userName ?? '');
    _role = widget.existing?.role ?? UserRole.seller;
  }

  @override
  void dispose() {
    _fullName.dispose();
    _userName.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.of(context).pop(
      UserFormResult(
        fullName: _fullName.text.trim(),
        userName: _userName.text.trim(),
        role: _role,
        password: _isEdit ? null : _password.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(_isEdit ? l.settingsEditUser : l.settingsNewUser),
      content: SizedBox(
        width: 380,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _fullName,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: l.settingsFullName,
                  isDense: true,
                ),
                validator: (v) =>
                    (v ?? '').trim().isEmpty ? l.commonRequired : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _userName,
                enabled: !_isEdit,
                decoration: InputDecoration(
                  labelText: l.settingsUserName,
                  isDense: true,
                ),
                validator: (v) =>
                    (v ?? '').trim().isEmpty ? l.commonRequired : null,
              ),
              if (!_isEdit) ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _password,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: l.settingsPassword,
                    isDense: true,
                  ),
                  validator: (v) =>
                      (v ?? '').length < 4 ? l.settingsPasswordMin : null,
                ),
              ],
              const SizedBox(height: 12),
              DropdownButtonFormField<UserRole>(
                initialValue: _role,
                decoration: InputDecoration(
                  labelText: l.settingsRole,
                  isDense: true,
                ),
                items: [
                  for (final r in UserRole.values)
                    DropdownMenuItem(value: r, child: Text(r.wire)),
                ],
                onChanged: (v) => setState(() => _role = v ?? UserRole.seller),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l.commonCancel),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(_isEdit ? l.commonSave : l.commonAdd),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Дар бораи
// ---------------------------------------------------------------------------

class _AboutSection extends StatelessWidget {
  const _AboutSection();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return _SettingsCard(
      title: l.settingsAbout,
      icon: Icons.info_outline,
      child: Row(
        children: [
          Expanded(
            child: Text(
              l.settingsAboutText,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const StatusChip(label: 'Desktop', tone: StatusTone.sync),
        ],
      ),
    );
  }
}
