import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../providers/products.dart';
import '../widgets/new_transaction.dart';
import '../widgets/product_item.dart';
import '../models/edit_product.dart';
import '../providers/product.dart';
import '../widgets/new_product.dart';
import '../providers/cached_transaction_date.dart';

class ProductsScreen extends StatefulWidget {
  final String title;

  ProductsScreen({
    @required this.title,
  });

  @override
  _ProductsScreenState createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen>
    with TickerProviderStateMixin {
  AnimationController animationController;
  int longPressedIndex = -1;
  double displayHeight;
  Animation<Offset> slideAnimation;
  Tween<Offset> slideTween;
  int saveCounter;
  var _isLoading = false;
  var uuid = Uuid();
  var slidePosition = 0.0;
  var currentSelectedTabIndex = 1;
  TabController _tabController;

  @override
  void initState() {
    animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      reverseDuration: const Duration(milliseconds: 200),
      vsync: this,
    );
    slideTween = Tween<Offset>(begin: Offset.zero, end: Offset.zero);
    slideAnimation = slideTween.animate(CurvedAnimation(
      parent: animationController,
      curve: Curves.easeIn,
    ));
    animationController.forward();

    _tabController = TabController(
        vsync: this, length: 2, initialIndex: currentSelectedTabIndex);
    super.initState();
  }

  void setCurrentSelectedTabIndex(int index) {
    setState(() {
      currentSelectedTabIndex = index;
    });
    _tabController.animateTo(index);
  }

