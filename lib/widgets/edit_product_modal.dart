import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../models/edit_product.dart';
import '../providers/product.dart';

class EditProductModal extends StatefulWidget {
  final Transaction transaction;
  final int currentSelectedTabIndex;
  final Function saveStockChanges;
  final int index;
  final Function editTransaction;

  const EditProductModal({
    @required this.transaction,
    @required this.currentSelectedTabIndex,
    @required this.saveStockChanges,
    this.index = -1,
    this.editTransaction,
  });

  @override
  _EditProductModalState createState() => _EditProductModalState();
}

class _EditProductModalState extends State<EditProductModal> {
  final _qtyController = TextEditingController();
  DateTime _selectedDate;
  var _isLoading = false;
  var uuid = Uuid();

  Future<void> _submitData(Product product) async {
    final enteredQty = _qtyController.text.trim();

    if (enteredQty.isEmpty) {
      return;
    }
    var qty = int.tryParse(enteredQty);
    if (qty == null || (_selectedDate == null && widget.transaction != null)) {
      return;
    }

    if (qty < 0) {
      if (!(widget.transaction == Transaction.stockAdjustment)) {
        return;
      }
    }

    if (widget.index != -1) {
      var previousQty = (widget.currentSelectedTabIndex == 0
          ? absolute(product.primaryStockList[widget.index].qty -
              product.primaryStockList[widget.index - 1].qty)
          : absolute(product.lorryStockList[widget.index].qty -
              product.lorryStockList[widget.index - 1].qty));
      var currentQty = qty;
      var signTx = (widget.currentSelectedTabIndex == 0
          ? product.primaryStockList[widget.index].qty -
                      product.primaryStockList[widget.index - 1].qty >
                  0
              ? 1
              : -1
          : product.lorryStockList[widget.index].qty -
                      product.lorryStockList[widget.index - 1].qty >
                  0
              ? 1
              : -1);
      qty = (qty - previousQty) * signTx;
      var editStockList = widget.currentSelectedTabIndex == 0
          ? product.primaryStockList
          : product.lorryStockList;
      var nonEditStockList = widget.currentSelectedTabIndex == 1
          ? product.primaryStockList
          : product.lorryStockList;

      for (var i = widget.index; i < editStockList.length; i++) {
        if (qty + editStockList[i].qty < 0) {
          showAlertDialog(false);
          return;
        }
      }

      var passiveIndex = nonEditStockList.indexWhere((tx) =>
          tx.transactionId == editStockList[widget.index].transactionId);
      if (currentQty == 0) {
        editStockList.removeAt(widget.index);
      }
      if (passiveIndex != -1) {
        if (currentQty == 0) {
          nonEditStockList.removeAt(passiveIndex);
        }
        for (var i = passiveIndex; i < nonEditStockList.length; i++) {
          if (-qty + nonEditStockList[i].qty < 0) {
            showAlertDialog(false);
            return;
          }
        }
      }

      for (var i = widget.index; i < editStockList.length; i++) {
        editStockList[i].qty += qty;
      }
      if (passiveIndex != -1) {
        for (var i = passiveIndex; i < nonEditStockList.length; i++) {
          nonEditStockList[i].qty -= qty;
        }
        nonEditStockList[passiveIndex].modifiedDate = DateTime.now();
      }
      editStockList[widget.index].modifiedDate = DateTime.now();

      var editedPrimaryProducts = {product.id: product.primaryStockList};
      var editedLorryProducts = {product.id: product.lorryStockList};
      await widget.editTransaction(editedPrimaryProducts, editedLorryProducts);
      Navigator.of(context).pop();
    } else {
      EditProduct editPrimaryProduct;
      EditProduct editLorryProduct;
      var primaryProductInsertIndex;
      var lorryProductInsertIndex;

      if (widget.transaction == Transaction.unLoading ||
          widget.transaction == Transaction.damagedReturn ||
          (widget.currentSelectedTabIndex == 1 &&
              widget.transaction == Transaction.stockAdjustment &&
              qty < 0)) {
        var adjustedQty = absolute(qty);
        var list = product.lorryStockList;
        var minQty = list[list.length - 1].qty;
        for (var i = list.length - 1; i >= 0; i--) {
          if (!list[i].transactionDate.isAfter(_selectedDate)) {
            if (adjustedQty > minQty) {
              showAlertDialog(false);
              return;
            } else {
              editLorryProduct = EditProduct(
                qty: -adjustedQty,
                transaction: widget.transaction,
                transactionDate: _selectedDate,
                transactionId: uuid.v4(),
              );
              lorryProductInsertIndex = i + 1;
              break;
            }
          } else {
            if (i == 0) {
              showAlertDialog(true);
              return;
            }
            if (list[i - 1].qty < minQty) {
              minQty = list[i - 1].qty;
            }
          }
        }
      } else if (widget.transaction == Transaction.goodReturn ||
          (widget.currentSelectedTabIndex == 1 &&
              widget.transaction == Transaction.stockAdjustment &&
              qty > 0)) {
        editLorryProduct = EditProduct(
          qty: qty,
          transaction: widget.transaction,
          transactionDate: _selectedDate,
          transactionId: uuid.v4(),
        );
        var list = product.lorryStockList;
        for (var i = list.length - 1; i >= 0; i--) {
          if (!list[i].transactionDate.isAfter(_selectedDate)) {
            lorryProductInsertIndex = i + 1;
            break;
          }
        }
      }

      if ((widget.currentSelectedTabIndex == 0 &&
          widget.transaction == Transaction.stockAdjustment &&
          qty < 0)) {
        var adjustedQty = absolute(qty);
        var list = product.primaryStockList;
        var minQty = list[list.length - 1].qty;
        for (var i = list.length - 1; i >= 0; i--) {
          if (!list[i].transactionDate.isAfter(_selectedDate)) {
            if (adjustedQty > minQty) {
              showAlertDialog(false);
              return;
            } else {
              editPrimaryProduct = EditProduct(
                qty: qty,
                transaction: widget.transaction,
                transactionDate: _selectedDate,
                transactionId: uuid.v4(),
              );
              primaryProductInsertIndex = i + 1;
              break;
            }
          } else {
            if (i == 0) {
              showAlertDialog(true);
              return;
            }
            if (list[i - 1].qty < minQty) {
              minQty = list[i - 1].qty;
            }
          }
        }
      } else if (widget.transaction == Transaction.unLoading ||
          (widget.currentSelectedTabIndex == 0 &&
              widget.transaction == Transaction.stockAdjustment &&
              qty > 0)) {
        editPrimaryProduct = EditProduct(
          qty: qty,
          transaction: widget.transaction,
          transactionDate: _selectedDate,
          transactionId: widget.transaction == Transaction.unLoading
              ? editLorryProduct.transactionId
              : uuid.v4(),
        );
        var list = product.primaryStockList;
        for (var i = list.length - 1; i >= 0; i--) {
          if (!list[i].transactionDate.isAfter(_selectedDate)) {
            primaryProductInsertIndex = i + 1;
            break;
          }
        }
      }

      if (primaryProductInsertIndex == null &&
          lorryProductInsertIndex == null) {
        showAlertDialog(true);
      }
      await widget.saveStockChanges(product, editPrimaryProduct,
          editLorryProduct, primaryProductInsertIndex, lorryProductInsertIndex);
      Navigator.of(context).pop();
    }
  }

