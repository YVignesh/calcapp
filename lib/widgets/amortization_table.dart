import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../core/density.dart';
import '../core/tokens.dart';
import 'calc_scaffold.dart' show SectionLabel;

/// A single amortization schedule row.
class AmortRow {
  final int month;
  final double payment;
  final double principal;
  final double interest;
  final double balance;

  const AmortRow({
    required this.month,
    required this.payment,
    required this.principal,
    required this.interest,
    required this.balance,
  });
}

/// Shared amortization table widget used by loan_screen and mortgage_screen.
/// Supports "Show all / Show less" and CSV copy. In [Density.cozy] mode the
/// table is horizontally scrollable with a sticky first column.
class AmortizationTable extends StatefulWidget {
  final List<AmortRow> rows;
  final NumberFormat fmt;
  final String currencySymbol;

  const AmortizationTable({
    super.key,
    required this.rows,
    required this.fmt,
    this.currencySymbol = '\$',
  });

  @override
  State<AmortizationTable> createState() => _AmortizationTableState();
}

class _AmortizationTableState extends State<AmortizationTable> {
  bool _showFull = false;
  static const _previewCount = 24;

  @override
  Widget build(BuildContext context) {
    final tok = DensityScope.of(context);
    final displayed = _showFull
        ? widget.rows
        : widget.rows.take(_previewCount).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SectionLabel('AMORTIZATION SCHEDULE'),
            IconButton(
              icon: const Icon(Icons.copy_rounded, size: 16),
              tooltip: 'Copy as CSV',
              onPressed: _copySchedule,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
        SizedBox(height: tok.vGap * 0.5),
        tok.tableScrollX
            ? _horizontalScrollTable(context, displayed, tok)
            : _fixedTable(context, displayed, tok),
        if (widget.rows.length > _previewCount)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: TextButton(
              onPressed: () => setState(() => _showFull = !_showFull),
              child: Text(
                _showFull
                    ? 'Show less'
                    : 'Show all ${widget.rows.length} months',
                style: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.w600),
              ),
            ),
          ),
      ],
    );
  }

  Widget _fixedTable(
      BuildContext context, List<AmortRow> rows, DensityTokens tok) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final bg = isLight ? AppTokens.lBg2 : AppTokens.bg2;
    final borderColor = isLight ? AppTokens.lBorder : AppTokens.border;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppTokens.rCard),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          _header(context),
          const Divider(height: 1),
          ...List.generate(rows.length, (i) => _dataRow(context, rows[i], i)),
        ],
      ),
    );
  }

  Widget _horizontalScrollTable(
      BuildContext context, List<AmortRow> rows, DensityTokens tok) {
    // Sticky Mo. column + horizontal scroll for the rest.
    final isLight = Theme.of(context).brightness == Brightness.light;
    final bg = isLight ? AppTokens.lBg2 : AppTokens.bg2;
    final borderColor = isLight ? AppTokens.lBorder : AppTokens.border;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppTokens.rCard),
        border: Border.all(color: borderColor),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: IntrinsicWidth(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _header(context),
              const Divider(height: 1),
              ...List.generate(
                  rows.length, (i) => _dataRow(context, rows[i], i)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          _th(context, 'Mo.', flex: 1),
          _th(context, 'Payment', flex: 3),
          _th(context, 'Principal', flex: 3),
          _th(context, 'Interest', flex: 3),
          _th(context, 'Balance', flex: 3),
        ],
      ),
    );
  }

  Widget _dataRow(BuildContext context, AmortRow row, int index) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      color: index.isEven
          ? Colors.transparent
          : cs.primary.withValues(alpha: 0.04),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      child: Row(
        children: [
          _td(context, '${row.month}', flex: 1, bold: true),
          _td(context, '${widget.currencySymbol}${widget.fmt.format(row.payment)}',
              flex: 3),
          _td(context,
              '${widget.currencySymbol}${widget.fmt.format(row.principal)}',
              flex: 3,
              color: AppTokens.success),
          _td(context,
              '${widget.currencySymbol}${widget.fmt.format(row.interest)}',
              flex: 3,
              color: AppTokens.danger),
          _td(context,
              '${widget.currencySymbol}${widget.fmt.format(row.balance)}',
              flex: 3),
        ],
      ),
    );
  }

  Widget _th(BuildContext context, String text, {required int flex}) =>
      Expanded(
        flex: flex,
        child: Text(
          text,
          style: GoogleFonts.ibmPlexSans(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            letterSpacing: 0.3,
          ),
        ),
      );

  Widget _td(BuildContext context, String text,
      {required int flex, Color? color, bool bold = false}) =>
      Expanded(
        flex: flex,
        child: Text(
          text,
          style: GoogleFonts.ibmPlexMono(
            fontSize: 11,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
            color: color ?? Theme.of(context).colorScheme.onSurface,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      );

  void _copySchedule() {
    final buf = StringBuffer('Month,Payment,Principal,Interest,Balance\n');
    for (final r in widget.rows) {
      buf.writeln(
          '${r.month},${widget.fmt.format(r.payment)},${widget.fmt.format(r.principal)},${widget.fmt.format(r.interest)},${widget.fmt.format(r.balance)}');
    }
    Clipboard.setData(ClipboardData(text: buf.toString()));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Schedule copied as CSV',
            style: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.w500),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}
