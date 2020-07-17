import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/category_item.dart';
import '../data/categories.dart';
import '../providers/products.dart';

class CategoriesScreen extends StatefulWidget {
  @override
  _CategoriesScreenState createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  var _isLoading = true;

  @override
  void initState() {
    Future.delayed(Duration.zero).then((_) {
      return Provider.of<Products>(context, listen: false)
          .fetchAndSetProducts();
    }).then((_) {
      setState(() {
        _isLoading = false;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Wireman Inventory'),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : GridView(
              cacheExtent: 2000,
              children: [
                ...CATEGORIES
                    .map(
                      (category) => CategoryItem(
                        title: category.title,
                        image: category.image,
                        color: category.color,
                      ),
                    )
                    .toList()
              ],
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200,
                childAspectRatio: 1.26 * 200 / 274,
                crossAxisSpacing: 5,
                mainAxisSpacing: 5,
              ),
              padding: const EdgeInsets.all(5),
            ),
    );
  }
}
