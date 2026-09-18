/// Module: console / c1_shell
///
///*************************** FILE INFO ****************************///
/// File Name: choice_widgets.dart
/// Purpose: Declares `ChoiceWrap`, `PeoplePicker`, `SwitchRow` and
///          `StatusPill` — selection furniture for console dialogs.
/// Author: Manger Plus team
/// Created: 18/9/2026

import 'package:flutter/material.dart';

import 'package:manger_plus/core/custom/35-custom_search_widget_custom.dart';
import 'package:manger_plus/core/custom/110-app_widgets.dart';
import 'package:manger_plus/core/theme/app_colors.dart';
import 'package:manger_plus/core/theme/app_theme.dart';
import 'package:manger_plus/features/onboarding/o2_authentication/domain/entities/app_user.dart';
import 'package:manger_plus/generated/l10n.dart';

/// Pills you can toggle. [multi] false behaves like radio buttons.
class ChoiceWrap<T> extends StatelessWidget {
  const ChoiceWrap({
    super.key,
    required this.items,
    required this.selected,
    required this.labelOf,
    required this.onChanged,
    this.multi = true,
    this.emptyText,
  });

  final List<T> items;
  final Set<T> selected;
  final String Function(T item) labelOf;
  final ValueChanged<Set<T>> onChanged;
  final bool multi;
  final String? emptyText;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Text(
        emptyText ?? '—',
        style: StyleText.fontSize13Weight400.copyWith(color: AppColors.secondaryText),
      );
    }
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: <Widget>[
        for (final T item in items)
          FilterChip(
            label: Text(labelOf(item)),
            selected: selected.contains(item),
            showCheckmark: multi,
            labelStyle: StyleText.fontSize13Weight500.copyWith(
              color: selected.contains(item) ? AppColors.primary : AppColors.text,
            ),
            selectedColor: AppColors.primary.withOpacity(0.12),
            backgroundColor: AppColors.background,
            checkmarkColor: AppColors.primary,
            side: BorderSide(
              color: selected.contains(item)
                  ? AppColors.primary
                  : AppColors.borderGrey.withOpacity(0.5),
            ),
            onSelected: (bool on) {
              final Set<T> next = multi ? <T>{...selected} : <T>{};
              if (on) {
                next.add(item);
              } else {
                next.remove(item);
              }
              onChanged(next);
            },
          ),
      ],
    );
  }
}

/// A searchable checklist of people — a parent's children, single students
/// to assign content to.
class PeoplePicker extends StatefulWidget {
  const PeoplePicker({
    super.key,
    required this.people,
    required this.selected,
    required this.onChanged,
    this.subtitleOf,
    this.maxHeight = 240,
  });

  final List<AppUser> people;
  final Set<String> selected;
  final ValueChanged<Set<String>> onChanged;
  final String Function(AppUser user)? subtitleOf;
  final double maxHeight;

  @override
  State<PeoplePicker> createState() => _PeoplePickerState();
}

class _PeoplePickerState extends State<PeoplePicker> {
  final TextEditingController _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String q = _query.trim().toLowerCase();
    final List<AppUser> visible = widget.people
        .where((AppUser u) =>
            q.isEmpty ||
            u.displayName.toLowerCase().contains(q) ||
            u.email.toLowerCase().contains(q))
        .toList();

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderGrey.withOpacity(0.5)),
      ),
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8),
            child: AppSearchTextField(
              controller: _search,
              expanded: false,
              onChanged: (String v) => setState(() => _query = v),
            ),
          ),
          const Divider(height: 1),
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: widget.maxHeight),
            child: visible.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      S.of(context).nobodyFound,
                      style: StyleText.fontSize13Weight400
                          .copyWith(color: AppColors.secondaryText),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: visible.length,
                    itemBuilder: (BuildContext context, int i) {
                      final AppUser u = visible[i];
                      final bool on = widget.selected.contains(u.uid);
                      return CheckboxListTile(
                        dense: true,
                        value: on,
                        activeColor: AppColors.primary,
                        controlAffinity: ListTileControlAffinity.leading,
                        title: Text(u.displayName, style: StyleText.fontSize13Weight600),
                        subtitle: Text(
                          widget.subtitleOf?.call(u) ?? u.email,
                          style: StyleText.fontSize12Weight400
                              .copyWith(color: AppColors.secondaryText),
                        ),
                        secondary: AppAvatar(name: u.displayName, size: 32),
                        onChanged: (bool? v) {
                          final Set<String> next = <String>{...widget.selected};
                          if (v == true) {
                            next.add(u.uid);
                          } else {
                            next.remove(u.uid);
                          }
                          widget.onChanged(next);
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

/// Icon, title, description, switch — one teacher permission.
class SwitchRow extends StatelessWidget {
  const SwitchRow({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: <Widget>[
          TypeBadge(icon: icon, color: value ? AppColors.primary : AppColors.greyIcon, size: 36),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title, style: StyleText.fontSize14Weight600),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: StyleText.fontSize12Weight400
                        .copyWith(color: AppColors.secondaryText),
                  ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            activeTrackColor: AppColors.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

/// "Active" / "Off" / any short state, as a coloured pill.
class StatusPill extends StatelessWidget {
  const StatusPill({super.key, required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: StyleText.fontSize12Weight600.copyWith(color: color)),
    );
  }
}
