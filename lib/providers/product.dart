import 'package:flutter/material.dart';

import '../models/edit_product.dart';
import './cached_transaction_date.dart';
import './products.dart';

class Product with ChangeNotifier {
  final String id;
  final String code;
  final String name;
  final String categoryTitle;
  final List<EditProduct> primaryStockList;
  final List<EditProduct> lorryStockList;
  final Products productsProvider;
  var primaryQty = 0;
  var lorryQty = 0;
  var transactionDate = DateTime.now();
  var isDuplicateOk = false;

  set setCachedTransactionDate(CachedTransactionDate cachedTransactionDate) {
    if (primaryQty == 0 && lorryQty == 0) {
      this.transactionDate = cachedTransactionDate.cachedTransactionDate;
    }
  }

  Product({
    @required this.id,
    @required this.code,
    @required this.name,
    @required this.categoryTitle,
    @required this.primaryStockList,
    @required this.lorryStockList,
    this.productsProvider,
  });

  bool isTransactionDuplicate(DateTime txDate, List<EditProduct> stockList,
      bool isLorryStockList, Transaction transaction) {
    return isLorryStockList
        ? stockList.indexWhere((tx) =>
                transaction == tx.transaction &&
                tx.transactionDate.isAtSameMomentAs(txDate) &&
                tx.modifiedDate
                    .add(Duration(hours: 1))
                    .isBefore(DateTime.now())) !=
            -1
        : stockList.indexWhere((tx) =>
                transaction == tx.transaction &&
                tx.transactionDate.isAtSameMomentAs(txDate)) !=
            -1;
  }

  Future<bool> validateStockQuantities(int qty, DateTime txDate,
      bool isPrimaryStock, bool shouldOverWrite, BuildContext context) async {
    var previousPrimaryQty = primaryQty;
    var previousLorryQty = lorryQty;
    if (shouldOverWrite) {
      if (isPrimaryStock) {
        primaryQty = 0;
      } else {
        lorryQty = 0;
      }
    }
    if (isPrimaryStock) {
      if (primaryQty + qty < 0) {
        var list = this.primaryStockList;
        var minQty = list[list.length - 1].qty;
        for (var i = list.length - 1; i >= 0; i--) {
          if (!list[i].transactionDate.isAfter(txDate)) {
            if (-(primaryQty + qty) <= minQty) {
              if (!isDuplicateOk &&
                  isTransactionDuplicate(
                      txDate, primaryStockList, false, Transaction.loading)) {
                var result = await showDecisionAlertDialog(context);
                if (result == 1) {
                  isDuplicateOk = true;
                  primaryQty += qty;
                  lorryQty = -primaryQty;
                  break;
                } else {
                  return false;
                }
              } else {
                primaryQty += qty;
                lorryQty = -primaryQty;
                break;
              }
            } else {
              showAlertDialog(context);
              return false;
            }
          } else {
            if (i == 0) {
              showAlertDialog(context);
              return false;
            }
            if (list[i - 1].qty < minQty) {
              minQty = list[i - 1].qty;
            }
          }
        }
      } else if (primaryQty + qty == 0) {
        primaryQty += qty;
        lorryQty = 0;
        isDuplicateOk = false;
      } else {
        if (!isDuplicateOk &&
            isTransactionDuplicate(
                txDate, primaryStockList, false, Transaction.grn)) {
          var result = await showDecisionAlertDialog(context);
          if (result == 1) {
            isDuplicateOk = true;
            primaryQty += qty;
            lorryQty = 0;
          } else {
            return false;
          }
        } else {
          primaryQty += qty;
          lorryQty = 0;
        }
      }
    } else {
      if (lorryQty + qty < 0) {
        var list = this.lorryStockList;
        var minQty = list[list.length - 1].qty;
        for (var i = list.length - 1; i >= 0; i--) {
          if (!list[i].transactionDate.isAfter(txDate)) {
            if (-(lorryQty + qty) <= minQty) {
              if (!isDuplicateOk &&
                  isTransactionDuplicate(
                      txDate, lorryStockList, true, Transaction.sales)) {
                var result = await showDecisionAlertDialog(context);
                if (result == 1) {
                  isDuplicateOk = true;
                  lorryQty += qty;
                  primaryQty = 0;
                  break;
                } else {
                  return false;
                }
              } else {
                lorryQty += qty;
                primaryQty = 0;
                break;
              }
            } else {
              showAlertDialog(context);
              return false;
            }
          } else {
            if (i == 0) {
              showAlertDialog(context);
              return false;
            }
            if (list[i - 1].qty < minQty) {
              minQty = list[i - 1].qty;
            }
          }
        }
      } else if (lorryQty + qty == 0) {
        lorryQty += qty;
        primaryQty = 0;
        isDuplicateOk = false;
      } else {
        var list = this.primaryStockList;
        var minQty = list[list.length - 1].qty;
        for (var i = list.length - 1; i >= 0; i--) {
          if (!list[i].transactionDate.isAfter(txDate)) {
            if ((lorryQty + qty) <= minQty) {
              if (!isDuplicateOk &&
                  isTransactionDuplicate(
                      txDate, primaryStockList, false, Transaction.loading)) {
                var result = await showDecisionAlertDialog(context);
                if (result == 1) {
                  isDuplicateOk = true;
                  lorryQty += qty;
                  primaryQty = -lorryQty;
                  break;
                } else {
                  return false;
                }
              } else {
                lorryQty += qty;
                primaryQty = -lorryQty;
                break;
              }
            } else {
              showAlertDialog(context);
              return false;
            }
          } else {
            if (i == 0) {
              showAlertDialog(context);
              return false;
            }
            if (list[i - 1].qty < minQty) {
              minQty = list[i - 1].qty;
            }
          }
        }
      }
    }
    transactionDate = txDate;
    if (primaryQty == 0 ||
        previousPrimaryQty == 0 ||
        lorryQty == 0 ||
        previousLorryQty == 0) {
      productsProvider.notifyProductQuantityChange(
        categoryTitle,
      );
    }

    notifyListeners();
    return true;
  }

  Future<void> showAlertDialog(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Unavailable Stock Alert!!'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                const Text(
                    'Please make sure enough stocks are available to avoid conflicts.'),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<int> showDecisionAlertDialog(BuildContext context) {
    return showDialog<int>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Possible Duplicate Transaction Alert!!'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                const Text(
                    'There is a similar transaction for this product. Do you want to continue with the new transaction?'),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: const Text('Yes'),
              onPressed: () {
                Navigator.of(context).pop(1);
              },
            ),
            FlatButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.of(context).pop(0);
              },
            ),
          ],
        );
      },
    );
  }
}
