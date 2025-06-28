import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/repair_transaction.dart';
import '../services/repair_service.dart';

class UnpaidPartsModalBottomSheet {
  /// Shows a modal bottom sheet with unpaid parts information and management
  static Future<void> show({
    required BuildContext context,
    required RepairTransaction repair,
    required VoidCallback onUpdateUI,
  }) async {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;
    final unpaidParts = repair.parts.where((part) => !part.isCostPaid).toList();
    final repairService = RepairService();

    // Detect screen size for responsive layout
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final isSmallScreen = screenWidth <= 800;
    final isMobile = screenWidth < 600;
    final isLandscape = mediaQuery.orientation == Orientation.landscape;

    // Adjust bottom sheet size based on screen dimensions and orientation
    final double initialSize =
        isLandscape ? (isMobile ? 0.85 : 0.75) : (isMobile ? 0.7 : 0.65);

    final double minSize =
        isLandscape ? (isMobile ? 0.4 : 0.35) : (isMobile ? 0.35 : 0.3);

    final double maxSize = isLandscape ? 0.95 : 0.9;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(isSmallScreen ? 16 : 20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: initialSize,
          minChildSize: minSize,
          maxChildSize: maxSize,
          expand: false,
          builder: (context, scrollController) {
            return StatefulBuilder(
              builder: (BuildContext context, StateSetter setBottomSheetState) {
                return Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.vertical(
                        top: Radius.circular(isSmallScreen ? 16 : 20)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: 1,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Handle and title
                        Padding(
                          padding: EdgeInsets.only(
                              top: isMobile ? 10 : 12,
                              bottom: isMobile ? 6 : 8),
                          child: Container(
                            width: isMobile ? 36 : 40,
                            height: isMobile ? 4 : 5,
                            decoration: BoxDecoration(
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.3),
                              borderRadius:
                                  BorderRadius.circular(isMobile ? 2 : 2.5),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: isMobile ? 16 : 20,
                              vertical: isMobile ? 8 : 10),
                          child: Row(
                            children: [
                              Icon(
                                Icons.warning_amber_rounded,
                                color: theme.colorScheme.error,
                                size: isMobile ? 22 : 24,
                              ),
                              SizedBox(width: isMobile ? 10 : 12),
                              Expanded(
                                child: Text(
                                  '${localizations.costPending} - ${repair.phoneModel}',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.error,
                                    fontSize: isMobile ? 16 : 18,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              TextButton.icon(
                                onPressed: () {
                                  // Mark all parts as paid
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text(
                                        localizations.confirmDelete,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: isMobile ? 18 : 20,
                                          color: theme.colorScheme.primary,
                                        ),
                                      ),
                                      content: Text(
                                        localizations.confirmMarkAllPaid,
                                        style: TextStyle(
                                          fontSize: isMobile ? 14 : 16,
                                        ),
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: Text(
                                            localizations.cancel,
                                            style: TextStyle(
                                              color: theme.colorScheme.primary,
                                              fontWeight: FontWeight.normal,
                                              fontSize: isMobile ? 13 : 14,
                                            ),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            Navigator.pop(
                                                context); // Close dialog

                                            // Show loading indicator
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Row(
                                                  children: [
                                                    SizedBox(
                                                      width: isMobile ? 18 : 20,
                                                      height:
                                                          isMobile ? 18 : 20,
                                                      child:
                                                          CircularProgressIndicator(
                                                        strokeWidth:
                                                            isMobile ? 1.5 : 2,
                                                        valueColor:
                                                            const AlwaysStoppedAnimation<
                                                                    Color>(
                                                                Colors.white),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                        width:
                                                            isMobile ? 12 : 16),
                                                    Text(
                                                      localizations.loading,
                                                      style: TextStyle(
                                                        fontSize:
                                                            isMobile ? 13 : 14,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                duration:
                                                    const Duration(seconds: 1),
                                              ),
                                            );

                                            // Mark all parts as paid
                                            try {
                                              for (final part in unpaidParts) {
                                                await repairService
                                                    .updatePartCostPaidStatus(
                                                        repair.id,
                                                        part.id,
                                                        true);
                                              }

                                              // Close bottom sheet after success
                                              Navigator.pop(context);

                                              // Update main UI
                                              onUpdateUI();

                                              // Show success message
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(localizations
                                                      .costHasBeenPaid),
                                                  backgroundColor: Colors.green,
                                                ),
                                              );
                                            } catch (e) {
                                              // Show error message
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(localizations
                                                      .errorWithMessage(
                                                          e.toString())),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                            }
                                          },
                                          child: Text(
                                            localizations.done,
                                            style: TextStyle(
                                              color: theme.colorScheme.primary,
                                              fontWeight: FontWeight.bold,
                                              fontSize: isMobile ? 13 : 14,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                icon: Icon(
                                  Icons.check_circle_outline,
                                  size: isMobile ? 16 : 18,
                                  color: Colors.green,
                                ),
                                label: Text(
                                  localizations.markAllAsPaid,
                                  style: TextStyle(
                                    fontSize: isMobile ? 12 : 13,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.green,
                                  ),
                                ),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.green,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: isMobile ? 8 : 12,
                                    vertical: isMobile ? 4 : 6,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  backgroundColor:
                                      Colors.green.withOpacity(0.1),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Client information if available
                        if (repair.clientName != null ||
                            repair.clientPhone != null)
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: isMobile ? 16 : 20,
                                vertical: isMobile ? 6 : 8),
                            child: Container(
                              padding: EdgeInsets.all(isMobile ? 10 : 12),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.secondaryContainer
                                    .withOpacity(0.3),
                                borderRadius:
                                    BorderRadius.circular(isMobile ? 10 : 12),
                                border: Border.all(
                                  color: theme.colorScheme.outline
                                      .withOpacity(0.2),
                                  width: 0.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.02),
                                    blurRadius: 3,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    localizations.clientInfo,
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.primary,
                                      fontSize: isMobile ? 13 : 14,
                                    ),
                                  ),
                                  SizedBox(height: isMobile ? 6 : 8),
                                  if (repair.clientName != null &&
                                      repair.clientName!.isNotEmpty)
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.person_outline,
                                          size: isMobile ? 14 : 16,
                                          color: theme
                                              .colorScheme.onSecondaryContainer,
                                        ),
                                        SizedBox(width: isMobile ? 6 : 8),
                                        Text(
                                          repair.clientName!,
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                            fontWeight: FontWeight.w500,
                                            fontSize: isMobile ? 13 : 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  if (repair.clientName != null &&
                                      repair.clientName!.isNotEmpty &&
                                      repair.clientPhone != null &&
                                      repair.clientPhone!.isNotEmpty)
                                    SizedBox(height: isMobile ? 4 : 6),
                                  if (repair.clientPhone != null &&
                                      repair.clientPhone!.isNotEmpty)
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.phone_outlined,
                                          size: isMobile ? 14 : 16,
                                          color: theme
                                              .colorScheme.onSecondaryContainer,
                                        ),
                                        SizedBox(width: isMobile ? 6 : 8),
                                        Text(
                                          repair.clientPhone!,
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                            fontSize: isMobile ? 13 : 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          ),

                        Divider(
                          height: 1,
                          thickness: 0.5,
                          color: theme.colorScheme.outline.withOpacity(0.2),
                        ),

                        // Unpaid parts list
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: unpaidParts.length,
                          padding: EdgeInsets.only(
                            bottom: isMobile ? 16 : 24,
                            top: isMobile ? 8 : 12,
                          ),
                          separatorBuilder: (context, index) => Divider(
                            height: 1,
                            thickness: 0.5,
                            color: theme.colorScheme.outline.withOpacity(0.1),
                          ),
                          itemBuilder: (context, index) {
                            final part = unpaidParts[index];
                            return ListTile(
                              title: Text(
                                part.name,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  fontSize: isMobile ? 14 : 16,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: isMobile ? 3 : 4),
                                  Text(
                                    '${localizations.costPrice}: ${localizations.currency} ${part.costPrice.toStringAsFixed(2)}',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontSize: isMobile ? 11 : 12,
                                      color: theme.colorScheme.onSurface
                                          .withOpacity(0.75),
                                    ),
                                  ),
                                  SizedBox(height: isMobile ? 2 : 3),
                                  Text(
                                    '${localizations.sellingPrice}: ${localizations.currency} ${part.sellingPrice.toStringAsFixed(2)}',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontSize: isMobile ? 11 : 12,
                                      color: theme.colorScheme.onSurface
                                          .withOpacity(0.75),
                                    ),
                                  ),
                                ],
                              ),
                              trailing: ElevatedButton.icon(
                                onPressed: () async {
                                  try {
                                    // Show loading indicator
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Row(
                                          children: [
                                            SizedBox(
                                              width: isMobile ? 18 : 20,
                                              height: isMobile ? 18 : 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: isMobile ? 1.5 : 2,
                                                valueColor:
                                                    const AlwaysStoppedAnimation<
                                                        Color>(Colors.white),
                                              ),
                                            ),
                                            SizedBox(width: isMobile ? 12 : 16),
                                            Text(
                                              localizations.loading,
                                              style: TextStyle(
                                                fontSize: isMobile ? 13 : 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                        duration: const Duration(seconds: 1),
                                      ),
                                    );

                                    // Mark part as paid
                                    await repairService
                                        .updatePartCostPaidStatus(
                                            repair.id, part.id, true);

                                    // Update the UI
                                    setBottomSheetState(() {
                                      unpaidParts.removeAt(index);
                                    });

                                    // Update main UI
                                    onUpdateUI();

                                    // Show success message
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            '${part.name} ${localizations.costHasBeenPaid}'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );

                                    // Close bottom sheet if there are no more unpaid parts
                                    if (unpaidParts.isEmpty) {
                                      Navigator.pop(context);
                                    }
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(localizations
                                            .errorWithMessage(e.toString())),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                },
                                icon: Icon(
                                  Icons.check,
                                  size: isMobile ? 14 : 16,
                                  color: Colors.white,
                                ),
                                label: Text(
                                  localizations.markAsPaid,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: isMobile ? 11 : 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: isMobile ? 8 : 10,
                                    vertical: isMobile ? 3 : 4,
                                  ),
                                  minimumSize: Size(0, isMobile ? 28 : 32),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  elevation: 1,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        isMobile ? 8 : 10),
                                  ),
                                ),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: isMobile ? 16 : 20,
                                  vertical: isMobile ? 6 : 8),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
