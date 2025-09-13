import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../presentation/providers/settings_providers.dart';

/// Currency formatter utility class
class CurrencyFormatter {
  /// Format a price value with the selected currency symbol
  static String formatPrice(double price, String currency) {
    switch (currency) {
      case 'USD':
        return '\$${price.toStringAsFixed(2)}';
      case 'EUR':
        return '€${price.toStringAsFixed(2)}';
      case 'GBP':
        return '£${price.toStringAsFixed(2)}';
      case 'JPY':
        return '¥${price.toStringAsFixed(0)}'; // JPY typically doesn't use decimal places
      case 'CAD':
        return 'C\$${price.toStringAsFixed(2)}';
      case 'AUD':
        return 'A\$${price.toStringAsFixed(2)}';
      case 'CHF':
        return 'CHF ${price.toStringAsFixed(2)}';
      case 'CNY':
        return '¥${price.toStringAsFixed(2)}';
      case 'INR':
        return '₹${price.toStringAsFixed(2)}';
      case 'BRL':
        return 'R\$${price.toStringAsFixed(2)}';
      case 'MXN':
        return 'MX\$${price.toStringAsFixed(2)}';
      case 'KRW':
        return '₩${price.toStringAsFixed(0)}'; // KRW typically doesn't use decimal places
      case 'SGD':
        return 'S\$${price.toStringAsFixed(2)}';
      case 'HKD':
        return 'HK\$${price.toStringAsFixed(2)}';
      case 'NZD':
        return 'NZ\$${price.toStringAsFixed(2)}';
      case 'SEK':
        return '${price.toStringAsFixed(2)} kr';
      case 'NOK':
        return '${price.toStringAsFixed(2)} kr';
      case 'DKK':
        return '${price.toStringAsFixed(2)} kr';
      case 'PLN':
        return '${price.toStringAsFixed(2)} zł';
      case 'CZK':
        return '${price.toStringAsFixed(2)} Kč';
      case 'HUF':
        return '${price.toStringAsFixed(2)} Ft';
      case 'RUB':
        return '${price.toStringAsFixed(2)} ₽';
      case 'ZAR':
        return 'R ${price.toStringAsFixed(2)}';
      case 'TRY':
        return '₺${price.toStringAsFixed(2)}';
      case 'ILS':
        return '₪${price.toStringAsFixed(2)}';
      case 'AED':
        return '${price.toStringAsFixed(2)} د.إ';
      case 'SAR':
        return '${price.toStringAsFixed(2)} ر.س';
      case 'THB':
        return '฿${price.toStringAsFixed(2)}';
      case 'MYR':
        return 'RM ${price.toStringAsFixed(2)}';
      case 'PHP':
        return '₱${price.toStringAsFixed(2)}';
      case 'IDR':
        return 'Rp ${price.toStringAsFixed(0)}'; // IDR typically doesn't use decimal places
      case 'VND':
        return '₫${price.toStringAsFixed(0)}'; // VND typically doesn't use decimal places
      default:
        return '$currency ${price.toStringAsFixed(2)}';
    }
  }

  /// Get currency symbol only
  static String getCurrencySymbol(String currency) {
    switch (currency) {
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'JPY':
        return '¥';
      case 'CAD':
        return 'C\$';
      case 'AUD':
        return 'A\$';
      case 'CHF':
        return 'CHF';
      case 'CNY':
        return '¥';
      case 'INR':
        return '₹';
      case 'BRL':
        return 'R\$';
      case 'MXN':
        return 'MX\$';
      case 'KRW':
        return '₩';
      case 'SGD':
        return 'S\$';
      case 'HKD':
        return 'HK\$';
      case 'NZD':
        return 'NZ\$';
      case 'SEK':
        return 'kr';
      case 'NOK':
        return 'kr';
      case 'DKK':
        return 'kr';
      case 'PLN':
        return 'zł';
      case 'CZK':
        return 'Kč';
      case 'HUF':
        return 'Ft';
      case 'RUB':
        return '₽';
      case 'ZAR':
        return 'R';
      case 'TRY':
        return '₺';
      case 'ILS':
        return '₪';
      case 'AED':
        return 'د.إ';
      case 'SAR':
        return 'ر.س';
      case 'THB':
        return '฿';
      case 'MYR':
        return 'RM';
      case 'PHP':
        return '₱';
      case 'IDR':
        return 'Rp';
      case 'VND':
        return '₫';
      default:
        return currency;
    }
  }

