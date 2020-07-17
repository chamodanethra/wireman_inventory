import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../screens/product_stock_details_screen.dart';
import '../providers/product.dart';
import '../providers/cached_transaction_date.dart';

class ProductItem extends StatelessWidget {
  final Key key;
  final int index;
  final bool isLongPressed;
  final Function didLongPress;
  final int currentSelectedTabIndex;
  final Function setCurrentSelectedTabIndex;

  ProductItem({
    @required this.key,
    @required this.index,
    @required this.isLongPressed,
    @required this.didLongPress,
    @required this.currentSelectedTabIndex,
    @required this.setCurrentSelectedTabIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var product = Provider.of<Product>(context);
    var stockList = currentSelectedTabIndex == 0
        ? product.primaryStockList
        : product.lorryStockList;
    var adjustedQty =
        currentSelectedTabIndex == 0 ? product.primaryQty : product.lorryQty;
    if (product.primaryQty == 0 && product.lorryQty == 0) {
      product.setCachedTransactionDate =
          Provider.of<CachedTransactionDate>(context);
    }
    var originalBalanceQty = stockList
        .lastWhere((tx) => !tx.transactionDate.isAfter(product.transactionDate))
        .qty;

    return GestureDetector(
      onLongPressStart: (LongPressStartDetails details) =>
          product.primaryQty == 0 && product.lorryQty == 0
              ? Navigator.of(context)
                  .push(
                  MaterialPageRoute(
                    builder: (context) => ChangeNotifierProvider.value(
                      value: product,
                      child: ProductStockDetailsScreen(
                        currentSelectedTabIndex: currentSelectedTabIndex,
                      ),
                    ),
                  ),
                )
                  .then((index) {
                  setCurrentSelectedTabIndex(index);
                })
              : showDialog<void>(
                  context: context,
                  barrierDismissible: false, // user must tap button!
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Unavailable Operation Alert!!'),
                      content: SingleChildScrollView(
                        child: ListBody(
                          children: <Widget>[
                            const Text(
                                'Please save or clear the changes for this product to view its history.'),
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
                ),
      child: Card(
        color: isLongPressed ? Theme.of(context).primaryColor : null,
        elevation: 5,
        margin: const EdgeInsets.symmetric(
          vertical: 8,
          horizontal: 0,
        ),
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(3),
          child: SizedBox(
            height: 70,
            child: ListTile(
              leading: Stack(
                children: [
                  CircleAvatar(
                    radius: 30,
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          (originalBalanceQty + adjustedQty).toString(),
                        ),
                      ),
                    ),
                  ),
                  if ((currentSelectedTabIndex == 0 && product.lorryQty < 0) ||
                      (currentSelectedTabIndex == 1 && product.primaryQty > 0))
                    Positioned(
                      left: 0,
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 10,
                          minHeight: 10,
                        ),
                      ),
                    ),
                ],
              ),
              title: Stack(
                children: [
                  Text(product.code),
                ],
              ),
              subtitle: FittedBox(
                child: adjustedQty == 0
                    ? Text(product.name)
                    : Text(
                        DateFormat.yMd()
                            .format(product.transactionDate)
                            .padRight(product.name.length),
                        style: TextStyle(
                            color: Theme.of(context).accentColor,
                            fontWeight: FontWeight.bold),
                      ),
                fit: BoxFit.scaleDown,
              ),
              trailing: Container(
                width: 140,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    if (adjustedQty != 0)
                      Container(
                        width: 35,
                        margin: const EdgeInsets.only(right: 5),
                        decoration: BoxDecoration(
                            color: adjustedQty > 0
                                ? Colors.green[200]
                                : Colors.red[200],
                            border: Border.all(
                                color: Theme.of(context).accentColor)),
                        child: Text(
                          adjustedQty.toString(),
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    Row(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(5),
                          child: GestureDetector(
                            child: const CircleAvatar(
                              radius: 20,
                              child: Icon(Icons.add),
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                            onTap: () {
                              product.validateStockQuantities(
                                  1,
                                  product.transactionDate,
                                  currentSelectedTabIndex == 0,
                                  false,
                                  context);
                            },
                            onDoubleTap: () {
                              product.validateStockQuantities(
                                  10,
                                  product.transactionDate,
                                  currentSelectedTabIndex == 0,
                                  false,
                                  context);
                            },
                            onLongPressStart: (LongPressStartDetails details) =>
                                didLongPress(
                              index,
                              details.globalPosition.dy,
                              details.localPosition.dy,
                              true,
                              currentSelectedTabIndex,
                              product,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(5),
                          child: GestureDetector(
                            child: const CircleAvatar(
                              radius: 20,
                              child: Icon(Icons.remove),
                              backgroundColor: Colors.redAccent,
                            ),
                            onTap: () {
                              product.validateStockQuantities(
                                  -1,
                                  product.transactionDate,
                                  currentSelectedTabIndex == 0,
                                  false,
                                  context);
                            },
                            onDoubleTap: () {
                              product.validateStockQuantities(
                                  -10,
                                  product.transactionDate,
                                  currentSelectedTabIndex == 0,
                                  false,
                                  context);
                            },
                            onLongPressStart: (LongPressStartDetails details) =>
                                didLongPress(
                              index,
                              details.globalPosition.dy,
                              details.localPosition.dy,
                              false,
                              currentSelectedTabIndex,
                              product,
                            ),
                          ),
                        ),
                      ],
                    )
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
