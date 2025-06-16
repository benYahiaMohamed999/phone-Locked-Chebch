import 'package:flutter/material.dart';
import '../models/repair_transaction.dart';
import '../models/repair_part.dart';
import '../services/repair_service.dart';
import '../l10n/app_localizations.dart';
import 'parts_bottom_sheet.dart';

class PartsModalBottomSheet {
  /// Shows a modal bottom sheet with parts information and management
  static Future<void> show({
    required BuildContext context,
    required RepairTransaction repair,
    required VoidCallback onUpdateUI,
  }) async {
    // Create a mutable copy of the parts list so it can be updated
    List<RepairPart> partsList = List<RepairPart>.from(repair.parts);
    final repairService = RepairService();
    final localizations = AppLocalizations.of(context)!;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final theme = Theme.of(context);
        return DraggableScrollableSheet(
          initialChildSize: 0.6, // Start at 60% of screen height
          minChildSize: 0.3, // Can be collapsed to 30%
          maxChildSize: 0.95, // Can expand to 95%
          expand: false,
          builder: (context, scrollController) {
            return StatefulBuilder(
              builder: (BuildContext context, StateSetter setModalState) {
                return Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(20)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Drag handle
                      Padding(
                        padding: const EdgeInsets.only(top: 12, bottom: 8),
                        child: Container(
                          width: 40,
                          height: 5,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.onSurface.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(2.5),
                          ),
                        ),
                      ),
                      // Title
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        child: Row(
                          children: [
                            Icon(
                              Icons.build_outlined,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              localizations.partsAndPhoneModel(
                                  localizations.parts, repair.phoneModel),
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Client information if available
                      if (repair.clientName != null ||
                          repair.clientPhone != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 8),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.secondaryContainer
                                  .withOpacity(0.3),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color:
                                    theme.colorScheme.outline.withOpacity(0.2),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  localizations.clientInfo,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                if (repair.clientName != null &&
                                    repair.clientName!.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.person_outline,
                                          size: 16,
                                          color: theme
                                              .colorScheme.onSecondaryContainer,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            repair.clientName!,
                                            style: theme.textTheme.bodyMedium
                                                ?.copyWith(
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                if (repair.clientPhone != null &&
                                    repair.clientPhone!.isNotEmpty)
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.phone_outlined,
                                        size: 16,
                                        color: theme
                                            .colorScheme.onSecondaryContainer,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        repair.clientPhone!,
                                        style: theme.textTheme.bodyMedium,
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ),

                      const Divider(),
                      // Main content
                      Expanded(
                        child: PartsBottomSheet(
                          // Use the local partsList which will be updated on deletion/addition
                          parts: partsList,
                          isReadOnly: false,
                          repairId: repair.id,
                          scrollController: scrollController,
                          onDeletePart: (part) async {
                            // Implement part deletion logic
                            try {
                              // Show loading indicator
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Colors.white),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Text(localizations.loading),
                                    ],
                                  ),
                                  duration: const Duration(seconds: 1),
                                ),
                              );

                              // Attempt to delete the part
                              await repairService.deletePartFromRepair(
                                  repair.id, part.id);

                              // Remove the part from the local list
                              setModalState(() {
                                partsList.removeWhere((p) => p.id == part.id);
                              });

                              // Update the main UI as well
                              onUpdateUI();

                              // Show success message
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      localizations.partDeleted(part.name)),
                                  backgroundColor: Colors.green,
                                ),
                              );

                              // Close bottom sheet if there are no more parts
                              if (partsList.isEmpty) {
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
                          onPartAdded: (RepairPart newPart) {
                            // Update the UI when a part is added
                            setModalState(() {
                              partsList.add(newPart);
                            });

                            // Update the main UI as well
                            onUpdateUI();
                          },
                        ),
                      ),
                    ],
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