  /// Get list of supported currencies
  static List<Map<String, String>> getSupportedCurrencies() {
    return [
      {'code': 'USD', 'name': 'US Dollar', 'symbol': '\$'},
      {'code': 'EUR', 'name': 'Euro', 'symbol': '€'},
      {'code': 'GBP', 'name': 'British Pound', 'symbol': '£'},
      {'code': 'JPY', 'name': 'Japanese Yen', 'symbol': '¥'},
      {'code': 'CAD', 'name': 'Canadian Dollar', 'symbol': 'C\$'},
      {'code': 'AUD', 'name': 'Australian Dollar', 'symbol': 'A\$'},
      {'code': 'CHF', 'name': 'Swiss Franc', 'symbol': 'CHF'},
      {'code': 'CNY', 'name': 'Chinese Yuan', 'symbol': '¥'},
      {'code': 'INR', 'name': 'Indian Rupee', 'symbol': '₹'},
      {'code': 'BRL', 'name': 'Brazilian Real', 'symbol': 'R\$'},
      {'code': 'MXN', 'name': 'Mexican Peso', 'symbol': 'MX\$'},
      {'code': 'KRW', 'name': 'South Korean Won', 'symbol': '₩'},
      {'code': 'SGD', 'name': 'Singapore Dollar', 'symbol': 'S\$'},
      {'code': 'HKD', 'name': 'Hong Kong Dollar', 'symbol': 'HK\$'},
      {'code': 'NZD', 'name': 'New Zealand Dollar', 'symbol': 'NZ\$'},
      {'code': 'SEK', 'name': 'Swedish Krona', 'symbol': 'kr'},
      {'code': 'NOK', 'name': 'Norwegian Krone', 'symbol': 'kr'},
      {'code': 'DKK', 'name': 'Danish Krone', 'symbol': 'kr'},
      {'code': 'PLN', 'name': 'Polish Złoty', 'symbol': 'zł'},
      {'code': 'CZK', 'name': 'Czech Koruna', 'symbol': 'Kč'},
      {'code': 'HUF', 'name': 'Hungarian Forint', 'symbol': 'Ft'},
      {'code': 'RUB', 'name': 'Russian Ruble', 'symbol': '₽'},
      {'code': 'ZAR', 'name': 'South African Rand', 'symbol': 'R'},
      {'code': 'TRY', 'name': 'Turkish Lira', 'symbol': '₺'},
      {'code': 'ILS', 'name': 'Israeli Shekel', 'symbol': '₪'},
      {'code': 'AED', 'name': 'UAE Dirham', 'symbol': 'د.إ'},
      {'code': 'SAR', 'name': 'Saudi Riyal', 'symbol': 'ر.س'},
      {'code': 'THB', 'name': 'Thai Baht', 'symbol': '฿'},
      {'code': 'MYR', 'name': 'Malaysian Ringgit', 'symbol': 'RM'},
      {'code': 'PHP', 'name': 'Philippine Peso', 'symbol': '₱'},
      {'code': 'IDR', 'name': 'Indonesian Rupiah', 'symbol': 'Rp'},
      {'code': 'VND', 'name': 'Vietnamese Dong', 'symbol': '₫'},
    ];
  }
}

/// Provider for currency formatter
final currencyFormatterProvider = Provider<CurrencyFormatter>((ref) {
  return CurrencyFormatter();
});

/// Provider for formatted price that uses current currency setting
final formattedPriceProvider = Provider.family<String, double>((ref, price) {
  final currency = ref.watch(currencyProvider);
  return CurrencyFormatter.formatPrice(price, currency);
});
