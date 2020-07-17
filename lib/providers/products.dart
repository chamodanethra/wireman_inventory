import 'dart:convert' as convert;
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:device_info/device_info.dart';

import '../models/edit_product.dart';
import '../providers/product.dart';
import '../data/categories.dart';

class Products with ChangeNotifier {
  List<Product> _products = List();
  String androidId;
  Map<String, int> _categoryWiseCountMap = Map();

  Products() {
    initPlatformState();
    CATEGORIES
        .forEach((e) => _categoryWiseCountMap.putIfAbsent(e.title, () => 0));
  }

  void notifyProductQuantityChange(String categoryTitle) {
    var previousCategoryUnsavedCount = _categoryWiseCountMap[categoryTitle];
    _categoryWiseCountMap[categoryTitle] = productsFromCategory(categoryTitle)
        .where((e) => e.primaryQty != 0 || e.lorryQty != 0)
        .toList()
        .length;
    if (_categoryWiseCountMap[categoryTitle] == 0 ||
        previousCategoryUnsavedCount == 0) {
      notifyListeners();
    }
  }

  int getCategoryCountValue(String categoryTitle) {
    return _categoryWiseCountMap[categoryTitle];
  }

  Future<void> initPlatformState() async {
    try {
      if (Platform.isAndroid) {
        androidId = _readAndroidBuildData(await DeviceInfoPlugin().androidInfo);
      }
    } on PlatformException {}
  }

  String _readAndroidBuildData(AndroidDeviceInfo build) {
    return build.androidId;
    // <String, String>{
    // 'version.securityPatch': build.version.securityPatch,
    // 'version.sdkInt': build.version.sdkInt,
    // 'version.release': build.version.release,
    // 'version.previewSdkInt': build.version.previewSdkInt,
    // 'version.incremental': build.version.incremental,
    // 'version.codename': build.version.codename,
    // 'version.baseOS': build.version.baseOS,
    // 'board': build.board,
    // 'bootloader': build.bootloader,
    // 'brand': build.brand,
    // 'device': build.device,
    // 'display': build.display,
    // 'fingerprint': build.fingerprint,
    // 'hardware': build.hardware,
    // 'host': build.host,
    // 'id': build.id,
    // 'manufacturer': build.manufacturer,
    // 'model': build.model,
    // 'product': build.product,
    // 'supported32BitAbis': build.supported32BitAbis,
    // 'supported64BitAbis': build.supported64BitAbis,
    // 'supportedAbis': build.supportedAbis,
    // 'tags': build.tags,
    // 'type': build.type,
    // 'isPhysicalDevice': build.isPhysicalDevice,
    // 'androidId': build.androidId,
    // 'systemFeatures': build.systemFeatures,
    // };
  }

  List<Product> get products {
    return [..._products];
  }

