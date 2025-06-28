import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/repair_part.dart';
import '../models/repair_transaction.dart';
import '../services/repair_service.dart';
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
      builder: (context) {
        final theme = Theme.of(context);
        final isMobile = MediaQuery.of(context).size.width < 600;
        final maxWidth = isMobile ? double.infinity : 500.0;
        final maxHeight =
            isMobile ? MediaQuery.of(context).size.height * 0.95 : 600.0;

        return Center(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: maxWidth,
              maxHeight: maxHeight,
            ),
            margin: EdgeInsets.symmetric(
              vertical: isMobile ? 0 : 40,
              horizontal: isMobile ? 0 : 24,
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.vertical(
                  top: Radius.circular(isMobile ? 20 : 28)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 24,
                  offset: const Offset(0, -8),
                ),
              ],
            ),
            child: DraggableScrollableSheet(
              initialChildSize: isMobile ? 0.85 : 0.7,
              minChildSize: isMobile ? 0.5 : 0.4,
              maxChildSize: 1.0,
              expand: false,
              builder: (context, scrollController) {
                return StatefulBuilder(
                  builder: (BuildContext context, StateSetter setModalState) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Handle
                        Padding(
                          padding: const EdgeInsets.only(top: 12, bottom: 8),
                          child: Container(
                            width: 40,
                            height: 5,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(2.5),
                            ),
                          ),
                        ),
                        // Title and close button
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
                              Expanded(
                                child: Text(
                                  localizations.partsAndPhoneModel(
                                      localizations.parts, repair.phoneModel),
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () => Navigator.pop(context),
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
                                  color: theme.colorScheme.outline
                                      .withOpacity(0.2),
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
                                            color: theme.colorScheme
                                                .onSecondaryContainer,
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
                            parts: partsList,
                            isReadOnly: false,
                            repairId: repair.id,
                            scrollController: scrollController,
                            onDeletePart: (part) async {
                              try {
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
                                await repairService.deletePartFromRepair(
                                    repair.id, part.id);
                                setModalState(() {
                                  partsList.removeWhere((p) => p.id == part.id);
                                });
                                onUpdateUI();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        localizations.partDeleted(part.name)),
                                    backgroundColor: Colors.green,
                                  ),
                                );
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
                              setModalState(() {
                                partsList.add(newPart);
                              });
                              onUpdateUI();
                            },
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}
