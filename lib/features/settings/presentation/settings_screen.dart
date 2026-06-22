import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_result.dart';
import '../../../core/config/api_config.dart';
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
    final user = ref.watch(authControllerProvider).user;
    final isAdmin = user?.role == UserRole.admin;
    return AppScaffold(
      title: 'Танзимот',
      icon: Icons.settings,
      subtitle: 'Сервер · огоҳӣ · нарх · принтер · корбар',
      body: ListView(
        children: [
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
      title: 'Сервер',
      icon: Icons.dns_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'URL-и ҷорӣ: ',
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
              labelText: 'Суроғаи сервер (scheme://host:port/api/v1)',
              prefixIcon: const Icon(Icons.link, size: 16),
              isDense: true,
              helperText: locked
                  ? 'Аз --dart-define муайян шуда — таҳрир мумкин нест.'
                  : 'Мисол: http://192.168.1.10:5000/api/v1',
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
                label: const Text('Нигоҳ доштан'),
              ),
              OutlinedButton.icon(
                onPressed: testState == ConnectionTestState.testing
                    ? null
                    : () => ref.read(connectionTestProvider.notifier).test(),
                icon: const Icon(Icons.wifi_tethering, size: 18),
                label: const Text('Санҷиши пайваст'),
              ),
              TextButton.icon(
                onPressed: locked ? null : () => _reset(controller),
                icon: const Icon(Icons.restart_alt, size: 18),
                label: const Text('Барқарор'),
              ),
              _testBadge(testState),
            ],
          ),
        ],
      ),
    );
  }

  Widget _testBadge(ConnectionTestState state) => switch (state) {
    ConnectionTestState.idle => const SizedBox.shrink(),
    ConnectionTestState.testing => const SizedBox(
      height: 18,
      width: 18,
      child: CircularProgressIndicator(strokeWidth: 2.5),
    ),
    ConnectionTestState.ok => const StatusChip(
      label: 'Пайваст шуд',
      tone: StatusTone.ok,
      icon: Icons.check_circle_outline,
    ),
    ConnectionTestState.failed => const StatusChip(
      label: 'Пайваст нашуд',
      tone: StatusTone.danger,
      icon: Icons.error_outline,
    ),
  };

  Future<void> _save(ServerConfigController controller) async {
    final normalized = await controller.update(_urlController.text);
    if (!mounted) return;
    if (normalized == null) {
      AppToast.error(context, 'Суроғаи нодуруст. http(s)://host… ворид кунед.');
    } else {
      _urlController.text = normalized;
      ref.read(connectionTestProvider.notifier).reset();
      AppToast.success(context, 'Суроғаи сервер нигоҳ дошта шуд.');
    }
  }

  Future<void> _reset(ServerConfigController controller) async {
    await controller.reset();
    if (!mounted) return;
    _urlController.text = ref.read(serverConfigProvider).baseUrl;
    ref.read(connectionTestProvider.notifier).reset();
    AppToast.info(context, 'Ба суроғаи пешфарз баргардонида шуд.');
  }
}

// ---------------------------------------------------------------------------
// ОГОҲӢ
// ---------------------------------------------------------------------------