  Future<void> addProduct(Product product) async {
    // if (androidId != 'f89a5eefa34fe17d') {
    //   return;
    // }
    const url = 'https://wireman-inventory.firebaseio.com/products.json';
    try {
      final response = await http.post(url,
          body: convert.json.encode({
            'name': product.name,
            'code': product.code,
            'categoryTitle': product.categoryTitle,
            'primaryStockList': product.primaryStockList
                .map((e) => {
                      'qty': e.qty,
                      'transactionDate': e.transactionDate.toIso8601String(),
                      'transaction': e.transaction.index,
                      'transactionId': e.transactionId,
                      'modifiedDate': e.modifiedDate.toIso8601String(),
                    })
                .toList(),
            'lorryStockList': product.lorryStockList
                .map((e) => {
                      'qty': e.qty,
                      'transactionDate': e.transactionDate.toIso8601String(),
                      'transaction': e.transaction.index,
                      'transactionId': e.transactionId,
                      'modifiedDate': e.modifiedDate.toIso8601String(),
                    })
                .toList(),
          }));

      _products.add(
        Product(
          id: convert.json.decode(response.body)['name'],
          code: product.code,
          name: product.name,
          categoryTitle: product.categoryTitle,
          primaryStockList: product.primaryStockList,
          lorryStockList: product.lorryStockList,
          productsProvider: this,
        ),
      );

      _products.sort((a, b) => a.code.compareTo(b.code));
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Transaction getTransaction(int index) {
    switch (index) {
      case 0:
        return Transaction.stockTake;
      case 1:
        return Transaction.grn;
      case 2:
        return Transaction.loading;
      case 3:
        return Transaction.sales;
      case 4:
        return Transaction.stockAdjustment;
      case 5:
        return Transaction.unLoading;
      case 6:
        return Transaction.goodReturn;
      case 7:
        return Transaction.damagedReturn;
    }
    return null;
  }

  Future<void> fetchAndSetProducts() async {
    try {
      const url = 'https://wireman-inventory.firebaseio.com/products.json';
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final extractedData =
            convert.json.decode(response.body) as Map<String, dynamic>;
        if (extractedData == null) {
          throw Exception();
        }
        final List<Product> loadedProducts = [];
        extractedData.forEach((productId, prodData) {
          loadedProducts.add(
            Product(
              id: productId,
              categoryTitle: prodData['categoryTitle'],
              name: prodData['name'],
              code: prodData['code'],
              primaryStockList: (prodData['primaryStockList'] as List<dynamic>)
                  .map(
                    (e) => EditProduct(
                      qty: e['qty'],
                      transactionDate: DateTime.parse(e['transactionDate']),
                      transaction: getTransaction(e['transaction']),
                      transactionId: e['transactionId'],
                      modifiedDate: DateTime.parse(e['modifiedDate']),
                    ),
                  )
                  .toList(),
              lorryStockList: (prodData['lorryStockList'] as List<dynamic>)
                  .map(
                    (e) => EditProduct(
                      qty: e['qty'],
                      transactionDate: DateTime.parse(e['transactionDate']),
                      transaction: getTransaction(e['transaction']),
                      transactionId: e['transactionId'],
                      modifiedDate: DateTime.parse(e['modifiedDate']),
                    ),
                  )
                  .toList(),
              productsProvider: this,
            ),
          );
        });
        _products = loadedProducts;
        _products.sort((a, b) => a.code.compareTo(b.code));
        notifyListeners();
      }
    } catch (error) {
      throw error;
    }
  }

  List<Product> productsFromCategory(String categoryTitle) {
    return products
        .where((prod) => prod.categoryTitle == categoryTitle)
        .toList();
  }

  Product getProductByCode(String productCode) {
    return products.firstWhere((prod) => prod.code == productCode);
  }

  bool isProductAvailable(String productCode) {
    return products.indexWhere((prod) => prod.code == productCode) != -1;
  }

  int max(int a, int b) {
    if (a > b) {
      return a;
    }
    return b;
  }

  Future<void> saveStockChanges(
      Map<String, List<EditProduct>> editedPrimaryProducts,
      Map<String, List<EditProduct>> editedLorryProducts) async {
    String categoryTitle;
    // if (androidId != 'f89a5eefa34fe17d') {
    //   return;
    // }
    try {
      editedPrimaryProducts.forEach((id, epList) async {
        categoryTitle =
            products.firstWhere((prod) => prod.id == id).categoryTitle;
        final url =
            'https://wireman-inventory.firebaseio.com/products/$id.json';
        final response = await http.patch(url,
            body: convert.json.encode({
              'primaryStockList': epList
                  .sublist(max(0, epList.length - 60))
                  .map((e) => {
                        'qty': e.qty,
                        'transactionDate': e.transactionDate.toIso8601String(),
                        'transaction': e.transaction.index,
                        'transactionId': e.transactionId,
                        'modifiedDate': e.modifiedDate.toIso8601String(),
                      })
                  .toList()
            }));
        // print(convert.json.decode(response.body));
      });

      editedLorryProducts.forEach((id, epList) async {
        categoryTitle =
            products.firstWhere((prod) => prod.id == id).categoryTitle;
        final url =
            'https://wireman-inventory.firebaseio.com/products/$id.json';
        final response = await http.patch(url,
            body: convert.json.encode({
              'lorryStockList': epList
                  .sublist(max(0, epList.length - 60))
                  .map((e) => {
                        'qty': e.qty,
                        'transactionDate': e.transactionDate.toIso8601String(),
                        'transaction': e.transaction.index,
                        'transactionId': e.transactionId,
                        'modifiedDate': e.modifiedDate.toIso8601String(),
                      })
                  .toList()
            }));
        // print(convert.json.decode(response.body));
      });
      _categoryWiseCountMap[categoryTitle] = 0;
      notifyProductQuantityChange(categoryTitle);
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }
}
