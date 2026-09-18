/// Module: core / custom
///
///*************************** FILE INFO ****************************///
/// File Name: 100-custom_data_table.dart
/// Purpose: Declares `AppTableColumn`, `AppDataTable` and `AppTableCellText` —
///          the app's one table.
/// Author: Manger Plus team
/// Created: 3/9/2026
///
/// WHY NOT `DataTable`
/// -------------------
/// Material's `DataTable` draws a divider under every row and a border around
/// the header, sizes columns to their content (so a long note makes the whole
/// table wider than the window), and has no sticky header. All three fight the
/// house style. This is a `Column` of `Row`s: flex-weighted columns, a header
/// that stays put while the body scrolls, and separation by ALTERNATING ROW
/// FILL rather than by lines.
///
/// THE RULES IT ENCODES
/// --------------------
///   * No borders and no dividers anywhere. Rows read as rows because they
///     alternate `AppColors.oddRowColor` / `AppColors.evenRowColor`.
///   * The header is `AppColors.background` — the page colour, so it reads as
///     part of the frame rather than as a first data row.
///   * Selection is `AppColors.primary` at 18% — visible on both zebra shades
///     and in both themes, without turning the row into a yellow block that
///     swallows its own text.
///   * The whole thing is clipped to radius 8, matching every card.
///
/// COLUMN WIDTHS
/// -------------
/// Columns are FLEX weights, not pixels: the table always fills its box and
/// never scrolls sideways. Give a column `fixedWidth` only when its content has
/// a genuine ceiling — a status chip, a row of action buttons.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:manger_plus/core/constants/app_assets.dart';
import 'package:manger_plus/core/custom/32-custom_svg.dart';
import 'package:manger_plus/core/custom/89-custom_empty_state.dart';
import 'package:manger_plus/core/helper/main_helper/localized_number.dart';
import 'package:manger_plus/core/theme/app_colors.dart';
import 'package:manger_plus/core/theme/app_theme.dart';

/// One column of [AppDataTable].
class AppTableColumn<T> {
  const AppTableColumn({
    required this.label,
    required this.cell,
    this.flex = 1,
    this.fixedWidth,
    this.alignment = Alignment.centerLeft,
    this.sortKey,
  });

  /// Header text. Rendered uppercase-free and in 12/w600 — a label, not a
  /// shouted one.
  final String label;

  /// Builds this column's cell for [row]. Return an [AppTableCellText] for
  /// plain values; anything else (a chip, a button row) is passed through.
  final Widget Function(BuildContext context, T row) cell;

  /// Share of the leftover width. Ignored when [fixedWidth] is set.
  final int flex;

  /// Pins the column to an exact width. Use for chips and action clusters.
  final double? fixedWidth;

  final Alignment alignment;

  /// Non-null makes the header tappable; the value is handed back to
  /// [AppDataTable.onSort]. Null columns are not sortable and show no affordance.
  final String? sortKey;
}

/// The standard cell: one line, ellipsised, in the app's body style.
class AppTableCellText extends StatelessWidget {
  const AppTableCellText(
    this.value, {
    super.key,
    this.style,
    this.color,
    this.emphasis = false,
    this.textAlign,
  });

  final String value;
  final TextStyle? style;
  final Color? color;

  /// The one column that identifies the row — an order number, a customer
  /// name. Renders w600 so the eye has an anchor per row.
  final bool emphasis;

  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    final TextStyle base = style ??
        (emphasis
            ? StyleText.fontSize13Weight600
            : StyleText.fontSize13Weight400);

    return Text(
      value,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: textAlign,
      style: base.copyWith(
        color: color ?? (emphasis ? AppColors.text : AppColors.secondaryText),
      ),
    );
  }
}

/// A borderless, zebra-striped, flex-column table with a sticky header.
class AppDataTable<T> extends StatelessWidget {
  const AppDataTable({
    super.key,
    required this.columns,
    required this.rows,
    this.onRowTap,
    this.isRowSelected,
    this.rowHeight,
    this.headerHeight,
    this.horizontalPadding,
    this.emptyState,
    this.shrinkWrap = false,
    this.scrollController,
    this.sortKey,
    this.sortAscending = true,
    this.onSort,
    this.showRowNumbers = false,
    this.rowNumberLabel = '#',
  });

