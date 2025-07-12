import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
    Locale('ar')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Phone Repair Management'**
  String get appTitle;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginTitle;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginButton;

  /// No description provided for @logoutButton.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logoutButton;

  /// No description provided for @totalEarnings.
  ///
  /// In en, this message translates to:
  /// **'Total Earnings'**
  String get totalEarnings;

  /// No description provided for @unpaidRepairs.
  ///
  /// In en, this message translates to:
  /// **'Unpaid'**
  String get unpaidRepairs;

  /// No description provided for @paidRepairs.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paidRepairs;

  /// No description provided for @dateRange.
  ///
  /// In en, this message translates to:
  /// **'Date Range'**
  String get dateRange;

  /// No description provided for @selectRange.
  ///
  /// In en, this message translates to:
  /// **'Select Range'**
  String get selectRange;

  /// No description provided for @from.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get from;

  /// No description provided for @to.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get to;

  /// No description provided for @noPaidRepairs.
  ///
  /// In en, this message translates to:
  /// **'No paid repairs found'**
  String get noPaidRepairs;

  /// No description provided for @noUnpaidRepairs.
  ///
  /// In en, this message translates to:
  /// **'No unpaid repairs found'**
  String get noUnpaidRepairs;

  /// No description provided for @totalCost.
  ///
  /// In en, this message translates to:
  /// **'Total Cost'**
  String get totalCost;

  /// No description provided for @totalSellingPrice.
  ///
  /// In en, this message translates to:
  /// **'Total Selling Price'**
  String get totalSellingPrice;

  /// No description provided for @profit.
  ///
  /// In en, this message translates to:
  /// **'Profit'**
  String get profit;

  /// No description provided for @confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete Repair'**
  String get confirmDelete;

  /// No description provided for @deleteRepairConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this repair? This action cannot be undone.'**
  String get deleteRepairConfirmation;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @repairMarkedAsPaid.
  ///
  /// In en, this message translates to:
  /// **'Repair marked as paid successfully'**
  String get repairMarkedAsPaid;

  /// No description provided for @errorMarkingAsPaid.
  ///
  /// In en, this message translates to:
  /// **'Error marking repair as paid'**
  String get errorMarkingAsPaid;

  /// No description provided for @repairDeleted.
  ///
  /// In en, this message translates to:
  /// **'Repair deleted successfully'**
  String get repairDeleted;

  /// No description provided for @errorDeletingRepair.
  ///
  /// In en, this message translates to:
  /// **'Error deleting repair'**
  String get errorDeletingRepair;

  /// No description provided for @addRepair.
  ///
  /// In en, this message translates to:
  /// **'Add Repair'**
  String get addRepair;

  /// No description provided for @phoneModel.
  ///
  /// In en, this message translates to:
  /// **'Phone Model'**
  String get phoneModel;

  /// No description provided for @phoneModelRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter the phone model'**
  String get phoneModelRequired;

  /// No description provided for @repairDetails.
  ///
  /// In en, this message translates to:
  /// **'Repair Details'**
  String get repairDetails;

  /// No description provided for @repairDetailsRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter repair details'**
  String get repairDetailsRequired;

  /// No description provided for @totalSellingPriceRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter the total selling price'**
  String get totalSellingPriceRequired;

  /// No description provided for @invalidPrice.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid price'**
  String get invalidPrice;

  /// No description provided for @repairUpdated.
  ///
  /// In en, this message translates to:
  /// **'Repair updated successfully'**
  String get repairUpdated;

  /// No description provided for @markAsPaid.
  ///
  /// In en, this message translates to:
  /// **'Mark as Paid'**
  String get markAsPaid;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No Data'**
  String get noData;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @editRepair.
  ///
  /// In en, this message translates to:
  /// **'Edit Repair'**
  String get editRepair;

  /// No description provided for @analytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analytics;

  /// No description provided for @noRepairsFound.
  ///
  /// In en, this message translates to:
  /// **'No repairs found for the selected date range'**
  String get noRepairsFound;

  /// No description provided for @totalRepairs.
  ///
  /// In en, this message translates to:
  /// **'Total Repairs'**
  String get totalRepairs;

  /// No description provided for @totalRevenue.
  ///
  /// In en, this message translates to:
  /// **'Total Revenue'**
  String get totalRevenue;

  /// No description provided for @totalProfit.
  ///
  /// In en, this message translates to:
  /// **'Total Profit'**
  String get totalProfit;

  /// No description provided for @partCost.
  ///
  /// In en, this message translates to:
  /// **'Part Cost'**
  String get partCost;

  /// No description provided for @serviceCost.
  ///
  /// In en, this message translates to:
  /// **'Service Cost'**
  String get serviceCost;

  /// No description provided for @repairParts.
  ///
  /// In en, this message translates to:
  /// **'Repair Parts'**
  String get repairParts;

  /// No description provided for @addPart.
  ///
  /// In en, this message translates to:
  /// **'Add Part'**
  String get addPart;

  /// No description provided for @noParts.
  ///
  /// In en, this message translates to:
  /// **'No parts added yet'**
  String get noParts;

  /// No description provided for @costPrice.
  ///
  /// In en, this message translates to:
  /// **'Cost Price'**
  String get costPrice;

  /// No description provided for @sellingPrice.
  ///
  /// In en, this message translates to:
  /// **'Selling Price'**
  String get sellingPrice;

  /// No description provided for @partName.
  ///
  /// In en, this message translates to:
  /// **'Part Name'**
  String get partName;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @partNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Part name is required'**
  String get partNameRequired;

  /// No description provided for @invalidCostPrice.
  ///
  /// In en, this message translates to:
  /// **'Invalid cost price'**
  String get invalidCostPrice;

  /// No description provided for @invalidSellingPrice.
  ///
  /// In en, this message translates to:
  /// **'Invalid selling price'**
  String get invalidSellingPrice;

  /// No description provided for @part.
  ///
  /// In en, this message translates to:
  /// **'Part'**
  String get part;

  /// No description provided for @parts.
  ///
  /// In en, this message translates to:
  /// **'Parts'**
  String get parts;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'USD'**
  String get currency;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @darkModeDescription.
  ///
  /// In en, this message translates to:
  /// **'Enable dark mode for better visibility in low-light conditions'**
  String get darkModeDescription;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @french.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get french;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabic;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @logoutConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logoutConfirmation;

  /// No description provided for @costPaid.
  ///
  /// In en, this message translates to:
  /// **'Cost Paid'**
  String get costPaid;

  /// No description provided for @costHasBeenPaid.
  ///
  /// In en, this message translates to:
  /// **'Cost has been paid'**
  String get costHasBeenPaid;

  /// No description provided for @costNotPaidYet.
  ///
  /// In en, this message translates to:
  /// **'Cost not paid yet'**
  String get costNotPaidYet;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @presetModels.
  ///
  /// In en, this message translates to:
  /// **'Preset Models'**
  String get presetModels;

  /// No description provided for @customModel.
  ///
  /// In en, this message translates to:
  /// **'Custom Model'**
  String get customModel;

  /// No description provided for @customPhoneModel.
  ///
  /// In en, this message translates to:
  /// **'Custom Phone Model'**
  String get customPhoneModel;

  /// No description provided for @phoneModelExample.
  ///
  /// In en, this message translates to:
  /// **'e.g. Xiaomi Mi 11'**
  String get phoneModelExample;

  /// No description provided for @selectPhoneModel.
  ///
  /// In en, this message translates to:
  /// **'Select Phone Model'**
  String get selectPhoneModel;

  /// No description provided for @describeRepairNeeded.
  ///
  /// In en, this message translates to:
  /// **'Describe the repair needed...'**
  String get describeRepairNeeded;

  /// No description provided for @repairAlreadyPaid.
  ///
  /// In en, this message translates to:
  /// **'This repair is already paid'**
  String get repairAlreadyPaid;

  /// No description provided for @repairNotPaidYet.
  ///
  /// In en, this message translates to:
  /// **'This repair is not paid yet'**
  String get repairNotPaidYet;

  /// No description provided for @costPending.
  ///
  /// In en, this message translates to:
  /// **'Cost Pending'**
  String get costPending;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get thisWeek;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get thisMonth;

  /// No description provided for @customRange.
  ///
  /// In en, this message translates to:
  /// **'Custom Range'**
  String get customRange;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get fieldRequired;

  /// No description provided for @addNewRepair.
  ///
  /// In en, this message translates to:
  /// **'Add New Repair'**
  String get addNewRepair;

  /// No description provided for @addAtLeastOnePart.
  ///
  /// In en, this message translates to:
  /// **'Please add at least one repair part'**
  String get addAtLeastOnePart;

  /// No description provided for @clientName.
  ///
  /// In en, this message translates to:
  /// **'Client Name'**
  String get clientName;

  /// No description provided for @clientPhone.
  ///
  /// In en, this message translates to:
  /// **'Client Phone Number'**
  String get clientPhone;

  /// No description provided for @clientNameOptional.
  ///
  /// In en, this message translates to:
  /// **'Client Name (Optional)'**
  String get clientNameOptional;

  /// No description provided for @clientPhoneOptional.
  ///
  /// In en, this message translates to:
  /// **'Client Phone Number (Optional)'**
  String get clientPhoneOptional;

  /// No description provided for @clientInfo.
  ///
  /// In en, this message translates to:
  /// **'Client Information'**
  String get clientInfo;

  /// No description provided for @searchByClientPhoneModel.
  ///
  /// In en, this message translates to:
  /// **'Search by client, phone, or model...'**
  String get searchByClientPhoneModel;

  /// No description provided for @markAllAsPaid.
  ///
  /// In en, this message translates to:
  /// **'Mark All Paid'**
  String get markAllAsPaid;

  /// No description provided for @confirmMarkAllPaid.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to mark all parts as paid?'**
  String get confirmMarkAllPaid;

  /// No description provided for @partDeleted.
  ///
  /// In en, this message translates to:
  /// **'{partName} deleted'**
  String partDeleted(Object partName);

  /// No description provided for @partsAndPhoneModel.
  ///
  /// In en, this message translates to:
  /// **'{parts} - {phoneModel}'**
  String partsAndPhoneModel(Object parts, Object phoneModel);

  /// No description provided for @errorWithMessage.
  ///
  /// In en, this message translates to:
  /// **'Error: {message}'**
  String errorWithMessage(Object message);

  /// No description provided for @revenue.
  ///
  /// In en, this message translates to:
  /// **'Revenue'**
  String get revenue;

  /// No description provided for @daily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get daily;

  /// No description provided for @profitTrend.
  ///
  /// In en, this message translates to:
  /// **'Profit Trend'**
  String get profitTrend;

  /// No description provided for @loadingAnalyticsData.
  ///
  /// In en, this message translates to:
  /// **'Loading analytics data...'**
  String get loadingAnalyticsData;

  /// No description provided for @errorLoadingData.
  ///
  /// In en, this message translates to:
  /// **'Error loading data'**
  String get errorLoadingData;

  /// No description provided for @noRepairsForSelectedPeriod.
  ///
  /// In en, this message translates to:
  /// **'No repairs found for selected period'**
  String get noRepairsForSelectedPeriod;

  /// No description provided for @noProfitDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No profit data available for the selected period'**
  String get noProfitDataAvailable;

  /// No description provided for @noRepairDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No repair data available for the selected period'**
  String get noRepairDataAvailable;

  /// No description provided for @repairStatus.
  ///
  /// In en, this message translates to:
  /// **'Repair Status'**
  String get repairStatus;

  /// No description provided for @sevenD.
  ///
  /// In en, this message translates to:
  /// **'7D'**
  String get sevenD;

  /// No description provided for @thirtyD.
  ///
  /// In en, this message translates to:
  /// **'30D'**
  String get thirtyD;

  /// No description provided for @ninetyD.
  ///
  /// In en, this message translates to:
  /// **'90D'**
  String get ninetyD;

  /// No description provided for @ytd.
  ///
  /// In en, this message translates to:
  /// **'YTD'**
  String get ytd;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
