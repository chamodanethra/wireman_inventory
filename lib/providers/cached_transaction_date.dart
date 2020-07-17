import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CachedTransactionDate with ChangeNotifier {
  DateTime _cachedTransactionDate =
      DateTime.parse(DateFormat('yyyy-MM-dd').format(DateTime.now()));
  DateTime _cachedBalanceOnDate =
      DateTime.parse(DateFormat('yyyy-MM-dd').format(DateTime.now()));

  void setCachedTransactionDate(DateTime date) {
    _cachedTransactionDate = date;
    notifyListeners();
  }

  void setCachedBalanceOnDate(DateTime date) {
    _cachedBalanceOnDate = date;
    notifyListeners();
  }

  DateTime get cachedTransactionDate {
    return _cachedTransactionDate;
  }

  DateTime get cachedBalanceOnDate {
    return _cachedBalanceOnDate;
  }
}