  final List<AppTableColumn<T>> columns;
  final List<T> rows;

  final ValueChanged<T>? onRowTap;

  /// Marks the row that is open in a side panel. Kept a predicate rather than
  /// an index so the caller can key on the record's id — a list that reorders
  /// underneath a selection then keeps the right row lit.
  final bool Function(T row)? isRowSelected;

  final double? rowHeight;
  final double? headerHeight;
  final double? horizontalPadding;

  /// Shown instead of the body when [rows] is empty. Defaults to the app's
  /// wordless [CustomEmptyState]. Pass your own only for a FAILED read, which
  /// is a different fact from an empty one.
  final Widget? emptyState;

  /// True inside an already-scrolling page. False (the default) makes the body
  /// scroll on its own under a header that stays put.
  final bool shrinkWrap;

  final ScrollController? scrollController;

  /// The column currently sorted, by its `sortKey`.
  final String? sortKey;
  final bool sortAscending;
  final void Function(String key)? onSort;

  /// Prepends knowticed's role-management "No" column — a 1-based counter in
  /// the reader's own digits.
  ///
  /// It numbers the ROWS AS DISPLAYED, not the records: re-sort the table and
  /// row 1 is whatever is now on top. That is the point of it — it is a place
  /// marker for "the third one down", which is how people talk about a row
  /// they are looking at, not an id.
  final bool showRowNumbers;
  final String rowNumberLabel;

  @override
  Widget build(BuildContext context) {
    final double padding = horizontalPadding ?? 16.sp;
    final double? numberWidth = showRowNumbers ? 56.sp : null;

    final Widget body = rows.isEmpty
        ? (emptyState ?? const CustomEmptyState())
        : ListView.builder(
            controller: scrollController,
            shrinkWrap: shrinkWrap,
            physics: shrinkWrap
                ? const NeverScrollableScrollPhysics()
                : const ClampingScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: rows.length,
            itemBuilder: (BuildContext context, int index) {
              final T row = rows[index];
              return _Row<T>(
                row: row,
                columns: columns,
                index: index,
                rowNumberWidth: numberWidth,
                height: rowHeight ?? 52.sp,
                horizontalPadding: padding,
                selected: isRowSelected?.call(row) ?? false,
                onTap: onRowTap == null ? null : () => onRowTap!(row),
              );
            },
          );

    return ClipRRect(
      borderRadius: BorderRadius.circular(8.sp),
      child: Column(
        mainAxisSize: shrinkWrap ? MainAxisSize.min : MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _Header<T>(
            columns: columns,
            rowNumberWidth: numberWidth,
            rowNumberLabel: rowNumberLabel,
            height: headerHeight ?? 44.sp,
            horizontalPadding: padding,
            sortKey: sortKey,
            sortAscending: sortAscending,
            onSort: onSort,
          ),
          if (shrinkWrap) body else Expanded(child: body),
        ],
      ),
    );
  }
}

class _Header<T> extends StatelessWidget {
  const _Header({
    required this.columns,
    required this.rowNumberWidth,
    required this.rowNumberLabel,
    required this.height,
    required this.horizontalPadding,
    required this.sortKey,
    required this.sortAscending,
    required this.onSort,
  });

