import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:phone_store_mangment/l10n/app_localizations.dart';

import '../../models/repair_transaction.dart';
import '../../models/repair_part.dart';
import '../../services/repair_service.dart';
import '../../widgets/parts_bottom_sheet.dart';

class AddRepairScreen extends StatefulWidget {
  const AddRepairScreen({super.key});

  @override
  State<AddRepairScreen> createState() => _AddRepairScreenState();
}

class _AddRepairScreenState extends State<AddRepairScreen> {
  AppLocalizations? _localizations;
  final _formKey = GlobalKey<FormState>();
  final _phoneModelController = TextEditingController();
  final _repairDetailsController = TextEditingController();
  final _clientNameController = TextEditingController();
  final _clientPhoneController = TextEditingController();
  bool _isPaid = false;
  bool _isLoading = false;
  final List<RepairPart> _parts = [];
  final _partNameController = TextEditingController();
  final _partCostController = TextEditingController();
  final _partPriceController = TextEditingController();
  bool _isCostPaid = false;

  // Getter for localizations to avoid null checks everywhere
  AppLocalizations get localizations => _localizations!;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _localizations = AppLocalizations.of(context);
  }

  @override
  void initState() {
    super.initState();
  }

  void _showAddPartBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddPartBottomSheet(
        onAddPart: (RepairPart part) {
          setState(() {
            _parts.add(part);
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showPartsListBottomSheet() {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: screenSize.height * 0.8,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle and header
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: isSmallScreen ? 12 : 16,
                ),
                child: Column(
                  children: [
                    // Drag handle
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onSurface.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 16 : 20),

                    // Header with title and total
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.build_circle_outlined,
                              color: theme.colorScheme.primary,
                              size: isSmallScreen ? 20 : 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${_parts.length} ${_parts.length == 1 ? localizations.part : localizations.parts}',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),

                        // Total cost chip
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            '${localizations.total}: ${_parts.fold(0.0, (sum, part) => sum + part.sellingPrice).toStringAsFixed(2)} ${localizations.currency}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // Parts list
              Expanded(
                child: _parts.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inventory_2_outlined,
                              size: isSmallScreen ? 48 : 64,
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.3),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              localizations.noParts,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      )
                    : Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: isSmallScreen ? double.infinity : 600,
                          ),
                          child: ListView.separated(
                            itemCount: _parts.length,
                            separatorBuilder: (_, __) =>
                                const Divider(height: 1),
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              final part = _parts[index];
                              return Dismissible(
                                key: Key(part.id),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  alignment: Alignment.centerRight,
                                  color: Colors.red,
                                  padding: const EdgeInsets.only(right: 16),
                                  child: const Icon(
                                    Icons.delete_forever,
                                    color: Colors.white,
                                  ),
                                ),
                                onDismissed: (direction) {
                                  setState(() {
                                    _parts.removeAt(index);
                                  });
                                },
                                child: ListTile(
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: isSmallScreen ? 8 : 12,
                                  ),
                                  title: Text(
                                    part.name,
                                    style:
                                        theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  '${localizations.costPrice}: ${part.costPrice.toStringAsFixed(2)} ${localizations.currency}',
                                                  style:
                                                      theme.textTheme.bodySmall,
                                                ),
                                                Text(
                                                  '${localizations.sellingPrice}: ${part.sellingPrice.toStringAsFixed(2)} ${localizations.currency}',
                                                  style:
                                                      theme.textTheme.bodySmall,
                                                ),
                                              ],
                                            ),
                                          ),
                                          Chip(
                                            label: Text(
                                              '${localizations.profit}: ${(part.sellingPrice - part.costPrice).toStringAsFixed(2)}',
                                              style: theme.textTheme.bodySmall
                                                  ?.copyWith(
                                                color: part.sellingPrice -
                                                            part.costPrice >
                                                        0
                                                    ? Colors.green
                                                    : theme.colorScheme.error,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            backgroundColor: (part
                                                                .sellingPrice -
                                                            part.costPrice >
                                                        0
                                                    ? Colors.green
                                                    : theme.colorScheme.error)
                                                .withOpacity(0.1),
                                            padding: EdgeInsets.zero,
                                            visualDensity:
                                                VisualDensity.compact,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(
                                            part.isCostPaid
                                                ? Icons.check_circle
                                                : Icons.pending,
                                            size: 16,
                                            color: part.isCostPaid
                                                ? Colors.green
                                                : theme.colorScheme.primary
                                                    .withOpacity(0.6),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            part.isCostPaid
                                                ? localizations.costPaid
                                                : localizations.costPending,
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                              color: part.isCostPaid
                                                  ? Colors.green
                                                  : theme.colorScheme.primary
                                                      .withOpacity(0.6),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.red,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _parts.removeAt(index);
                                      });
                                      if (_parts.isEmpty) {
                                        Navigator.pop(context);
                                      }
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
              ),

              // Bottom buttons
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: isSmallScreen ? 12 : 16,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.check),
                      label: Text(localizations.done),
                      style: TextButton.styleFrom(
                        foregroundColor: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: _showAddPartBottomSheet,
                      icon: const Icon(Icons.add),
                      label: Text(
                        isSmallScreen
                            ? localizations.add
                            : localizations.addPart,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_parts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations.addAtLeastOnePart)),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null)
        throw Exception(
            localizations.errorWithMessage('User not authenticated'));

      final transaction = RepairTransaction(
        id: '', // Firestore will generate this
        phoneModel: _phoneModelController.text.trim(),
        repairDetails: _repairDetailsController.text,
        parts: _parts,
        isPaid: _isPaid,
        createdAt: DateTime.now(),
        userId: userId,
        clientName: _clientNameController.text.isEmpty
            ? null
            : _clientNameController.text.trim(),
        clientPhone: _clientPhoneController.text.isEmpty
            ? null
            : _clientPhoneController.text.trim(),
      );

      await RepairService().addRepairTransaction(transaction);
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${localizations.error}: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: Text(
          localizations.addNewRepair,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onPrimary,
          ),
        ),
        backgroundColor: theme.colorScheme.primary,
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isSmallScreen ? double.infinity : 600,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Client information card
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.person,
                                  color: theme.colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  localizations.clientInfo,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Client name field
                            TextFormField(
                              controller: _clientNameController,
                              decoration: InputDecoration(
                                labelText: localizations.clientNameOptional,
                                hintText: 'John Doe',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                prefixIcon: const Icon(Icons.person_outline),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Client phone field
                            TextFormField(
                              controller: _clientPhoneController,
                              decoration: InputDecoration(
                                labelText: localizations.clientPhoneOptional,
                                hintText: '+1 234 567 8900',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                prefixIcon: const Icon(Icons.phone),
                              ),
                              keyboardType: TextInputType.phone,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Phone model section with card
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.phone_iphone,
                                  color: theme.colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  localizations.phoneModel,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Phone model text field - now the only option
                            TextFormField(
                              controller: _phoneModelController,
                              decoration: InputDecoration(
                                labelText: localizations.phoneModel,
                                hintText: 'e.g. iPhone 13 Pro Max',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                prefixIcon: const Icon(Icons.phone_android),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return localizations.fieldRequired;
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Repair details card
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.build_circle,
                                  color: theme.colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  localizations.repairDetails,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _repairDetailsController,
                              decoration: InputDecoration(
                                hintText: localizations.describeRepairNeeded,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              maxLines: 3,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return localizations.repairDetailsRequired;
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Repair parts card
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.hardware,
                                        color: theme.colorScheme.primary,
                                      ),
                                      const SizedBox(width: 8),
                                      Flexible(
                                        child: Text(
                                          localizations.repairParts,
                                          style: theme.textTheme.titleMedium
                                              ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: theme.colorScheme.primary,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                ElevatedButton.icon(
                                  onPressed: _showAddPartBottomSheet,
                                  icon: const Icon(Icons.add, size: 18),
                                  label: Text(
                                    isSmallScreen
                                        ? localizations.add
                                        : localizations.addPart,
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: theme.colorScheme.primary,
                                    foregroundColor:
                                        theme.colorScheme.onPrimary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 0,
                                    padding: isSmallScreen
                                        ? const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 8)
                                        : null,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            if (_parts.isEmpty)
                              Container(
                                padding:
                                    EdgeInsets.all(isSmallScreen ? 16 : 24),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surface,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: theme.colorScheme.outline
                                        .withOpacity(0.3),
                                  ),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.inventory_2_outlined,
                                      size: isSmallScreen ? 36 : 48,
                                      color: theme.colorScheme.onSurface
                                          .withOpacity(0.3),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      localizations.noParts,
                                      style:
                                          theme.textTheme.bodyLarge?.copyWith(
                                        color: theme.colorScheme.onSurface
                                            .withOpacity(0.6),
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              )
                            else
                              InkWell(
                                onTap: _showPartsListBottomSheet,
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primaryContainer
                                        .withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Flexible(
                                            child: Row(
                                              children: [
                                                Container(
                                                  padding:
                                                      const EdgeInsets.all(8),
                                                  decoration: BoxDecoration(
                                                    color: theme
                                                        .colorScheme.primary
                                                        .withOpacity(0.1),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Text(
                                                    _parts.length.toString(),
                                                    style: theme
                                                        .textTheme.titleMedium
                                                        ?.copyWith(
                                                      color: theme
                                                          .colorScheme.primary,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Flexible(
                                                  child: Text(
                                                    _parts.length == 1
                                                        ? localizations.part
                                                        : localizations.parts,
                                                    style: theme
                                                        .textTheme.titleMedium
                                                        ?.copyWith(
                                                      color: theme.colorScheme
                                                          .onSurface,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Icon(
                                            Icons.chevron_right,
                                            color: theme.colorScheme.primary,
                                          ),
                                        ],
                                      ),
                                      if (_parts.isNotEmpty) ...[
                                        const SizedBox(height: 12),
                                        Divider(
                                            color: theme.colorScheme.outline
                                                .withOpacity(0.3)),
                                        const SizedBox(height: 12),
                                        isSmallScreen
                                            ? Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        '${localizations.total}:',
                                                        style: theme.textTheme
                                                            .bodyMedium,
                                                      ),
                                                      Text(
                                                        '${_parts.fold(0.0, (sum, part) => sum + part.sellingPrice).toStringAsFixed(2)} ${localizations.currency}',
                                                        style: theme.textTheme
                                                            .titleMedium
                                                            ?.copyWith(
                                                          color: theme
                                                              .colorScheme
                                                              .primary,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        '${localizations.profit}:',
                                                        style: theme.textTheme
                                                            .bodyMedium,
                                                      ),
                                                      Text(
                                                        '${_parts.fold(0.0, (sum, part) => sum + (part.sellingPrice - part.costPrice)).toStringAsFixed(2)} ${localizations.currency}',
                                                        style: theme.textTheme
                                                            .titleSmall
                                                            ?.copyWith(
                                                          color: Colors.green,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              )
                                            : Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        '${localizations.total}:',
                                                        style: theme.textTheme
                                                            .bodyMedium,
                                                      ),
                                                      Text(
                                                        '${_parts.fold(0.0, (sum, part) => sum + part.sellingPrice).toStringAsFixed(2)} ${localizations.currency}',
                                                        style: theme.textTheme
                                                            .titleMedium
                                                            ?.copyWith(
                                                          color: theme
                                                              .colorScheme
                                                              .primary,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.end,
                                                    children: [
                                                      Text(
                                                        '${localizations.profit}:',
                                                        style: theme.textTheme
                                                            .bodyMedium,
                                                      ),
                                                      Text(
                                                        '${_parts.fold(0.0, (sum, part) => sum + (part.sellingPrice - part.costPrice)).toStringAsFixed(2)} ${localizations.currency}',
                                                        style: theme.textTheme
                                                            .titleSmall
                                                            ?.copyWith(
                                                          color: Colors.green,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Payment status card
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: SwitchListTile(
                          title: Text(
                            localizations.markAsPaid,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            _isPaid
                                ? localizations.repairAlreadyPaid
                                : localizations.repairNotPaidYet,
                            style: theme.textTheme.bodyMedium,
                          ),
                          value: _isPaid,
                          onChanged: (value) {
                            setState(() => _isPaid = value);
                          },
                          secondary: Icon(
                            _isPaid ? Icons.check_circle : Icons.money_off,
                            color: _isPaid
                                ? Colors.green
                                : theme.colorScheme.error,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Submit button
                    ElevatedButton(
                      onPressed: _isLoading ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              localizations.addRepair,
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
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _phoneModelController.dispose();
    _repairDetailsController.dispose();
    _partNameController.dispose();
    _partCostController.dispose();
    _partPriceController.dispose();
    _clientNameController.dispose();
    _clientPhoneController.dispose();
    super.dispose();
  }
}

class AddPartBottomSheet extends StatefulWidget {
  final Function(RepairPart) onAddPart;

  const AddPartBottomSheet({
    Key? key,
    required this.onAddPart,
  }) : super(key: key);

  @override
  State<AddPartBottomSheet> createState() => _AddPartBottomSheetState();
}

class _AddPartBottomSheetState extends State<AddPartBottomSheet> {
  final _partNameController = TextEditingController();
  final _partCostController = TextEditingController();
  final _partPriceController = TextEditingController();
  bool _isCostPaid = false;

  @override
  void dispose() {
    _partNameController.dispose();
    _partCostController.dispose();
    _partPriceController.dispose();
    super.dispose();
  }

  void _addPart() {
    final name = _partNameController.text.trim();
    final costPrice = double.tryParse(_partCostController.text) ?? 0;
    final sellingPrice = double.tryParse(_partPriceController.text) ?? 0;
    final localizations = AppLocalizations.of(context)!;

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations.partNameRequired)),
      );
      return;
    }

    if (costPrice <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations.invalidCostPrice)),
      );
      return;
    }

    if (sellingPrice <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations.invalidSellingPrice)),
      );
      return;
    }

    final part = RepairPart(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      costPrice: costPrice,
      sellingPrice: sellingPrice,
      description: name,
      createdAt: DateTime.now(),
      isCostPaid: _isCostPaid,
    );

    widget.onAddPart(part);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    final localizations = AppLocalizations.of(context)!;

    return Container(
      constraints: BoxConstraints(
        maxHeight: screenSize.height * 0.9,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: bottomPadding > 0 ? bottomPadding : 16,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isSmallScreen ? double.infinity : 500,
              ),
              child: Padding(
                padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Handle and title row
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
                    SizedBox(height: isSmallScreen ? 20 : 32),

                    // Part name field with modern decoration
                    TextFormField(
                      controller: _partNameController,
                      decoration: InputDecoration(
                        labelText: localizations.partName,
                        prefixIcon:
                            Icon(Icons.build, color: theme.colorScheme.primary),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: theme.colorScheme.outline.withOpacity(0.5),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: theme.colorScheme.primary,
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: theme.colorScheme.surface,
                      ),
                      textInputAction: TextInputAction.next,
                    ),
                    SizedBox(height: isSmallScreen ? 12 : 20),

                    // Cost fields row or column based on screen size
                    isSmallScreen
                        ? Column(
                            children: [
                              // Cost price field
                              TextFormField(
                                controller: _partCostController,
                                decoration: InputDecoration(
                                  labelText: localizations.costPrice,
                                  prefixIcon: Icon(Icons.attach_money,
                                      color: theme.colorScheme.primary),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: theme.colorScheme.outline
                                          .withOpacity(0.5),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: theme.colorScheme.primary,
                                      width: 2,
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: theme.colorScheme.surface,
                                ),
                                keyboardType: TextInputType.number,
                                textInputAction: TextInputAction.next,
                              ),
                              const SizedBox(height: 12),

                              // Selling price field
                              TextFormField(
                                controller: _partPriceController,
                                decoration: InputDecoration(
                                  labelText: localizations.sellingPrice,
                                  prefixIcon: Icon(Icons.point_of_sale,
                                      color: theme.colorScheme.primary),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: theme.colorScheme.outline
                                          .withOpacity(0.5),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: theme.colorScheme.primary,
                                      width: 2,
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: theme.colorScheme.surface,
                                ),
                                keyboardType: TextInputType.number,
                                textInputAction: TextInputAction.done,
                              ),
                            ],
                          )
                        : Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Cost price field
                              Expanded(
                                child: TextFormField(
                                  controller: _partCostController,
                                  decoration: InputDecoration(
                                    labelText: localizations.costPrice,
                                    prefixIcon: Icon(Icons.attach_money,
                                        color: theme.colorScheme.primary),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: theme.colorScheme.outline
                                            .withOpacity(0.5),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: theme.colorScheme.primary,
                                        width: 2,
                                      ),
                                    ),
                                    filled: true,
                                    fillColor: theme.colorScheme.surface,
                                  ),
                                  keyboardType: TextInputType.number,
                                  textInputAction: TextInputAction.next,
                                ),
                              ),
                              const SizedBox(width: 16),

                              // Selling price field
                              Expanded(
                                child: TextFormField(
                                  controller: _partPriceController,
                                  decoration: InputDecoration(
                                    labelText: localizations.sellingPrice,
                                    prefixIcon: Icon(Icons.point_of_sale,
                                        color: theme.colorScheme.primary),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: theme.colorScheme.outline
                                            .withOpacity(0.5),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: theme.colorScheme.primary,
                                        width: 2,
                                      ),
                                    ),
                                    filled: true,
                                    fillColor: theme.colorScheme.surface,
                                  ),
                                  keyboardType: TextInputType.number,
                                  textInputAction: TextInputAction.done,
                                ),
                              ),
                            ],
                          ),
                    SizedBox(height: isSmallScreen ? 12 : 20),

                    // Cost paid switch
                    Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: SwitchListTile(
                        title: Text(
                          localizations.costPaid,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          _isCostPaid
                              ? localizations.costHasBeenPaid
                              : localizations.costNotPaidYet,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                        value: _isCostPaid,
                        onChanged: (value) {
                          setState(() {
                            _isCostPaid = value;
                          });
                        },
                        secondary: Icon(
                          _isCostPaid ? Icons.check_circle : Icons.money_off,
                          color: _isCostPaid
                              ? Colors.green
                              : theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 24 : 32),

                    // Add button
                    ElevatedButton(
                      onPressed: _addPart,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
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
          ),
        ),
      ),
    );
  }
}
