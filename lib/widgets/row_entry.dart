import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/edit_product.dart';
import '../providers/product.dart';

class RowEntry extends StatelessWidget {
  final Key key;
  final int index;
  final Transaction transaction;
  final DateTime transactionDate;
  final DateTime modifiedDate;
  final int qty;
  final int balanceQty;
  final int currentSelectedTabIndex;
  final Function didLongPress;

  RowEntry({
    @required this.key,
    @required this.index,
    @required this.transactionDate,
    @required this.modifiedDate,
    @required this.transaction,
    @required this.qty,
    @required this.balanceQty,
    @required this.currentSelectedTabIndex,
    @required this.didLongPress,
  }) : super(key: key);

  // Future<void> primaryStockUnavailable() {
  //   return showDialog<void>(
  //     context: context,
  //     barrierDismissible: false, // user must tap button!
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Text('Unavailable Stock Alert!!'),
  //         content: SingleChildScrollView(
  //           child: ListBody(
  //             children: <Widget>[
  //               Text(
  //                   'Please make sure enough stocks are available in the Primary Stock.'),
  //             ],
  //           ),
  //         ),
  //         actions: <Widget>[
  //           FlatButton(
  //             child: const Text('OK'),
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Consumer<Product>(
      builder: (context, product, child) => GestureDetector(
        onLongPressStart: (LongPressStartDetails details) {
          if (index > 0) {
            didLongPress(index, product);
          }
        },
        child: Card(
          elevation: 5,
          margin: const EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 5,
          ),
          child: SizedBox(
            height: 76,
            child: Container(
              decoration: BoxDecoration(),
              alignment: Alignment.center,
              child: ListTile(
                leading: index == 0
                    ? SizedBox(
                        height: 60,
                        width: 60,
                      )
                    : CircleAvatar(
                        radius: 30,
                        child: Padding(
                          padding: const EdgeInsets.all(5),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              qty.toString(),
                            ),
                          ),
                        ),
                      ),
                title: index == 0
                    ? const Text('Initial balance')
                    : Text(getTransactionString(transaction)),
                subtitle: FittedBox(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('on ' +
                          DateFormat('yyyy-MM-dd').format(transactionDate)),
                      Text('at ' +
                          DateFormat('yyyy-MM-dd – kk:mm:ss')
                              .format(modifiedDate)),
                    ],
                  ),
                  fit: BoxFit.scaleDown,
                ),
                trailing: Padding(
                  padding: const EdgeInsets.all(5),
                  child: CircleAvatar(
                    radius: 30,
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(balanceQty.toString()),
                      ),
                    ),
                  ),
                ),
              ),
            ),
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
