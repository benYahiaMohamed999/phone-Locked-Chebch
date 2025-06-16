// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Phone Repair Management';

  @override
  String get loginTitle => 'Login';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get loginButton => 'Login';

  @override
  String get logoutButton => 'Logout';

  @override
  String get totalEarnings => 'Total Earnings';

  @override
  String get unpaidRepairs => 'Unpaid';

  @override
  String get paidRepairs => 'Paid';

  @override
  String get dateRange => 'Date Range';

  @override
  String get selectRange => 'Select Range';

  @override
  String get from => 'From';

  @override
  String get to => 'To';

  @override
  String get noPaidRepairs => 'No paid repairs found';

  @override
  String get noUnpaidRepairs => 'No unpaid repairs found';

  @override
  String get totalCost => 'Total Cost';

  @override
  String get totalSellingPrice => 'Total Selling Price';

  @override
  String get profit => 'Profit';

  @override
  String get confirmDelete => 'Delete Repair';

  @override
  String get deleteRepairConfirmation => 'Are you sure you want to delete this repair? This action cannot be undone.';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get repairMarkedAsPaid => 'Repair marked as paid successfully';

  @override
  String get errorMarkingAsPaid => 'Error marking repair as paid';

  @override
  String get repairDeleted => 'Repair deleted successfully';

  @override
  String get errorDeletingRepair => 'Error deleting repair';

  @override
  String get addRepair => 'Add Repair';

  @override
  String get phoneModel => 'Phone Model';

  @override
  String get phoneModelRequired => 'Please enter the phone model';

  @override
  String get repairDetails => 'Repair Details';

  @override
  String get repairDetailsRequired => 'Please enter repair details';

  @override
  String get totalSellingPriceRequired => 'Please enter the total selling price';

  @override
  String get invalidPrice => 'Please enter a valid price';

  @override
  String get repairUpdated => 'Repair updated successfully';

  @override
  String get markAsPaid => 'Mark as Paid';

  @override
  String get save => 'Save';

  @override
  String get error => 'Error';

  @override
  String get success => 'Success';

  @override
  String get loading => 'Loading...';

  @override
  String get noData => 'No Data';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get editRepair => 'Edit Repair';

  @override
  String get analytics => 'Analytics';

  @override
  String get noRepairsFound => 'No repairs found for the selected date range';

  @override
  String get totalRepairs => 'Total Repairs';

  @override
  String get totalRevenue => 'Total Revenue';

  @override
  String get totalProfit => 'Total Profit';

  @override
  String get partCost => 'Part Cost';

  @override
  String get serviceCost => 'Service Cost';

  @override
  String get repairParts => 'Repair Parts';

  @override
  String get addPart => 'Add Part';

  @override
  String get noParts => 'No parts added yet';

  @override
  String get costPrice => 'Cost Price';

  @override
  String get sellingPrice => 'Selling Price';

  @override
  String get partName => 'Part Name';

  @override
  String get add => 'Add';

  @override
  String get partNameRequired => 'Part name is required';

  @override
  String get invalidCostPrice => 'Invalid cost price';

  @override
  String get invalidSellingPrice => 'Invalid selling price';

  @override
  String get part => 'Part';

  @override
  String get parts => 'Parts';

  @override
  String get total => 'Total';

  @override
  String get currency => 'USD';

  @override
  String get settings => 'Settings';

  @override
  String get appearance => 'Appearance';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get darkModeDescription => 'Enable dark mode for better visibility in low-light conditions';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get french => 'French';

  @override
  String get arabic => 'Arabic';

  @override
  String get account => 'Account';

  @override
  String get logout => 'Logout';

  @override
  String get logoutConfirmation => 'Are you sure you want to logout?';

  @override
  String get costPaid => 'Cost Paid';

  @override
  String get costHasBeenPaid => 'Cost has been paid';

  @override
  String get costNotPaidYet => 'Cost not paid yet';

  @override
  String get done => 'Done';

  @override
  String get presetModels => 'Preset Models';

  @override
  String get customModel => 'Custom Model';

  @override
  String get customPhoneModel => 'Custom Phone Model';

  @override
  String get phoneModelExample => 'e.g. Xiaomi Mi 11';

  @override
  String get selectPhoneModel => 'Select Phone Model';

  @override
  String get describeRepairNeeded => 'Describe the repair needed...';

  @override
  String get repairAlreadyPaid => 'This repair is already paid';

  @override
  String get repairNotPaidYet => 'This repair is not paid yet';

  @override
  String get costPending => 'Cost Pending';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get thisWeek => 'This Week';

  @override
  String get thisMonth => 'This Month';

  @override
  String get customRange => 'Custom Range';

  @override
  String get fieldRequired => 'This field is required';

  @override
  String get addNewRepair => 'Add New Repair';

  @override
  String get addAtLeastOnePart => 'Please add at least one repair part';

  @override
  String get clientName => 'Client Name';

  @override
  String get clientPhone => 'Client Phone Number';

  @override
  String get clientNameOptional => 'Client Name (Optional)';

  @override
  String get clientPhoneOptional => 'Client Phone Number (Optional)';

  @override
  String get clientInfo => 'Client Information';

  @override
  String get searchByClientPhoneModel => 'Search by client, phone, or model...';

  @override
  String get markAllAsPaid => 'Mark All Paid';

  @override
  String get confirmMarkAllPaid => 'Are you sure you want to mark all parts as paid?';

  @override
  String partDeleted(Object partName) {
    return '$partName deleted';
  }

  @override
  String partsAndPhoneModel(Object parts, Object phoneModel) {
    return '$parts - $phoneModel';
  }

  @override
  String errorWithMessage(Object message) {
    return 'Error: $message';
  }

  @override
  String get revenue => 'Revenue';

  @override
  String get daily => 'Daily';

  @override
  String get profitTrend => 'Profit Trend';

  @override
  String get loadingAnalyticsData => 'Loading analytics data...';

  @override
  String get errorLoadingData => 'Error loading data';

  @override
  String get noRepairsForSelectedPeriod => 'No repairs found for selected period';

  @override
  String get noProfitDataAvailable => 'No profit data available for the selected period';

  @override
  String get noRepairDataAvailable => 'No repair data available for the selected period';

  @override
  String get repairStatus => 'Repair Status';

  @override
  String get sevenD => '7D';

  @override
  String get thirtyD => '30D';

  @override
  String get ninetyD => '90D';

  @override
  String get ytd => 'YTD';
}
