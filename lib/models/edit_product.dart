import 'package:flutter/material.dart';

class EditProduct with ChangeNotifier {
  int qty;
  DateTime transactionDate;
  Transaction transaction;
  String transactionId;
  DateTime modifiedDate;

  EditProduct({
    @required this.qty,
    @required this.transactionDate,
    @required this.transaction,
    @required this.transactionId,
    this.modifiedDate,
  });
}

enum Transaction {
  stockTake,
  grn,
  loading,
  sales,
  stockAdjustment,
  unLoading,
  goodReturn,
  damagedReturn,
}
