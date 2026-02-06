import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/accessibility/a11y.dart';
import '../../core/constants/enums.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';

class ManageUsersScreen extends ConsumerWidget {
  const ManageUsersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = context.tr;
    final usersAsync = ref.watch(allUsersProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(tr('manage_users')),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            tooltip: tr('add_user'),
            onPressed: () => _showAddUserDialog(context, ref),
          ),
        ],
      ),
      body: usersAsync.when(
        data: (users) {
          if (users.isEmpty) {
            return Center(child: Text(tr('no_users')));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: users.length,
            itemBuilder: (context, i) =>
                _UserTile(user: users[i]),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
      ),
    );
  }

  void _showAddUserDialog(BuildContext context, WidgetRef ref) {
    final tr = context.tr;
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final cinCtrl = TextEditingController();
    UserRole selectedRole = UserRole.adherent;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(tr('add_user')),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    labelText: tr('name'),
                    prefixIcon: const Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailCtrl,
                  decoration: InputDecoration(
                    labelText: tr('email'),
                    prefixIcon: const Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: cinCtrl,
                  decoration: InputDecoration(
                    labelText: '${tr('password')} (3 chiffres)',
                    prefixIcon: const Icon(Icons.lock),
                  ),
                  keyboardType: TextInputType.number,
                  maxLength: 3,
                  obscureText: true,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<UserRole>(
                  value: selectedRole,
                  decoration: InputDecoration(
                    labelText: tr('role'),
                    prefixIcon: const Icon(Icons.badge),
                  ),
                  items: UserRole.values
                      .where((r) => r != UserRole.visiteur)
                      .map((r) => DropdownMenuItem(
                            value: r,
                            child: Text(r.name),
                          ))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) {
                      setDialogState(() => selectedRole = v);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(tr('cancel')),
            ),
            FilledButton(
              onPressed: () async {
                if (nameCtrl.text.trim().isEmpty ||
                    cinCtrl.text.trim().length != 3) {
                  return;
                }
                try {
                  await ref.read(authServiceProvider).createUser(
                        displayName: nameCtrl.text.trim(),
                        password: cinCtrl.text.trim(),
                        role: selectedRole,
                        email: emailCtrl.text.trim().isNotEmpty
                            ? emailCtrl.text.trim()
                            : 'user_${DateTime.now().millisecondsSinceEpoch}@rct.app',
                        phone: '',
                      );
                  if (ctx.mounted) Navigator.pop(ctx);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(tr('user_created'))),
                    );
                  }
                } catch (e) {
                  if (ctx.mounted) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      SnackBar(
                        content: Text(e.toString()),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                }
              },
              child: Text(tr('create')),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserTile extends ConsumerWidget {
  final UserModel user;
  const _UserTile({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = context.tr;
    final roleColors = {
      UserRole.adminPrincipal: AppColors.error,
      UserRole.adminCoach: AppColors.secondary,
      UserRole.adminGroupe: Colors.teal,
      UserRole.adherent: AppColors.primary,
      UserRole.visiteur: Colors.grey,
    };
    final color = roleColors[user.role] ?? AppColors.primary;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.2),
          child: Text(
            user.displayName.isNotEmpty
                ? user.displayName[0].toUpperCase()
                : '?',
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(user.displayName,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                user.role.name,
                style: TextStyle(fontSize: 11, color: color),
              ),
            ),
            if (user.groupId != null) ...[
              const SizedBox(width: 8),
              Text(user.groupId!,
                  style: Theme.of(context).textTheme.bodySmall),
            ],
          ],
        ),
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                if (user.email.isNotEmpty)
                  _DetailRow(label: tr('email'), value: user.email),
                if (user.phone.isNotEmpty)
                  _DetailRow(label: tr('phone'), value: user.phone),
                _DetailRow(
                  label: tr('joined'),
                  value:
                      '${user.joinedAt.day}/${user.joinedAt.month}/${user.joinedAt.year}',
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Change role
                    A11y.touchTarget(
                      child: TextButton.icon(
                        icon: const Icon(Icons.badge, size: 16),
                        label: Text(tr('change_role')),
                        onPressed: () =>
                            _showRoleDialog(context, ref, user),
                      ),
                    ),
                    // Delete
                    A11y.touchTarget(
                      child: TextButton.icon(
                        style: TextButton.styleFrom(
                            foregroundColor: AppColors.error),
                        icon: const Icon(Icons.delete, size: 16),
                        label: Text(tr('delete')),
                        onPressed: () =>
                            _confirmDelete(context, ref, user),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showRoleDialog(
      BuildContext context, WidgetRef ref, UserModel user) {
    final tr = context.tr;
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text(tr('change_role')),
        children: UserRole.values
            .where((r) => r != UserRole.visiteur)
            .map((role) => SimpleDialogOption(
                  onPressed: () async {
                    Navigator.pop(ctx);
                    await ref
                        .read(authServiceProvider)
                        .updateUserRole(user.id, role);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(tr('role_updated'))),
                      );
                    }
                  },
                  child: Row(
                    children: [
                      if (user.role == role)
                        const Icon(Icons.check,
                            color: AppColors.primary, size: 18),
                      if (user.role == role) const SizedBox(width: 8),
                      Text(role.name),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, WidgetRef ref, UserModel user) {
    final tr = context.tr;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(tr('confirm_delete')),
        content: Text('${tr('delete_user_confirm')} ${user.displayName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(tr('cancel')),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(authServiceProvider).deleteUser(user.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(tr('user_deleted'))),
                );
              }
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: Text(tr('delete')),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text('$label: ',
              style: const TextStyle(fontWeight: FontWeight.w600)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
