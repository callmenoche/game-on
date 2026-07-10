import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/group.dart';
import '../providers/group_provider.dart';
import '../widgets/game_on_logo.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  GroupVisibility _visibility = GroupVisibility.private;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    final desc = _descCtrl.text.trim();
    final group = await context.read<GroupProvider>().createGroup(
          _nameCtrl.text.trim(),
          desc.isEmpty ? null : desc,
          visibility: _visibility,
        );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (group != null) {
      context.pop();
      context.push('/groups/${group.id}');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.couldNotCreateGroup),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l.newGroup,
            style: const TextStyle(fontWeight: FontWeight.w800)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: GameOnBrand.saffron.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: GameOnBrand.saffron.withValues(alpha: 0.2)),
              ),
              child: Column(
                children: [
                  const Icon(Icons.group_add_rounded,
                      size: 40, color: GameOnBrand.saffron),
                  const SizedBox(height: 10),
                  Text(
                    l.createPrivateGroup,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l.createGroupBody,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color:
                          theme.colorScheme.onSurface.withValues(alpha: 0.55),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            _label(l.groupName),
            const SizedBox(height: 10),
            TextFormField(
              controller: _nameCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                hintText: l.exampleGroupName,
                prefixIcon: const Icon(Icons.group_rounded, size: 20),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? l.groupName : null,
            ),
            const SizedBox(height: 20),
            _label(l.descriptionOptional),
            const SizedBox(height: 10),
            TextFormField(
              controller: _descCtrl,
              maxLines: 3,
              maxLength: 200,
              decoration: InputDecoration(
                hintText: l.groupAboutHint,
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(bottom: 40),
                  child: Icon(Icons.description_rounded, size: 20),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _label(l.groupVisibility),
            const SizedBox(height: 10),
            _VisibilityPicker(
              selected: _visibility,
              onChanged: (v) => setState(() => _visibility = v),
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: _isSubmitting ? null : _submit,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(54),
                backgroundColor: GameOnBrand.saffron,
                foregroundColor: GameOnBrand.slateDark,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.5, color: GameOnBrand.slateDark),
                    )
                  : Text(l.createGroup,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w800)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.45),
        ),
      );
}

// ─── Visibility picker ───────────────────────────────────────────────────

class _VisibilityPicker extends StatelessWidget {
  final GroupVisibility selected;
  final ValueChanged<GroupVisibility> onChanged;

  const _VisibilityPicker({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final options = [
      (GroupVisibility.public, Icons.public_rounded, l.visibilityPublic,
          l.visibilityPublicDesc),
      (GroupVisibility.private, Icons.lock_rounded, l.visibilityPrivate,
          l.visibilityPrivateDesc),
      (
        GroupVisibility.inviteOnly,
        Icons.how_to_reg_rounded,
        l.visibilityInviteOnly,
        l.visibilityInviteOnlyDesc
      ),
    ];

    return Column(
      children: options.map((o) {
        final (value, icon, title, desc) = o;
        final isSelected = value == selected;
        final theme = Theme.of(context);
        return GestureDetector(
          onTap: () => onChanged(value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isSelected
                  ? GameOnBrand.saffron.withValues(alpha: 0.10)
                  : GameOnBrand.slateCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected
                    ? GameOnBrand.saffron
                    : theme.colorScheme.onSurface.withValues(alpha: 0.12),
              ),
            ),
            child: Row(
              children: [
                Icon(icon,
                    size: 22,
                    color: isSelected
                        ? GameOnBrand.saffron
                        : theme.colorScheme.onSurface
                            .withValues(alpha: 0.5)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                            color: isSelected
                                ? GameOnBrand.saffron
                                : theme.colorScheme.onSurface,
                          )),
                      const SizedBox(height: 2),
                      Text(desc,
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.5),
                          )),
                    ],
                  ),
                ),
                if (isSelected)
                  const Icon(Icons.check_circle_rounded,
                      color: GameOnBrand.saffron, size: 20),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
