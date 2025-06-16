import 'package:flutter/material.dart';
import '../models/repair_part.dart';
import '../l10n/app_localizations.dart';
import '../services/repair_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PartsBottomSheet extends StatefulWidget {
  final List<RepairPart> parts;
  final bool isReadOnly;
  final Function(RepairPart)? onDeletePart;
  final Function(RepairPart)? onPartAdded;
  final String? repairId;
  final ScrollController? scrollController;

  const PartsBottomSheet({
    Key? key,
    required this.parts,
    this.isReadOnly = false,
    this.onDeletePart,
    this.onPartAdded,
    this.repairId,
    this.scrollController,
  }) : super(key: key);

  @override
  State<PartsBottomSheet> createState() => _PartsBottomSheetState();
}

class _PartsBottomSheetState extends State<PartsBottomSheet> {
  final _repairService = RepairService();
  List<RepairPart> _parts = [];

  @override
  void initState() {
    super.initState();
    _parts = List<RepairPart>.from(widget.parts);
  }

  @override
  void didUpdateWidget(PartsBottomSheet oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Always update the parts list when the widget updates
    setState(() {
      _parts = List<RepairPart>.from(widget.parts);
    });
  }

  void _toggleCostPaidStatus(RepairPart part, bool newValue) async {
    if (widget.repairId == null) {
      return;
    }

    // Check if part ID is null or empty and use part name instead
    String partIdentifier = part.id.isNotEmpty ? part.id : part.name;

    try {
      // Show a loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(width: 16),
              Text(AppLocalizations.of(context)!.loading),
            ],
          ),
          duration: const Duration(seconds: 1),
        ),
      );

      // Use the repair service to update the part status
      await _repairService.updatePartCostPaidStatus(
        widget.repairId!,
        partIdentifier,
        newValue,
      );

      // Create an updated part with the new isCostPaid value
      final updatedPart = RepairPart(
        id: part.id.isNotEmpty
            ? part.id
            : 'part_${DateTime.now().millisecondsSinceEpoch}',
        name: part.name,
        description: part.description,
        costPrice: part.costPrice,
        sellingPrice: part.sellingPrice,
        createdAt: part.createdAt,
        isCostPaid: newValue,
      );

      // Update local state
      setState(() {
        final index = _parts.indexWhere((p) =>
            (p.id.isNotEmpty && p.id == part.id) ||
            (p.id.isEmpty && p.name == part.name));

        if (index != -1) {
          // Replace the part in the list
          _parts[index] = updatedPart;
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newValue
                  ? AppLocalizations.of(context)!.costHasBeenPaid
                  : AppLocalizations.of(context)!.costNotPaidYet,
            ),
            backgroundColor: newValue ? Colors.green : Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating part status: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showAddPartBottomSheet() {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;

    // Form controllers
    final nameController = TextEditingController();
    final costController = TextEditingController();
    final priceController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isCostPaid = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Handle and title
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.onSurface.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            localizations.addPart,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Part name field
                    TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: localizations.partName,
                        prefixIcon:
                            Icon(Icons.build, color: theme.colorScheme.primary),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return localizations.partNameRequired;
                        }
                        return null;
                      },
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),

                    // Cost and Price fields in a row or column based on screen size
                    if (isSmallScreen)
                      Column(
                        children: [
                          _buildPriceField(
                            controller: costController,
                            label: localizations.costPrice,
                            icon: Icons.shopping_cart_outlined,
                            validator: (value) {
                              if (value == null ||
                                  value.isEmpty ||
                                  double.tryParse(value) == null) {
                                return localizations.invalidCostPrice;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildPriceField(
                            controller: priceController,
                            label: localizations.sellingPrice,
                            icon: Icons.monetization_on_outlined,
                            validator: (value) {
                              if (value == null ||
                                  value.isEmpty ||
                                  double.tryParse(value) == null) {
                                return localizations.invalidSellingPrice;
                              }
                              return null;
                            },
                          ),
                        ],
                      )
                    else
                      Row(
                        children: [
                          Expanded(
                            child: _buildPriceField(
                              controller: costController,
                              label: localizations.costPrice,
                              icon: Icons.shopping_cart_outlined,
                              validator: (value) {
                                if (value == null ||
                                    value.isEmpty ||
                                    double.tryParse(value) == null) {
                                  return localizations.invalidCostPrice;
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildPriceField(
                              controller: priceController,
                              label: localizations.sellingPrice,
                              icon: Icons.monetization_on_outlined,
                              validator: (value) {
                                if (value == null ||
                                    value.isEmpty ||
                                    double.tryParse(value) == null) {
                                  return localizations.invalidSellingPrice;
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 16),

                    // Cost paid toggle
                    Row(
                      children: [
                        Switch.adaptive(
                          value: isCostPaid,
                          onChanged: (value) {
                            setState(() {
                              isCostPaid = value;
                            });
                          },
                          activeColor: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          localizations.costPaid,
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          isCostPaid
                              ? Icons.check_circle_outline
                              : Icons.money_off_outlined,
                          size: 18,
                          color: isCostPaid
                              ? Colors.green
                              : theme.colorScheme.error,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Add button
                    ElevatedButton(
                      onPressed: () async {
                        if (formKey.currentState?.validate() ?? false) {
                          final name = nameController.text.trim();
                          final cost =
                              double.tryParse(costController.text) ?? 0;
                          final price =
                              double.tryParse(priceController.text) ?? 0;

                          if (widget.repairId != null) {
                            try {
                              // Create a new part object
                              final newPart = RepairPart(
                                id: 'part_${DateTime.now().millisecondsSinceEpoch}',
                                name: name,
                                description: name,
                                costPrice: cost,
                                sellingPrice: price,
                                createdAt: DateTime.now(),
                                isCostPaid: isCostPaid,
                              );

                              // Add to Firestore
                              await _repairService.addPartToRepair(
                                widget.repairId!,
                                newPart,
                              );

                              // Close the add part dialog
                              Navigator.pop(context);

                              // Update local state with the new part
                              setState(() {
                                _parts.add(newPart);
                              });

                              // Call the onPartAdded callback if provided
                              if (widget.onPartAdded != null) {
                                widget.onPartAdded!(newPart);
                              }

                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        '${localizations.addPart} ${localizations.success}'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${localizations.error}: $e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        localizations.add,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
      },
    );
  }

  Widget _buildPriceField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
  }) {
    final theme = Theme.of(context);

    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: theme.colorScheme.primary),
        prefixText: '\$',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: validator,
      textInputAction: TextInputAction.next,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;
    final mediaQuery = MediaQuery.of(context);

    return Container(
      width: mediaQuery.size.width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withOpacity(0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    localizations.repairParts,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (!widget.isReadOnly)
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    child: OutlinedButton.icon(
                      onPressed: _showAddPartBottomSheet,
                      icon: Icon(
                        Icons.add,
                        size: 18,
                        color: theme.colorScheme.primary,
                      ),
                      label: Text(
                        localizations.addPart,
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        side: BorderSide(color: theme.colorScheme.primary),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const Divider(),
          if (_parts.isEmpty)
            Expanded(
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  constraints: const BoxConstraints(maxWidth: 300),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.build_outlined,
                          size: 40,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        localizations.noParts,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (!widget.isReadOnly)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            localizations.addAtLeastOnePart,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      if (!widget.isReadOnly)
                        Padding(
                          padding: const EdgeInsets.only(top: 24),
                          child: ElevatedButton.icon(
                            onPressed: _showAddPartBottomSheet,
                            icon: const Icon(Icons.add),
                            label: Text(localizations.addPart),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            )
          else
            Flexible(
              child: ListView.separated(
                controller: widget.scrollController,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                shrinkWrap: true,
                itemCount: _parts.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final part = _parts[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    elevation: 0,
                    color: theme.colorScheme.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: theme.colorScheme.outline.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  part.name,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: theme.colorScheme.primary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (!widget.isReadOnly &&
                                  widget.onDeletePart != null)
                                IconButton(
                                  icon: Icon(
                                    Icons.delete_outline,
                                    color: theme.colorScheme.error,
                                    size: 20,
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 36,
                                    minHeight: 36,
                                  ),
                                  padding: EdgeInsets.zero,
                                  visualDensity: VisualDensity.compact,
                                  onPressed: () {
                                    // Call the onDeletePart callback
                                    widget.onDeletePart!(part);

                                    // Immediately update the local list
                                    setState(() {
                                      _parts
                                          .removeWhere((p) => p.id == part.id);
                                    });
                                  },
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Price information
                          Row(
                            children: [
                              Expanded(
                                child: _buildPriceInfo(
                                  theme,
                                  title: localizations.costPrice,
                                  price: part.costPrice,
                                  icon: Icons.shopping_cart_outlined,
                                ),
                              ),
                              Expanded(
                                child: _buildPriceInfo(
                                  theme,
                                  title: localizations.sellingPrice,
                                  price: part.sellingPrice,
                                  icon: Icons.monetization_on_outlined,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          // Profit indicator
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: (part.sellingPrice - part.costPrice) >= 0
                                  ? Colors.green.withOpacity(0.1)
                                  : theme.colorScheme.error.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  (part.sellingPrice - part.costPrice) >= 0
                                      ? Icons.trending_up
                                      : Icons.trending_down,
                                  size: 16,
                                  color:
                                      (part.sellingPrice - part.costPrice) >= 0
                                          ? Colors.green
                                          : theme.colorScheme.error,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '${localizations.profit}: \$${(part.sellingPrice - part.costPrice).toStringAsFixed(2)}',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color:
                                        (part.sellingPrice - part.costPrice) >=
                                                0
                                            ? Colors.green
                                            : theme.colorScheme.error,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Cost paid status
                          if (!widget.isReadOnly && widget.repairId != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Row(
                                children: [
                                  Switch.adaptive(
                                    value: part.isCostPaid,
                                    onChanged: (value) =>
                                        _toggleCostPaidStatus(part, value),
                                    activeColor: theme.colorScheme.primary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    localizations.costPaid,
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    part.isCostPaid
                                        ? Icons.check_circle_outline
                                        : Icons.money_off_outlined,
                                    size: 16,
                                    color: part.isCostPaid
                                        ? Colors.green
                                        : theme.colorScheme.error,
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPriceInfo(
    ThemeData theme, {
    required String title,
    required double price,
    required IconData icon,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              '\$${price.toStringAsFixed(2)}',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
