/// Module: console / c1_shell
///
///*************************** FILE INFO ****************************///
/// File Name: console_page.dart
/// Purpose: Declares `ConsolePage`, `ConsoleToolbar`, `FilterChipRow` and
///          `ConsoleDialog` — the frame and furniture every console page uses.
/// Author: Manger Plus team
/// Created: 18/9/2026

import 'package:flutter/material.dart';

import 'package:manger_plus/core/custom/35-custom_search_widget_custom.dart';
import 'package:manger_plus/core/custom/8-custom_filter_app.dart';
import 'package:manger_plus/core/theme/app_colors.dart';
import 'package:manger_plus/core/theme/app_theme.dart';
import 'package:manger_plus/generated/l10n.dart';
import 'package:manger_plus/core/custom/111-app_svg_icon.dart';

/// The height every control in a page header is drawn at.
///
/// ADDED 18/9/2026. The search box is 38 (it is `AppSearchTextField`, and 38
/// is the toolbar height the whole app uses) while `AppButton` defaults to 50,
/// so "Search" and "Add content" sat side by side at two different heights
/// with their centres out of line. Header actions are held to this now, and a
/// button placed there passes `dense: true` so it ASKS for 38 rather than
/// being squeezed into it.
const double kConsoleControlHeight = 38;

/// Title + subtitle + actions on top, the page below.
///
/// The console runs at ScreenUtil scale 1 (see main.dart), so this file uses
/// raw logical pixels — they ARE the design values on desktop.
class ConsolePage extends StatelessWidget {
  const ConsolePage({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.actions = const <Widget>[],
    this.scrollable = false,
  });

  final String title;
  final String? subtitle;
  final List<Widget> actions;
  final Widget child;

  /// True wraps [child] in a scroll view. Leave false for pages whose body
  /// is a table or list that scrolls itself.
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final Widget body = Padding(
      padding: const EdgeInsets.fromLTRB(32, 0, 32, 28),
      child: child,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(32, 28, 32, 20),
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints c) {
          // Tablet portrait: the actions no longer fit beside the title, so
          // they wrap onto their own line underneath it.
          final bool stacked = actions.isNotEmpty && c.maxWidth < 760;
          final Widget titleBlock = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(title, style: StyleText.fontSize26Weight600),
              if (subtitle != null) ...<Widget>[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: StyleText.fontSize14Weight400
                      .copyWith(color: AppColors.secondaryText),
                ),
              ],
            ],
          );
          if (stacked) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                titleBlock,
                const SizedBox(height: 14),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: <Widget>[
                    for (final Widget a in actions)
                      ConstrainedBox(
                        constraints: const BoxConstraints(
                            maxHeight: kConsoleControlHeight, maxWidth: 420),
                        child: a,
                      ),
                  ],
                ),
              ],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(title, style: StyleText.fontSize26Weight600),
                    if (subtitle != null) ...<Widget>[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: StyleText.fontSize14Weight400
                            .copyWith(color: AppColors.secondaryText),
                      ),
                    ],
                  ],
                ),
              ),
              for (int i = 0; i < actions.length; i++) ...<Widget>[
                if (i > 0) const SizedBox(width: 10),
                // maxHeight, not a tight SizedBox: a control that wants more
                // is brought into line instead of overflowing with stripes.
                ConstrainedBox(
                  constraints:
                      const BoxConstraints(maxHeight: kConsoleControlHeight),
                  child: actions[i],
                ),
              ],
            ],
          );
            },
          ),
        ),
        Expanded(
          child: scrollable ? SingleChildScrollView(child: body) : body,
        ),
      ],
    );
  }
}

/// A search box for a console toolbar.
/// A search box for a console toolbar.
///
/// REBUILT 18/9/2026 on `35-custom_search_widget_custom`. This used to be its
/// own `TextField` with its own height (42), its own radius (12) and a VISIBLE
/// BORDER — three things no other control in the console has. There is one
/// search box in this app now, and this is a thin wrapper that owns the
/// controller so callers can keep passing a plain `onChanged`.
class ConsoleSearchField extends StatefulWidget {
  const ConsoleSearchField({
    super.key,
    required this.onChanged,
    this.hint,
    this.width = 280,
  });

  final ValueChanged<String> onChanged;
  final String? hint;
  final double width;

  @override
  State<ConsoleSearchField> createState() => _ConsoleSearchFieldState();
}

class _ConsoleSearchFieldState extends State<ConsoleSearchField> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _set(String value) {
    // The rebuild is for the clear button appearing and disappearing; the
    // caller's own setState does the filtering.
    setState(() {});
    widget.onChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    return AppSearchTextField(
      controller: _controller,
      expanded: false,
      width: widget.width,
      hintText: widget.hint,
      onChanged: _set,
      // A bare IconButton is 48 square and would burst a 38-tall field.
      suffixIcon: _controller.text.isEmpty
          ? null
          : IconButton(
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
              iconSize: 16,
              icon: const AppIcon(Icons.close_rounded),
              onPressed: () {
                _controller.clear();
                _set('');
              },
            ),
    );
  }
}

