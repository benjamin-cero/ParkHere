import 'package:flutter/material.dart';

class BaseTable extends StatelessWidget {
  final double width;
  final double height;
  final List<DataColumn> columns;
  final List<DataRow> rows;
  final Widget? emptyState;
  final IconData? emptyIcon;
  final String? emptyText;
  final String? emptySubtext;
  final bool showCheckboxColumn;
  final double columnSpacing;
  final Color? headingRowColor;
  final Color? hoverRowColor;
  final EdgeInsetsGeometry? padding;
  final String? title;
  final IconData? icon;
  final List<double>? columnWidths;

  const BaseTable({
    super.key,
    required this.width,
    required this.height,
    required this.columns,
    required this.rows,
    this.emptyState,
    this.emptyIcon,
    this.emptyText,
    this.emptySubtext,
    this.showCheckboxColumn = false,
    this.columnSpacing = 24,
    this.headingRowColor,
    this.hoverRowColor,
    this.padding,
    this.title,
    this.icon,
    this.columnWidths,
  });

  @override
  Widget build(BuildContext context) {
    final bool isEmpty = rows.isEmpty;
    return Container(
      width: width,
      constraints: BoxConstraints(minHeight: height * 0.8, maxHeight: height),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: isEmpty
          ? (emptyState ?? _defaultEmptyState())
          : Column(
              children: [
                // Modern header
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.05),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      if (icon != null)
                        Icon(
                          icon!,
                          color: Theme.of(context).colorScheme.primary,
                          size: 20,
                        ),
                      const SizedBox(width: 12),
                      Text(
                        title ?? 'Data Table',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${rows.length} items',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Table content
                Expanded(
                  child: Container(
                    padding: padding ?? EdgeInsets.zero,
                    child: SingleChildScrollView(
                      child: _buildModernDataTable(context),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildModernDataTable(BuildContext context) {
    if (rows.isEmpty) {
      return Container(
        height: 100,
        alignment: Alignment.center,
        child: Text('No data available'),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate table width based on column widths or use constraints
        double tableWidth;
        if (columnWidths != null && columnWidths!.isNotEmpty) {
          // Sum of all column widths plus spacing between columns
          tableWidth = columnWidths!.fold(0.0, (sum, width) => sum + width) +
              (columnWidths!.length - 1) * columnSpacing;
        } else {
          tableWidth = constraints.maxWidth;
        }

        return Container(
          margin: const EdgeInsets.all(16),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withOpacity(0.1), width: 1),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: tableWidth,
              child: DataTable(
                showCheckboxColumn: showCheckboxColumn,
                columnSpacing: columnSpacing,
                headingRowColor: WidgetStateProperty.all(
                  headingRowColor ?? Colors.grey[50],
                ),
                dataRowColor: WidgetStateProperty.resolveWith<Color?>((states) {
                  if (states.contains(WidgetState.hovered)) {
                    return hoverRowColor ??
                        Theme.of(context).colorScheme.primary.withOpacity(0.05);
                  }
                  return null;
                }),
                columns: _buildModernColumns(context, tableWidth),
                rows: _buildModernRows(context, tableWidth),
                dataTextStyle: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[800],
                  fontWeight: FontWeight.w500,
                ),
                headingTextStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                  letterSpacing: 0.5,
                ),
                dividerThickness: 1,
                border: TableBorder(
                  horizontalInside: BorderSide(
                    color: Colors.grey.withOpacity(0.1),
                    width: 1,
                  ),
                  verticalInside: BorderSide(
                    color: Colors.grey.withOpacity(0.1),
                    width: 1,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  List<DataColumn> _buildModernColumns(
    BuildContext context,
    double tableWidth,
  ) {
    // Use custom column widths if provided, otherwise distribute evenly
    List<double> widths;
    if (columnWidths != null && columnWidths!.length == columns.length) {
      widths = columnWidths!;
    } else {
      double columnWidth = tableWidth / columns.length;
      widths = List.filled(columns.length, columnWidth);
    }

    return columns.asMap().entries.map((entry) {
      int index = entry.key;
      DataColumn column = entry.value;
      return DataColumn(
        label: Container(
          width: widths[index],
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          child: column.label,
        ),
      );
    }).toList();
  }

  List<DataRow> _buildModernRows(BuildContext context, double tableWidth) {
    // Use custom column widths if provided, otherwise distribute evenly
    List<double> widths;
    if (columnWidths != null && columnWidths!.length == columns.length) {
      widths = columnWidths!;
    } else {
      double columnWidth = tableWidth / columns.length;
      widths = List.filled(columns.length, columnWidth);
    }

    return rows.map((row) {
      return DataRow(
        onSelectChanged: row.onSelectChanged,
        cells: row.cells.asMap().entries.map((entry) {
          int index = entry.key;
          DataCell cell = entry.value;
          return DataCell(
            Container(
              width: widths[index],
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              child: cell.child,
            ),
          );
        }).toList(),
      );
    }).toList();
  }

  Widget _defaultEmptyState() {
    if (emptyIcon == null && emptyText == null && emptySubtext == null) {
      return Center(child: Text('No data'));
    }
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (emptyIcon != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Icon(emptyIcon, size: 48, color: Colors.grey[400]),
              ),
            if (emptyText != null) ...[
              const SizedBox(height: 24),
              Text(
                emptyText!,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (emptySubtext != null) ...[
              const SizedBox(height: 8),
              Text(
                emptySubtext!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
