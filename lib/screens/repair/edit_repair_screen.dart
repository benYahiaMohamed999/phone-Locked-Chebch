import 'package:flutter/material.dart';
import '../../models/repair_transaction.dart';
import '../../services/repair_service.dart';
import '../../l10n/app_localizations.dart';

class EditRepairScreen extends StatefulWidget {
  final RepairTransaction repair;

  const EditRepairScreen({Key? key, required this.repair}) : super(key: key);

  @override
  _EditRepairScreenState createState() => _EditRepairScreenState();
}

class _EditRepairScreenState extends State<EditRepairScreen> {
  final _formKey = GlobalKey<FormState>();
  final _repairService = RepairService();
  late TextEditingController _phoneModelController;
  late TextEditingController _repairDetailsController;

  late TextEditingController _clientNameController;
  late TextEditingController _clientPhoneController;
  bool _isLoading = false;
  String? _selectedPhoneModel;

  // Predefined list of phone models

  @override
  void initState() {
    super.initState();
    _phoneModelController =
        TextEditingController(text: widget.repair.phoneModel);
    _repairDetailsController =
        TextEditingController(text: widget.repair.repairDetails);

    _clientNameController =
        TextEditingController(text: widget.repair.clientName ?? '');
    _clientPhoneController =
        TextEditingController(text: widget.repair.clientPhone ?? '');

    _selectedPhoneModel = widget.repair.phoneModel;
  }

  @override
  void dispose() {
    _phoneModelController.dispose();
    _repairDetailsController.dispose();

    _clientNameController.dispose();
    _clientPhoneController.dispose();
    super.dispose();
  }

  Future<void> _updateRepair() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _repairService.updateRepairTransaction(
        widget.repair.id,
        _selectedPhoneModel ?? _phoneModelController.text,
        _repairDetailsController.text,
        clientName: _clientNameController.text.isNotEmpty
            ? _clientNameController.text
            : null,
        clientPhone: _clientPhoneController.text.isNotEmpty
            ? _clientPhoneController.text
            : null,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.repairUpdated),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
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
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          localizations.editRepair,
          style: TextStyle(
            color: theme.colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: theme.colorScheme.primary,
        iconTheme: IconThemeData(color: theme.colorScheme.onPrimary),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.surfaceVariant.withOpacity(0.5),
              theme.colorScheme.surface,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          localizations.repairDetails,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _repairDetailsController,
                          decoration: InputDecoration(
                            labelText: localizations.repairDetails,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: Icon(
                              Icons.build,
                              color: theme.colorScheme.primary,
                            ),
                            fillColor: theme.colorScheme.surface,
                            filled: true,
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
                const SizedBox(height: 16),
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          localizations.clientInfo,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _clientNameController,
                          decoration: InputDecoration(
                            labelText: localizations.clientName,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: Icon(
                              Icons.person,
                              color: theme.colorScheme.primary,
                            ),
                            fillColor: theme.colorScheme.surface,
                            filled: true,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _clientPhoneController,
                          decoration: InputDecoration(
                            labelText: localizations.clientPhone,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: Icon(
                              Icons.phone,
                              color: theme.colorScheme.primary,
                            ),
                            fillColor: theme.colorScheme.surface,
                            filled: true,
                          ),
                          keyboardType: TextInputType.phone,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _updateRepair,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.save),
                            const SizedBox(width: 8),
                            Text(
                              localizations.save,
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
