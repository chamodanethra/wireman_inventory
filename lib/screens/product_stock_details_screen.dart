import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/product.dart';
import '../models/edit_product.dart';
import '../widgets/row_entry.dart';
import '../providers/products.dart';
import '../widgets/edit_product_modal.dart';

class ProductStockDetailsScreen extends StatefulWidget {
  final int currentSelectedTabIndex;

  const ProductStockDetailsScreen({
    @required this.currentSelectedTabIndex,
  });

  @override
  _ProductStockDetailsScreenState createState() =>
      _ProductStockDetailsScreenState();
}

class _ProductStockDetailsScreenState extends State<ProductStockDetailsScreen> {
  var _isLoading = false;
  var _currentSelectedTabIndex;

  @override
  void initState() {
    _currentSelectedTabIndex = widget.currentSelectedTabIndex;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Product>(
      builder: (ctx, product, _) => DefaultTabController(
        initialIndex: _currentSelectedTabIndex,
        length: 2,
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            leading: new IconButton(
                icon: new Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context, _currentSelectedTabIndex);
                }),
            title: Text(product.code),
            centerTitle: true,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(44),
              child: TabBar(
                onTap: (value) {
                  setState(() {
                    _currentSelectedTabIndex = value;
                  });
                },
                unselectedLabelColor: Colors.white,
                labelColor: Theme.of(context).accentColor,
                tabs: <Widget>[
                  const Tab(
                    icon: Icon(Icons.home),
                    text: 'Primary',
                  ),
                  const Tab(
                    icon: Icon(Icons.business_center),
                    text: 'Lorry',
                  ),
                ],
              ),
            ),
          ),
          body: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : TabBarView(
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    ListView.builder(
                      itemBuilder: (context, index) => RowEntry(
                        key: ValueKey(index),
                        index: index,
                        transaction:
                            product.primaryStockList[index].transaction,
                        transactionDate:
                            product.primaryStockList[index].transactionDate,
                        modifiedDate:
                            product.primaryStockList[index].modifiedDate,
                        qty: absolute(product.primaryStockList[index].qty -
                            (index == 0
                                ? 0
                                : product.primaryStockList[index - 1].qty)),
                        balanceQty: product.primaryStockList[index].qty,
                        currentSelectedTabIndex: _currentSelectedTabIndex,
                        didLongPress: didLongPress,
                      ),
                      itemCount: product.primaryStockList.length,
                      physics: const AlwaysScrollableScrollPhysics(),
                      shrinkWrap: true,
                    ),
                    ListView.builder(
                      itemBuilder: (context, index) => RowEntry(
                        key: ValueKey(index),
                        index: index,
                        transaction: product.lorryStockList[index].transaction,
                        transactionDate:
                            product.lorryStockList[index].transactionDate,
                        modifiedDate:
                            product.lorryStockList[index].modifiedDate,
                        qty: absolute(product.lorryStockList[index].qty -
                            (index == 0
                                ? 0
                                : product.lorryStockList[index - 1].qty)),
                        balanceQty: product.lorryStockList[index].qty,
                        currentSelectedTabIndex: _currentSelectedTabIndex,
                        didLongPress: didLongPress,
                      ),
                      itemCount: product.lorryStockList.length,
                      physics: const AlwaysScrollableScrollPhysics(),
                      shrinkWrap: true,
                    )
                  ],
                ),
          floatingActionButtonLocation:
              _isLoading ? null : FloatingActionButtonLocation.centerFloat,
          floatingActionButton: _isLoading
              ? null
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: _currentSelectedTabIndex == 0
                      ? [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: FloatingActionButton(
                              heroTag: "btn1",
                              child: Icon(Icons.adjust),
                              onPressed: () {
                                showModalBottomSheet(
                                  isScrollControlled: true,
                                  context: context,
                                  builder: (_) {
                                    return ChangeNotifierProvider.value(
                                      value: product,
                                      child: EditProductModal(
                                        currentSelectedTabIndex:
                                            _currentSelectedTabIndex,
                                        transaction:
                                            Transaction.stockAdjustment,
                                        saveStockChanges: _saveStockChanges,
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: FloatingActionButton(
                              heroTag: "btn2",
                              child: Icon(Icons.undo),
                              onPressed: () {
                                showModalBottomSheet(
                                  isScrollControlled: true,
                                  context: context,
                                  builder: (_) {
                                    return ChangeNotifierProvider.value(
                                      value: product,
                                      child: EditProductModal(
                                        currentSelectedTabIndex:
                                            _currentSelectedTabIndex,
                                        transaction: Transaction.unLoading,
                                        saveStockChanges: _saveStockChanges,
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ]
                      : [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: FloatingActionButton(
                              heroTag: "btn3",
                              child: Icon(Icons.adjust),
                              onPressed: () {
                                showModalBottomSheet(
                                  isScrollControlled: true,
                                  context: context,
                                  builder: (_) {
                                    return ChangeNotifierProvider.value(
                                      value: product,
                                      child: EditProductModal(
                                        currentSelectedTabIndex:
                                            _currentSelectedTabIndex,
                                        transaction:
                                            Transaction.stockAdjustment,
                                        saveStockChanges: _saveStockChanges,
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: FloatingActionButton(
                              heroTag: "btn4",
                              child: Icon(
                                Icons.assignment_return,
                                color: Colors.green,
                              ),
                              onPressed: () {
                                showModalBottomSheet(
                                  isScrollControlled: true,
                                  context: context,
                                  builder: (_) {
                                    return ChangeNotifierProvider.value(
                                      value: product,
                                      child: EditProductModal(
                                        currentSelectedTabIndex:
                                            _currentSelectedTabIndex,
                                        transaction: Transaction.goodReturn,
                                        saveStockChanges: _saveStockChanges,
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: FloatingActionButton(
                              heroTag: "btn5",
                              child: Icon(
                                Icons.assignment_return,
                                color: Colors.red,
                              ),
                              onPressed: () {
                                showModalBottomSheet(
                                  isScrollControlled: true,
                                  context: context,
                                  builder: (_) {
                                    return ChangeNotifierProvider.value(
                                      value: product,
                                      child: EditProductModal(
                                        currentSelectedTabIndex:
                                            _currentSelectedTabIndex,
                                        transaction: Transaction.damagedReturn,
                                        saveStockChanges: _saveStockChanges,
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                ),
        ),
      ),
    );
  }

  Future<void> _saveStockChanges(
      Product product,
      EditProduct editPrimaryProduct,
      EditProduct editLorryProduct,
      primaryProductInsertIndex,
      lorryProductInsertIndex) async {
    setState(() {
      _isLoading = true;
    });
    Map<String, List<EditProduct>> editedPrimaryProducts = Map();
    Map<String, List<EditProduct>> editedLorryProducts = Map();
    if (editPrimaryProduct != null && editPrimaryProduct.qty != 0) {
      product.primaryStockList.forEach((e) {
        if (e.transactionDate.isAfter(editPrimaryProduct.transactionDate)) {
          e.qty += editPrimaryProduct.qty;
        }
      });

      EditProduct editedPrimaryStock = EditProduct(
        qty: editPrimaryProduct.qty +
            product.primaryStockList
                .lastWhere((e) => !e.transactionDate
                    .isAfter(editPrimaryProduct.transactionDate))
                .qty,
        transactionDate: editPrimaryProduct.transactionDate,
        transaction: editPrimaryProduct.transaction,
        transactionId: editPrimaryProduct.transactionId,
        modifiedDate: DateTime.now(),
      );

      product.primaryStockList.add(editedPrimaryStock);
      product.primaryStockList.sort((a, b) {
        var cmp = a.transactionDate.compareTo(b.transactionDate);
        return (cmp != 0 ? cmp : a.modifiedDate.compareTo(b.modifiedDate));
      });
      editedPrimaryProducts['${product.id}'] = product.primaryStockList;
    }
    if (editLorryProduct != null && editLorryProduct.qty != 0) {
      product.lorryStockList.forEach((e) {
        if (e.transactionDate.isAfter(editLorryProduct.transactionDate)) {
          e.qty += editLorryProduct.qty;
        }
      });
      EditProduct editedLorryStock = EditProduct(
        qty: editLorryProduct.qty +
            product.lorryStockList
                .lastWhere((e) => !e.transactionDate
                    .isAfter(editLorryProduct.transactionDate))
                .qty,
        transactionDate: editLorryProduct.transactionDate,
        transaction: editLorryProduct.transaction,
        transactionId: editLorryProduct.transactionId,
        modifiedDate: DateTime.now(),
      );
      product.lorryStockList.add(editedLorryStock);
      product.lorryStockList.sort((a, b) {
        var cmp = a.transactionDate.compareTo(b.transactionDate);
        return (cmp != 0 ? cmp : a.modifiedDate.compareTo(b.modifiedDate));
      });
      editedLorryProducts['${product.id}'] = product.lorryStockList;
    }
    await Provider.of<Products>(context, listen: false)
        .saveStockChanges(editedPrimaryProducts, editedLorryProducts);

    setState(() {
      _isLoading = false;
    });
  }

  double min(double a, double b) {
    if (a < b) {
      return a;
    }
    return b;
  }

  double max(double a, double b) {
    if (a > b) {
      return a;
    }
    return b;
  }

  int absolute(int value) {
    if (value >= 0) {
      return value;
    }
    return -value;
  }

  @override
  void dispose() {
    super.dispose();
  }

  didLongPress(int index, Product product) async {
    return showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (_) {
        return ChangeNotifierProvider.value(
          value: product,
          child: EditProductModal(
            currentSelectedTabIndex: _currentSelectedTabIndex,
            transaction: null,
            saveStockChanges: null,
            index: index,
            editTransaction: editTransaction,
          ),
        );
      },
    );
  }

  editTransaction(Map<String, List<EditProduct>> editedPrimaryProducts,
      Map<String, List<EditProduct>> editedLorryProducts) async {
    setState(() {
      _isLoading = true;
    });
    await Provider.of<Products>(context, listen: false)
        .saveStockChanges(editedPrimaryProducts, editedLorryProducts);

    setState(() {
      _isLoading = false;
    });
  }
}
