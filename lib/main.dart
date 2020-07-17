import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './screens/categories_screen.dart';
import './providers/products.dart';
import './providers/cached_transaction_date.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => CachedTransactionDate(),
        ),
        ChangeNotifierProvider(
          create: (_) => Products(),
        ),
      ],
      child: MaterialApp(
        title: 'Wireman Inventory',
        theme: ThemeData(
          primarySwatch: Colors.orange,
          accentColor: const Color.fromARGB(255, 186, 35, 35),
        ),
        home: CategoriesScreen(),
      ),
    );
  }
}