/// A horizontal row of selectable filter chips — type filters, section
/// filters.
///
/// REBUILT 18/9/2026 on `8-custom_filter_app`. It used to draw its own
/// rounded pills, each tinted with the filtered thing's own colour: five
/// content types meant five hues in one row, and the eye read the RAINBOW
/// before it read any of the labels. `StatusChipFilter` is the app's one
/// filter row and carries a single accent, so that is what this delegates to
/// now; [FilterChipRow] survives only as the `T`-typed adapter, because the
/// pages filter by enum and by section id, not by string key.
///
/// Chips get a count box when [countOf] is given and read as plain pills when
/// it is not — see [StatusChipItem.count].
class FilterChipRow<T> extends StatelessWidget {
  const FilterChipRow({
    super.key,
    required this.items,
    required this.selected,
    required this.labelOf,
    required this.onSelected,
    this.countOf,
    this.allLabel,
    this.allCount,
  });

  final List<T> items;

  /// Null = "All".
  final T? selected;
  final String Function(T item) labelOf;
  final ValueChanged<T?> onSelected;

  /// Supplies each chip's count. Leave null for a row with nothing to count.
  final int? Function(T item)? countOf;

  /// Adds a leading "All" chip when set.
  final String? allLabel;

  /// The "All" chip's count. Defaults to the sum of [countOf] across [items],
  /// which is right when every record belongs to exactly one chip — pass it
  /// explicitly when they can belong to several, or the total would be
  /// larger than the number of records.
  final int? allCount;

  /// Positional, not the label: labels are localized and two of them can
  /// collide, whereas the index is stable for as long as the row exists.
  static String _keyFor(int index) => 'i$index';

  @override
  Widget build(BuildContext context) {
    final int selectedIndex = selected == null ? -1 : items.indexOf(selected as T);

    int? resolvedAllCount() {
      if (allCount != null) return allCount;
      if (countOf == null) return null;
      return items.fold<int>(0, (int a, T b) => a + (countOf!(b) ?? 0));
    }

    return StatusChipFilter(
      // Pills, not count boxes: 38 tall and 10 apart, so a filter row lines up
      // with the 38-tall toolbar controls above it instead of towering over
      // them on knowticed's 45 + 30 count-chip spacing.
      chipSize: 38,
      chipSpacing: 10,
      selectedKey: selectedIndex < 0
          ? (allLabel != null ? kAllChipKey : '')
          : _keyFor(selectedIndex),
      onSelected: (String key) {
        if (key == kAllChipKey) {
          onSelected(null);
          return;
        }
        for (int i = 0; i < items.length; i++) {
          if (_keyFor(i) == key) {
            onSelected(items[i]);
            return;
          }
        }
      },
      items: <StatusChipItem>[
        if (allLabel != null)
          StatusChipItem(
            key: kAllChipKey,
            label: allLabel!,
            count: resolvedAllCount(),
          ),
        for (int i = 0; i < items.length; i++)
          StatusChipItem(
            key: _keyFor(i),
            label: labelOf(items[i]),
            count: countOf?.call(items[i]),
          ),
      ],
    );
  }
}

class ConsoleDialog extends StatelessWidget {
  const ConsoleDialog({
    super.key,
    required this.title,
    required this.child,
    required this.actions,
    this.width = 560,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final Widget child;
  final List<Widget> actions;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.card,
      insetPadding: const EdgeInsets.all(24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: width,
          maxHeight: MediaQuery.of(context).size.height * 0.88,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 22, 12, 8),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(title, style: StyleText.fontSize20Weight600),
                        if (subtitle != null)
                          Text(
                            subtitle!,
                            style: StyleText.fontSize13Weight400
                                .copyWith(color: AppColors.secondaryText),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: AppIcon(Icons.close_rounded, color: AppColors.secondaryText),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
                child: child,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  for (int i = 0; i < actions.length; i++) ...<Widget>[
                    if (i > 0) const SizedBox(width: 10),
                    actions[i],
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A small caption above a form group inside a dialog.
class FormLabel extends StatelessWidget {
  const FormLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 8),
      child: Text(
        text,
        style: StyleText.fontSize13Weight600.copyWith(color: AppColors.secondaryText),
      ),
    );
  }
}

/// Shows a snackbar in the console style.
void showToast(BuildContext context, String message, {bool error = false}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      width: MediaQuery.of(context).size.width > 600 ? 420 : null,
      backgroundColor: error ? AppColors.red : AppColors.text,
      content: Text(message, style: StyleText.fontSize14Weight500.copyWith(color: AppColors.background)),
    ),
  );
}