class _AlertSection extends ConsumerWidget {
  const _AlertSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
      title: 'Огоҳӣ',
      icon: Icons.notifications_active_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Уфуқи огоҳии мӯҳлат (рӯз):',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 30, label: Text('30 рӯз')),
              ButtonSegment(value: 60, label: Text('60 рӯз')),
              ButtonSegment(value: 90, label: Text('90 рӯз')),
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
    return _SettingsCard(
      title: 'Нарх',
      icon: Icons.percent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Наценкаи пешфарз (барои модули нархгузорӣ):',
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
                  decoration: const InputDecoration(
                    labelText: 'Наценка %',
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
                  AppToast.success(context, 'Наценка нигоҳ дошта шуд.');
                },
                child: const Text('Нигоҳ доштан'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Эзоҳ: дар сервер нигоҳ дошта мешавад ва ҳамчун наценкаи '
            'пешфарзи нархи фурӯш ҳангоми приход истифода мешавад.',
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
    return _SettingsCard(
      title: 'Принтер',
      icon: Icons.print_outlined,
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Чопи чек тавассути диалоги системавии чоп (printing). '
              'Интихоби принтери пешфарз дар нусхаи минбаъда илова мешавад.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const SizedBox(width: 12),
          const StatusChip(label: 'Системавӣ', tone: StatusTone.info),
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
    final user = ref.watch(authControllerProvider).user;
    return _SettingsCard(
      title: 'Корбар',
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
                    user?.fullName ?? 'Корбар',
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
            label: const Text('Баромадан'),
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
    switch (result) {
      case Success():
        ref.invalidate(usersListProvider);
        AppToast.success(context, 'Корбар илова шуд.');
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
    switch (result) {
      case Success():
        ref.invalidate(usersListProvider);
        AppToast.success(context, 'Корбар таҳрир шуд.');
      case Error(:final failure):
        AppToast.error(context, failure.message);
    }
  }

  Future<void> _deactivate(BuildContext context, WidgetRef ref, User user) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ғайрифаъол кардан'),
        content: Text('«${user.fullName}»-ро ғайрифаъол мекунед?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Бекор'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Тасдиқ'),
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
        AppToast.success(context, 'Корбар ғайрифаъол шуд.');
      case Error(:final failure):
        AppToast.error(context, failure.message);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(usersListProvider);
    return _SettingsCard(
      title: 'Корбарон',
      icon: Icons.group_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: () => _create(context, ref),
              icon: const Icon(Icons.person_add_alt, size: 18),
              label: const Text('Корбари нав'),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 260,
            child: async.when(
              loading: () => const LoadingState(),
              error: (err, _) => EmptyState(
                icon: Icons.error_outline,
                title: 'Хатогӣ',
                message: err is Failure ? err.message : 'Боркунӣ ноком шуд.',
                action: FilledButton.tonalIcon(
                  onPressed: () => ref.invalidate(usersListProvider),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Аз нав'),
                ),
              ),
              data: (users) {
                if (users.isEmpty) {
                  return const EmptyState(message: 'Корбар нест');
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
                            tooltip: 'Таҳрир',
                            icon: const Icon(Icons.edit_outlined, size: 18),
                            onPressed: () => _edit(context, ref, u),
                          ),
                          IconButton(
                            tooltip: 'Ғайрифаъол',
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
    return AlertDialog(
      title: Text(_isEdit ? 'Таҳрири корбар' : 'Корбари нав'),
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
                decoration: const InputDecoration(
                  labelText: 'Ному насаб *',
                  isDense: true,
                ),
                validator: (v) =>
                    (v ?? '').trim().isEmpty ? 'Ҳатмист' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _userName,
                enabled: !_isEdit,
                decoration: const InputDecoration(
                  labelText: 'Номи корбар (login) *',
                  isDense: true,
                ),
                validator: (v) =>
                    (v ?? '').trim().isEmpty ? 'Ҳатмист' : null,
              ),
              if (!_isEdit) ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _password,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Парол *',
                    isDense: true,
                  ),
                  validator: (v) =>
                      (v ?? '').length < 4 ? 'Камаш 4 аломат' : null,
                ),
              ],
              const SizedBox(height: 12),
              DropdownButtonFormField<UserRole>(
                initialValue: _role,
                decoration: const InputDecoration(
                  labelText: 'Нақш *',
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
          child: const Text('Бекор'),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(_isEdit ? 'Нигоҳ доштан' : 'Илова'),
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
    return _SettingsCard(
      title: 'Дар бораи',
      icon: Icons.info_outline,
      child: Row(
        children: [
          Expanded(
            child: Text(
              
              'Дорухона — Касса/Анбор · v1.0.0',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const StatusChip(label: 'Desktop', tone: StatusTone.sync),
        ],
      ),
    );
  }
}