  Future<void> showAlertDialog(bool isInvalidTransactionDate) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Unavailable Stock Alert!!'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(isInvalidTransactionDate
                    ? 'Each stock operation is possible only after Stock Take'
                    : 'Please make sure enough stocks are available to avoid conflicts.'),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _presentDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    ).then((selectedDate) {
      if (selectedDate == null) {
        return;
      }
      setState(() {
        _selectedDate = selectedDate;
      });
    });
  }

  double max(double a, double b) {
    if (a > b) {
      return a;
    }
    return b;
  }

  int absolute(int value) {
    if (value < 0) {
      return -value;
    }
    return value;
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? null
        : Consumer<Product>(
            builder: (context, product, child) => Card(
              child: Container(
                height:
                    200 + max(MediaQuery.of(context).viewInsets.bottom - 30, 0),
                color: Color.fromARGB(50, 186, 35, 35),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        decoration: const InputDecoration(labelText: 'Qty'),
                        controller: _qtyController,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    if (getTransactionString(widget.transaction) != null)
                      Container(
                        height: 70,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                                '${getTransactionString(widget.transaction)} Date'),
                            FlatButton(
                              textColor: Theme.of(context).primaryColor,
                              child: Text(
                                _selectedDate == null
                                    ? 'Choose Date!'
                                    : '${DateFormat.yMd().format(_selectedDate)}',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              onPressed: _presentDatePicker,
                            ),
                            RaisedButton(
                              onPressed: () => _submitData(product),
                              child: const Text('Save'),
                              color: Theme.of(context).primaryColor,
                              textColor:
                                  Theme.of(context).textTheme.button.color,
                            )
                          ],
                        ),
                      ),
                    if (getTransactionString(widget.transaction) == null)
                      RaisedButton(
                        onPressed: () => _submitData(product),
                        child: const Text('Save'),
                        color: Theme.of(context).primaryColor,
                        textColor: Theme.of(context).textTheme.button.color,
                      )
                  ],
                ),
              ),
            ),
          );
  }

  String getTransactionString(Transaction transaction) {
    switch (transaction) {
      case Transaction.stockTake:
        return 'Stock Take';
      case Transaction.grn:
        return 'GRN';
      case Transaction.loading:
        return 'Loading';
      case Transaction.sales:
        return 'Sales';
      case Transaction.stockAdjustment:
        return 'Stock Adjust';
      case Transaction.unLoading:
        return 'Unloading';
      case Transaction.goodReturn:
        return 'Good Return';
      case Transaction.damagedReturn:
        return 'Damaged Return';
    }
    return null;
  }
}
