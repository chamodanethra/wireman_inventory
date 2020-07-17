import 'package:flutter/foundation.dart';

import '../models/edit_product.dart';
import '../providers/product.dart';

class EditProducts with ChangeNotifier {
  List<EditProduct> _editProducts = List();

  List<EditProduct> get editProductList {
    return [..._editProducts];
  }
}