  void didLongPress(int index, double dyGlobal, double dyLocal,
      bool isIncreasing, int currentSelectedTabIndex, Product product) async {
    if (dyGlobal + 66 - 8 - dyLocal > displayHeight) {
      return;
    }
    setState(() {
      longPressedIndex = index;
      animationController = AnimationController(
        duration: const Duration(milliseconds: 400),
        reverseDuration: const Duration(milliseconds: 200),
        vsync: this,
      );
      slideTween = Tween<Offset>(
          begin: Offset.zero,
          end: Offset(
              0,
              min(
                  ((-310 +
                          32.4 +
                          (displayHeight - dyGlobal - 66 + 8 + dyLocal)) /
                      (displayHeight -
                          132.4)), //100 = appBarHeight 32.4 = safe area
                  0)));
      slideAnimation = slideTween.animate(CurvedAnimation(
        parent: animationController,
        curve: Curves.easeIn,
      ));
      slidePosition = min(-310, -(displayHeight - dyGlobal - 66 + 8 + dyLocal));
    });
    animationController.forward();
    await showDialog(
      context: context,
      builder: (_) {
        return NewTransaction(
          isIncreasing,
          animationController,
          displayHeight,
          currentSelectedTabIndex,
          product,
        );
      },
    ).then((value) {
      setState(() {
        longPressedIndex = -1;
      });
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

  void _presentDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(Duration(days: 60)),
      lastDate: DateTime.now(),
    ).then((selectedDate) {
      if (selectedDate != null) {
        Provider.of<CachedTransactionDate>(context, listen: false)
            .setCachedTransactionDate(selectedDate);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    displayHeight ??= MediaQuery.of(context)?.size?.height;
    final products =
        Provider.of<Products>(context).productsFromCategory(widget.title);
    saveCounter = products
        .where((e) => e.primaryQty != 0 || e.lorryQty != 0)
        .toList()
        .length;
    final selectedDate =
        Provider.of<CachedTransactionDate>(context).cachedTransactionDate;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        // leading: new IconButton(
        //     icon: new Icon(Icons.arrow_back),
        //     onPressed: () {
        //       Navigator.pop(context, saveCounter);
        //     }),
        title: Text(widget.title),
        centerTitle: true,
        actions: <Widget>[
          FlatButton.icon(
              onPressed: _presentDatePicker,
              icon: Icon(Icons.calendar_today),
              label: Text(DateFormat.Md().format(selectedDate)))
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(44),
          child: TabBar(
            controller: _tabController,
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
              child: const CircularProgressIndicator(),
            )
          : Container(
              transform: Matrix4.translationValues(
                0.0,
                longPressedIndex != -1 &&
                        animationController.status ==
                            AnimationStatus.completed &&
                        MediaQuery.of(context).viewInsets.bottom != 0.0
                    ? min(
                        -(MediaQuery.of(context).viewInsets.bottom +
                                110 +
                                30) - // remove 30
                            (slidePosition == -310
                                ? -310 + 32.4
                                : slidePosition),
                        0)
                    : 0,
                0.0,
              ),
              child: SlideTransition(
                position: slideAnimation,
                child: TabBarView(
                  controller: _tabController,
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    Container(
                      // height: displayHeight,
                      child: ListView.builder(
                        itemBuilder: (context, index) =>
                            ChangeNotifierProvider<Product>.value(
                          value: products[index],
                          builder: (context, child) => ProductItem(
                            key: ValueKey(index),
                            index: index,
                            didLongPress: didLongPress,
                            isLongPressed: index == longPressedIndex,
                            currentSelectedTabIndex: _tabController.index,
                            setCurrentSelectedTabIndex:
                                setCurrentSelectedTabIndex,
                          ),
                        ),
                        itemCount: products.length,
                        physics: const AlwaysScrollableScrollPhysics(),
                        shrinkWrap: true,
                      ),
                    ),
                    Container(
                      child: ListView.builder(
                        itemBuilder: (context, index) =>
                            ChangeNotifierProvider<Product>.value(
                          value: products[index],
                          builder: (context, child) => ProductItem(
                            key: ValueKey(index),
                            index: index,
                            didLongPress: didLongPress,
                            isLongPressed: index == longPressedIndex,
                            currentSelectedTabIndex: _tabController.index,
                            setCurrentSelectedTabIndex:
                                setCurrentSelectedTabIndex,
                          ),
                        ),
                        itemCount: products.length,
                        physics: const AlwaysScrollableScrollPhysics(),
                        shrinkWrap: true,
                      ),
                    ),
                  ],
                ),
              ),
            ),
      floatingActionButtonLocation:
          _isLoading ? null : FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _isLoading
          ? null
          : FloatingActionButton(
              child: Icon(saveCounter != 0 ? Icons.save : Icons.add),
              onPressed: () {
                if (saveCounter == 0) {
                  return showModalBottomSheet(
                    isScrollControlled: true,
                    context: context,
                    builder: (_) {
                      return NewProduct(_addNewProduct);
                    },
                  );
                } else {
                  return _saveStockChanges(products);
                }
              },
            ),
    );
  }

  Future<void> _saveStockChanges(List<Product> products) async {
    setState(() {
      _isLoading = true;
    });
    Map<String, List<EditProduct>> editedPrimaryProducts = Map();
    Map<String, List<EditProduct>> editedLorryProducts = Map();
    List<String> isTxLoadingList = List(products.length);
    for (var i = 0; i < products.length; i++) {
      if (products[i].primaryQty != 0) {
        products[i].primaryStockList.forEach((e) {
          if (e.transactionDate.isAfter(products[i].transactionDate)) {
            e.qty += products[i].primaryQty;
          }
        });

        EditProduct editedPrimaryStock = EditProduct(
          qty: products[i].primaryQty +
              products[i]
                  .primaryStockList
                  .lastWhere((e) =>
                      !e.transactionDate.isAfter(products[i].transactionDate))
                  .qty,
          transactionDate: products[i].transactionDate,
          transaction: products[i].primaryQty > 0
              ? Transaction.grn
              : Transaction.loading,
          transactionId: uuid.v4(),
          modifiedDate: DateTime.now(),
        );

        if (products[i].primaryQty < 0) {
          isTxLoadingList[i] = editedPrimaryStock.transactionId;
        } else {
          isTxLoadingList[i] = null;
        }

        products[i].primaryStockList.add(editedPrimaryStock);
        products[i].primaryStockList.sort((a, b) {
          var cmp = a.transactionDate.compareTo(b.transactionDate);
          return (cmp != 0 ? cmp : a.modifiedDate.compareTo(b.modifiedDate));
        });
        editedPrimaryProducts['${products[i].id}'] =
            products[i].primaryStockList;
      }
      if (products[i].lorryQty != 0) {
        products[i].lorryStockList.forEach((e) {
          if (e.transactionDate.isAfter(products[i].transactionDate)) {
            e.qty += products[i].lorryQty;
          }
        });

        EditProduct editedLorryStock = EditProduct(
          qty: products[i].lorryQty +
              products[i]
                  .lorryStockList
                  .lastWhere((e) =>
                      !e.transactionDate.isAfter(products[i].transactionDate))
                  .qty,
          transactionDate: products[i].transactionDate,
          transaction: products[i].lorryQty > 0
              ? Transaction.loading
              : Transaction.sales,
          transactionId:
              isTxLoadingList[i] == null ? uuid.v4() : isTxLoadingList[i],
          modifiedDate: DateTime.now(),
        );

        if (products[i].lorryQty < 0) {
          products[i].lorryStockList.removeWhere((e) =>
              e.transactionDate.isAtSameMomentAs(products[i].transactionDate) &&
              e.transaction ==
                  Transaction
                      .sales); //batching sales with same transaction date
        }

        products[i].lorryStockList.add(editedLorryStock);
        products[i].lorryStockList.sort((a, b) {
          var cmp = a.transactionDate.compareTo(b.transactionDate);
          return (cmp != 0 ? cmp : a.modifiedDate.compareTo(b.modifiedDate));
        });
        editedLorryProducts['${products[i].id}'] = products[i].lorryStockList;
      }
      products[i].primaryQty = 0;
      products[i].lorryQty = 0;
    }
    await Provider.of<Products>(context, listen: false)
        .saveStockChanges(editedPrimaryProducts, editedLorryProducts);
    // await Provider.of<Products>(context, listen: false).fetchAndSetProducts();

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _addNewProduct(String name, String productCode, int primaryQty,
      int lorryQty, DateTime minAvailableDate) async {
    setState(() {
      _isLoading = true;
    });
    final primaryStock = EditProduct(
      qty: primaryQty,
      transactionDate: minAvailableDate,
      transaction: Transaction.stockTake,
      transactionId: uuid.v4(),
      modifiedDate: DateTime.now(),
    );
    final lorryStock = EditProduct(
      qty: lorryQty,
      transactionDate: minAvailableDate,
      transaction: Transaction.stockTake,
      transactionId: uuid.v4(),
      modifiedDate: DateTime.now(),
    );
    List<EditProduct> primaryStockList = List();
    primaryStockList.add(primaryStock);
    List<EditProduct> lorryStockList = List();
    lorryStockList.add(lorryStock);
    final product = Product(
      id: DateTime.now().toString(),
      code: productCode,
      name: name,
      categoryTitle: widget.title,
      primaryStockList: primaryStockList,
      lorryStockList: lorryStockList,
    );

    await Provider.of<Products>(context, listen: false).addProduct(product);
    // await Provider.of<Products>(context, listen: false).fetchAndSetProducts(); // Don't fetch
    // context.read<Products>().addProduct(product);
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    animationController.dispose();
    _tabController.dispose();
    super.dispose();
  }
}