  final List<AppTableColumn<T>> columns;
  final double? rowNumberWidth;
  final String rowNumberLabel;
  final double height;
  final double horizontalPadding;
  final String? sortKey;
  final bool sortAscending;
  final void Function(String key)? onSort;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      // ROLE-MANAGEMENT STYLE 18/9/2026. The header used to be
      // `AppColors.background` — the page colour, so it read as part of the
      // frame. knowticed's role-management table fills it instead, and that
      // is the look this app standardised on: a solid `blackShadow` bar with
      // white labels, so the header is unmistakably a header in both themes
      // and on both zebra shades.
      color: AppColors.blackShadow,
      child: Row(
        children: <Widget>[
          if (rowNumberWidth != null)
            SizedBox(
              width: rowNumberWidth,
              child: Text(
                rowNumberLabel,
                style: StyleText.fontSize14Weight500
                    .copyWith(color: AppColors.white),
              ),
            ),
          for (final AppTableColumn<T> column in columns)
            _Cell(
              column: column,
              child: _HeaderLabel(
                column: column,
                isSorted: column.sortKey != null && column.sortKey == sortKey,
                ascending: sortAscending,
                onTap: (column.sortKey == null || onSort == null)
                    ? null
                    : () => onSort!(column.sortKey!),
              ),
            ),
        ],
      ),
    );
  }
}

class _HeaderLabel<T> extends StatelessWidget {
  const _HeaderLabel({
    required this.column,
    required this.isSorted,
    required this.ascending,
    required this.onTap,
  });

  final AppTableColumn<T> column;
  final bool isSorted;
  final bool ascending;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Widget label = Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Flexible(
          child: Text(
            column.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: StyleText.fontSize14Weight500.copyWith(
              color: AppColors.white,
              fontWeight: isSorted ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
        // The caret appears only on the sorted column. A permanent pair of
        // arrows on every sortable header is six pieces of chrome saying
        // nothing about the current state.
        //
        // One asset, flipped: `chevronDown` turned half a turn is the ascending
        // caret, so there is no second file to keep in visual step with it.
        if (isSorted) ...<Widget>[
          SizedBox(width: 4.sp),
          RotatedBox(
            quarterTurns: ascending ? 2 : 0,
            child: CustomSvgImage(
              assetPath: AppAssets.chevronDown,
              width: 12.sp,
              height: 12.sp,
              color: AppColors.white,
            ),
          ),
        ],
      ],
    );

    if (onTap == null) return label;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(onTap: onTap, child: label),
    );
  }
}

class _Row<T> extends StatefulWidget {
  const _Row({
    required this.row,
    required this.columns,
    required this.index,
    required this.rowNumberWidth,
    required this.height,
    required this.horizontalPadding,
    required this.selected,
    required this.onTap,
  });

  final T row;
  final List<AppTableColumn<T>> columns;
  final int index;
  final double? rowNumberWidth;
  final double height;
  final double horizontalPadding;
  final bool selected;
  final VoidCallback? onTap;

  @override
  State<_Row<T>> createState() => _RowState<T>();
}

class _RowState<T> extends State<_Row<T>> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final Color zebra = widget.index.isEven
        ? AppColors.evenRowColor
        : AppColors.oddRowColor;

    final Color background = widget.selected
        ? AppColors.primary.withOpacity(0.18)
        : _hovered
            ? AppColors.primary.withOpacity(0.08)
            : zebra;

    final Widget row = Container(
      height: widget.height,
      padding: EdgeInsets.symmetric(horizontal: widget.horizontalPadding),
      color: background,
      child: Row(
        children: <Widget>[
          if (widget.rowNumberWidth != null)
            SizedBox(
              width: widget.rowNumberWidth,
              child: Text(
                LocalizedNumber.of(context, widget.index + 1),
                style: StyleText.fontSize12Weight600
                    .copyWith(color: AppColors.secondaryText),
              ),
            ),
          for (final AppTableColumn<T> column in widget.columns)
            _Cell(
              column: column,
              child: column.cell(context, widget.row),
            ),
        ],
      ),
    );

    if (widget.onTap == null) return row;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: row,
      ),
    );
  }
}

/// Lays one cell out under its column's width rule. Shared by the header and
/// the body so a header can never drift out of line with its column.
class _Cell<T> extends StatelessWidget {
  const _Cell({required this.column, required this.child});

  final AppTableColumn<T> column;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final Widget padded = Padding(
      padding: EdgeInsets.only(right: 12.sp),
      child: Align(alignment: column.alignment, child: child),
    );

    if (column.fixedWidth != null) {
      return SizedBox(width: column.fixedWidth, child: padded);
    }
    return Expanded(flex: column.flex, child: padded);
  }
}
