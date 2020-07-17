// import 'package:Wireman_Inventory/data/products.dart';
// import 'package:Wireman_Inventory/widgets/new_transaction.dart';
// import 'package:Wireman_Inventory/widgets/product_item.dart';
// import '../models/EditProduct.dart';
// import 'package:flutter/material.dart';

// class ProductsScreen extends StatefulWidget {
//   final String title;
//   final Color color;
//   final Image image;

//   ProductsScreen({
//     @required this.title,
//     @required this.image,
//     @required this.color,
//   });

//   @override
//   _ProductsScreenState createState() => _ProductsScreenState();
// }

// class _ProductsScreenState extends State<ProductsScreen>
//     with TickerProviderStateMixin {
//   AnimationController animationController;
//   int longPressedIndex = -1;
//   double displayHeight;
//   ScrollController controller = ScrollController(keepScrollOffset: false);
//   Animation<double> heightAnimation;
//   List<EditProduct> editProductsList = new List(
//     PRODUCTS.length,
//   );
//   @override
//   void initState() {
//     PRODUCTS.asMap().forEach(
//           (i, product) => MapEntry(
//             product,
//             editProductsList[i] = EditProduct(
//               qty: 0,
//               date: DateTime.now(),
//             ),
//           ),
//         );
//     super.initState();
//   }

//   void didLongPress(int index, BuildContext ctx, bool isLoading) async {
//     animationController = AnimationController(
//       duration: const Duration(milliseconds: 400),
//       vsync: this,
//     );
//     Tween<double> heightTween = Tween<double>(begin: displayHeight, end: 375);
//     heightAnimation = heightTween.animate(animationController);

//     longPressedIndex = index;
//     var topPosition = controller.position.pixels;
//     animationController.forward();
//     animationController.addListener(() {
//       setState(() {
//         // controller.animateTo(
//         //   92 * (index + 1 + 2 * (((index + 1) / 8).floor() % 8)) +
//         //       80 -
//         //       topPosition -
//         //       heightAnimation.value,
//         //   curve: Curves.easeIn,
//         //   duration: Duration(milliseconds: 1),
//         // );
//       });
//       controller.animateTo(
//         92 * (index + 1 + 2 * (((index + 1) / 8).floor() % 8)) +
//             80 -
//             topPosition -
//             heightAnimation.value,
//         curve: Curves.easeIn,
//         duration: Duration(milliseconds: 1),
//       );
//     });

//     await showDialog(
//       context: ctx,
//       builder: (_) {
//         return NewTransaction(isLoading, animationController, editProduct);
//       },
//     ).then((value) {
//       setState(() {
//         longPressedIndex = -1;
//         controller = ScrollController(keepScrollOffset: false);
//       });
//     });
//   }

//   void editProduct(int adjustedQty, DateTime transactionDate) {
//     setState(() {
//       editProductsList[longPressedIndex].qty += adjustedQty;
//     });
//   }

//   void didTap(int index, int adjustedQty) {
//     setState(() {
//       editProductsList[index].qty += adjustedQty;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     displayHeight ??= MediaQuery.of(context)?.size?.height;

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.title),
//       ),
//       body: Container(
//         height: heightAnimation == null ? displayHeight : heightAnimation.value,
//         child: ListView.builder(
//           itemBuilder: (context, index) {
//             return (ProductItem(
//               index: index,
//               title: PRODUCTS[index].title,
//               id: PRODUCTS[index].id,
//               totalQty: PRODUCTS[index].qty + editProductsList[index].qty,
//               adjustedQty: editProductsList[index].qty,
//               didLongPress: didLongPress,
//               didTap: didTap,
//               isLongPressed: index == longPressedIndex,
//             ));
//           },
//           controller: controller,
//           itemCount: PRODUCTS.length,
//           physics: AlwaysScrollableScrollPhysics(),
//         ),
//         padding: EdgeInsets.all(5),
//       ),
//     );
//   }

// @override
//   Widget build(BuildContext context) {
//     displayHeight ??= MediaQuery.of(context)?.size?.height;

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.title),
//       ),
//       body: Container(
//         height: heightAnimation == null ? displayHeight : heightAnimation.value,
//         child: SingleChildScrollView(
//           child: Column(
//             children: <Widget>[
//               ...PRODUCTS
//                   .asMap()
//                   .map(
//                     (index, product) => MapEntry(
//                       index,
//                       ProductItem(
//                         title: product.title,
//                         id: product.id,
//                         totalQty: product.qty,
//                         adjustedQty: editProductsList[index].qty,
//                         didLongPress: didLongPress,
//                         index: index,
//                         didTap: didTap,
//                         isLongPressed: longPressedIndex == index,
//                       ),
//                     ),
//                   )
//                   .values
//                   .toList()
//             ],
//           ),
//           controller: controller,
//           physics: AlwaysScrollableScrollPhysics(),
//         ),
//         padding: const EdgeInsets.all(5),
//       ),
//     );
//   }
// }

//////////////////////////////////// Version 2 ///////////////////////////////////////////
// import 'package:Wireman_Inventory/data/products.dart';
// import 'package:Wireman_Inventory/widgets/new_transaction.dart';
// import 'package:Wireman_Inventory/widgets/product_item.dart';
// import '../models/EditProduct.dart';
// import 'package:flutter/material.dart';

// class ProductsScreen extends StatefulWidget {
//   final String title;
//   final Color color;
//   final Image image;

//   ProductsScreen({
//     @required this.title,
//     @required this.image,
//     @required this.color,
//   });

//   @override
//   _ProductsScreenState createState() => _ProductsScreenState();
// }

// class _ProductsScreenState extends State<ProductsScreen>
//     with SingleTickerProviderStateMixin {
//   AnimationController animationController;
//   int longPressedIndex = -1;
//   double displayHeight;
//   ScrollController controller = ScrollController(keepScrollOffset: false);
//   Animation<double> heightAnimation;
//   Animation<double> scrollAnimation;
//   List<EditProduct> editProductsList = new List(
//     PRODUCTS.length,
//   );
//   @override
//   void initState() {
//     PRODUCTS.asMap().forEach(
//           (i, product) => MapEntry(
//             product,
//             editProductsList[i] = EditProduct(
//               qty: 0,
//               date: DateTime.now(),
//             ),
//           ),
//         );
//     super.initState();
//   }

//   void didLongPress(
//       int index, double dy, BuildContext ctx, bool isLoading) async {
//     animationController = AnimationController(
//       duration: const Duration(milliseconds: 500),
//       vsync: this,
//     );
//     Tween<double> heightTween = Tween<double>(begin: displayHeight, end: 375);
//     heightAnimation = heightTween.animate(animationController);

//     Tween<double> scrollTween = Tween<double>(
//         begin: dy - displayHeight, end: 375 - (displayHeight - dy) + 92 / 2);
//     scrollAnimation = scrollTween.animate(
//       CurvedAnimation(
//         parent: animationController,
//         curve: Curves.easeIn,
//       ),
//     )..addListener(() {
//         setState(() {
//           if (dy > displayHeight - 375) {
//             controller.animateTo(
//               scrollAnimation.value,
//               curve: Curves.ease,
//               duration: const Duration(milliseconds: 1),
//             );
//             // controller.jumpTo(scrollAnimation.value);
//           }
//         });
//       });

//     longPressedIndex = index;
//     animationController.forward();

//     await showDialog(
//       context: ctx,
//       builder: (_) {
//         return NewTransaction(
//             isLoading, animationController, editProduct, displayHeight);
//       },
//     ).then((value) {
//       setState(() {
//         longPressedIndex = -1;
//         controller = ScrollController(keepScrollOffset: false);
//       });
//     });
//   }

//   void editProduct(int adjustedQty, DateTime transactionDate) {
//     setState(() {
//       editProductsList[longPressedIndex].qty += adjustedQty;
//     });
//   }

//   void didTap(int index, int adjustedQty) {
//     setState(() {
//       editProductsList[index].qty += adjustedQty;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     displayHeight ??= MediaQuery.of(context)?.size?.height;

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.title),
//       ),
//       body: Container(
//         height: heightAnimation == null ? displayHeight : heightAnimation.value,
//         child: ListView.builder(
//           itemBuilder: (context, index) {
//             return (ProductItem(
//               index: index,
//               title: PRODUCTS[index].title,
//               id: PRODUCTS[index].id,
//               totalQty: PRODUCTS[index].qty + editProductsList[index].qty,
//               adjustedQty: editProductsList[index].qty,
//               didLongPress: didLongPress,
//               didTap: didTap,
//               isLongPressed: index == longPressedIndex,
//             ));
//           },
//           controller: controller,
//           itemCount: PRODUCTS.length,
//           physics: AlwaysScrollableScrollPhysics(),
//           shrinkWrap: true,
//         ),
//         padding: const EdgeInsets.all(5),
//       ),
//     );
//   }
// }

///////////////////////////////////////////////////////// Version 3  //////////////////////////////////////////////////

// import 'package:Wireman_Inventory/data/products.dart';
// import 'package:Wireman_Inventory/widgets/new_transaction.dart';
// import 'package:Wireman_Inventory/widgets/product_item.dart';
// import '../models/EditProduct.dart';
// import 'package:flutter/material.dart';

// class ProductsScreen extends StatefulWidget {
//   final String title;
//   final Color color;
//   final Image image;

//   ProductsScreen({
//     @required this.title,
//     @required this.image,
//     @required this.color,
//   });

//   @override
//   _ProductsScreenState createState() => _ProductsScreenState();
// }

// class _ProductsScreenState extends State<ProductsScreen>
//     with TickerProviderStateMixin {
//   AnimationController animationController;
//   int longPressedIndex = -1;
//   double displayHeight;
//   ScrollController controller = ScrollController(keepScrollOffset: false);
//   Animation<double> heightAnimation;
//   Animation<double> scrollAnimation;
//   List<EditProduct> editProductsList = new List(
//     PRODUCTS.length,
//   );
//   @override
//   void initState() {
//     PRODUCTS.asMap().forEach(
//           (i, product) => MapEntry(
//             product,
//             editProductsList[i] = EditProduct(
//               qty: 0,
//               date: DateTime.now(),
//             ),
//           ),
//         );
//     super.initState();
//   }

//   void didLongPress(
//       int index, double dy, BuildContext ctx, bool isLoading) async {
//     animationController = AnimationController(
//       duration: const Duration(milliseconds: 500),
//       vsync: this,
//     );
//     Tween<double> heightTween = Tween<double>(begin: displayHeight, end: 375);
//     heightAnimation = heightTween.animate(
//       CurvedAnimation(
//         parent: animationController,
//         curve: Curves.easeIn,
//       ),
//     );

//     Tween<double> scrollTween = Tween<double>(
//         begin: dy - displayHeight, end: 375 - (displayHeight - dy) + 92 / 2);
//     scrollAnimation = scrollTween.animate(
//       CurvedAnimation(
//         parent: animationController,
//         curve: Curves.easeIn,
//       ),
//     )..addListener(() {
//         setState(() {
//           if (dy > displayHeight - 375) {
//             controller.animateTo(
//               scrollAnimation.value,
//               curve: Curves.ease,
//               duration: const Duration(microseconds: 10),
//             );
//             // controller.jumpTo(scrollAnimation.value);
//           }
//         });
//       });

//     longPressedIndex = index;
//     animationController.forward();

//     await showDialog(
//       context: ctx,
//       builder: (_) {
//         return NewTransaction(
//             isLoading, animationController, editProduct, displayHeight);
//       },
//     ).then((value) {
//       setState(() {
//         longPressedIndex = -1;
//         controller = ScrollController(keepScrollOffset: false);
//       });
//     });
//   }

//   void editProduct(int adjustedQty, DateTime transactionDate) {
//     setState(() {
//       editProductsList[longPressedIndex].qty += adjustedQty;
//     });
//   }

//   void didTap(int index, int adjustedQty) {
//     setState(() {
//       editProductsList[index].qty += adjustedQty;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     displayHeight ??= MediaQuery.of(context)?.size?.height;
//     var listView = ListView.builder(
//       itemBuilder: (context, index) {
//         return (ProductItem(
//           key: ValueKey(index),
//           index: index,
//           title: PRODUCTS[index].title,
//           id: PRODUCTS[index].id,
//           totalQty: PRODUCTS[index].qty + editProductsList[index].qty,
//           adjustedQty: editProductsList[index].qty,
//           didLongPress: didLongPress,
//           didTap: didTap,
//           isLongPressed: index == longPressedIndex,
//         ));
//       },
//       controller: controller,
//       itemCount: PRODUCTS.length,
//       physics: AlwaysScrollableScrollPhysics(),
//       shrinkWrap: true,
//     );

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.title),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(5),
//         child: longPressedIndex == -1
//             ? Container(
//                 child: listView,
//                 height: displayHeight,
//               )
//             : SizeTransition(sizeFactor: heightAnimation, child: listView),
//       ),
//     );
//   }
// }

//////////////////////////////////////////////// Version 4  /////////////////////////////////////////////////

// import 'package:Wireman_Inventory/data/products.dart';
// import 'package:Wireman_Inventory/widgets/new_transaction.dart';
// import 'package:Wireman_Inventory/widgets/product_item.dart';
// import '../models/EditProduct.dart';
// import 'package:flutter/material.dart';

// class ProductsScreen extends StatefulWidget {
//   final String title;
//   final Color color;
//   final Image image;

//   ProductsScreen({
//     @required this.title,
//     @required this.image,
//     @required this.color,
//   });

//   @override
//   _ProductsScreenState createState() => _ProductsScreenState();
// }

// class _ProductsScreenState extends State<ProductsScreen>
//     with TickerProviderStateMixin {
//   AnimationController animationController;
//   int longPressedIndex = -1;
//   double displayHeight;
//   ScrollController controller = ScrollController(keepScrollOffset: false);
//   Animation<double> heightAnimation;
//   Animation<double> scrollAnimation;
//   List<EditProduct> editProductsList = new List(
//     PRODUCTS.length,
//   );
//   @override
//   void initState() {
//     PRODUCTS.asMap().forEach(
//           (i, product) => MapEntry(
//             product,
//             editProductsList[i] = EditProduct(
//               qty: 0,
//               date: DateTime.now(),
//             ),
//           ),
//         );
//     super.initState();
//   }

//   void didLongPress(
//       int index, double dy, BuildContext ctx, bool isLoading) async {
//     animationController = AnimationController(
//       duration: const Duration(milliseconds: 500),
//       vsync: this,
//     );
//     Tween<double> heightTween = Tween<double>(begin: displayHeight, end: 375);
//     heightAnimation = heightTween.animate(animationController);

//     Tween<double> scrollTween = Tween<double>(
//         begin: dy - displayHeight, end: 375 - (displayHeight - dy) + 92 / 2);
//     scrollAnimation = scrollTween.animate(
//       CurvedAnimation(
//         parent: animationController,
//         curve: Curves.easeIn,
//       ),
//     )..addListener(() {
//         setState(() {
//           if (dy > displayHeight - 375) {
//             controller.animateTo(
//               scrollAnimation.value,
//               curve: Curves.ease,
//               duration: const Duration(microseconds: 10),
//             );
//             // controller.jumpTo(scrollAnimation.value);
//           }
//         });
//       });

//     longPressedIndex = index;
//     animationController.forward();

//     await showDialog(
//       context: ctx,
//       builder: (_) {
//         return NewTransaction(
//             isLoading, animationController, editProduct, displayHeight);
//       },
//     ).then((value) {
//       setState(() {
//         longPressedIndex = -1;
//         controller = ScrollController(keepScrollOffset: false);
//       });
//     });
//   }

//   void editProduct(int adjustedQty, DateTime transactionDate) {
//     setState(() {
//       editProductsList[longPressedIndex].qty += adjustedQty;
//     });
//   }

//   void didTap(int index, int adjustedQty) {
//     setState(() {
//       editProductsList[index].qty += adjustedQty;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     displayHeight ??= MediaQuery.of(context)?.size?.height;

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.title),
//       ),
//       body: Container(
//         height: heightAnimation == null ? displayHeight : heightAnimation.value,
//         child: ListView.builder(
//           itemBuilder: (context, index) {
//             return ValueListenableBuilder(
//               valueListenable: ValueNotifier(index),
//               builder: (ctx, value, __) => (ProductItem(
//                 key: ValueKey(index),
//                 context: ctx,
//                 index: index,
//                 title: PRODUCTS[index].title,
//                 id: PRODUCTS[index].id,
//                 totalQty: PRODUCTS[index].qty + editProductsList[index].qty,
//                 adjustedQty: editProductsList[index].qty,
//                 didLongPress: didLongPress,
//                 didTap: didTap,
//                 isLongPressed: index == longPressedIndex,
//               )),
//             );
//           },
//           controller: controller,
//           itemCount: PRODUCTS.length,
//           physics: AlwaysScrollableScrollPhysics(),
//           shrinkWrap: true,
//         ),
//         padding: const EdgeInsets.all(5),
//       ),
//     );
//   }
// }

///////////////////////////////////////////////////////////////////////////////////

// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

// class NewTransaction extends StatefulWidget {
//   final bool isLoading;
//   final AnimationController _animationController;
//   final Function editProduct;
//   final double displayHeight;

//   NewTransaction(
//     this.isLoading,
//     this._animationController,
//     this.editProduct,
//     this.displayHeight,
//   );

//   @override
//   _NewTransactionState createState() => _NewTransactionState();
// }

// class _NewTransactionState extends State<NewTransaction> {
//   Animation<double> opacityAnimation;
//   Tween<double> opacityTween = Tween<double>(begin: 0.0, end: 1.0);
//   Tween<double> marginTopTween;

//   Animation<double> marginTopAnimation;
//   AnimationStatus animationStatus;
//   final _qtyController = TextEditingController();
//   DateTime _selectedDate = DateTime.now();

//   @override
//   void initState() {
//     super.initState();
//     marginTopTween = Tween<double>(
//         begin: widget.displayHeight, end: widget.displayHeight - 375);
//     marginTopAnimation = marginTopTween.animate(
//       CurvedAnimation(
//         parent: widget._animationController,
//         curve: Curves.easeIn,
//       ),
//     )..addListener(() {
//         animationStatus = widget._animationController.status;

//         if (animationStatus == AnimationStatus.dismissed) {
//           Navigator.of(context).pop();
//         }

//         if (this.mounted) {
//           setState(() {});
//         }
//       });
//   }

//   void _submitData() {
//     final enteredQty = int.parse(_qtyController.text);

//     if (enteredQty <= 0) {
//       return;
//     }
//     widget.editProduct(
//       widget.isLoading ? enteredQty : enteredQty * -1,
//       _selectedDate,
//     );
//     widget._animationController.reverse();
//     Navigator.of(context).pop();
//   }

//   void _presentDatePicker() {
//     showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime(2020),
//       lastDate: DateTime.now(),
//     ).then((selectedDate) {
//       if (selectedDate != null) {
//         setState(() {
//           _selectedDate = selectedDate;
//         });
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FadeTransition(
//       opacity: opacityTween.animate(widget._animationController),
//       child: GestureDetector(
//         onTap: () {
//           widget._animationController.reverse();
//         },
//         child: Material(
//           color: Colors.transparent,
//           child: Container(
//             margin: EdgeInsets.only(top: marginTopAnimation.value),
//             color: widget.isLoading ? Colors.green[100] : Colors.red[100],
//             padding: const EdgeInsets.all(10),
//             child: ListView(
//               children: [
//                 TextField(
//                   decoration: const InputDecoration(labelText: 'Qty'),
//                   controller: _qtyController,
//                   keyboardType: TextInputType.number,
//                   // onSubmitted: (_) => _submitData(),
//                 ),
//                 Container(
//                   height: 70,
//                   child: Row(
//                     children: <Widget>[
//                       Text(
//                           '${widget.isLoading ? 'Loading' : 'Sales'} Date: ${DateFormat.yMd().format(_selectedDate)}'),
//                       FlatButton(
//                         textColor: Theme.of(context).primaryColor,
//                         child: const Text(
//                           'Choose Date',
//                           style: const TextStyle(fontWeight: FontWeight.bold),
//                         ),
//                         onPressed: _presentDatePicker,
//                       )
//                     ],
//                   ),
//                 ),
//                 RaisedButton(
//                   onPressed: _submitData,
//                   child: const Text('Add Transaction'),
//                   color: Theme.of(context).primaryColor,
//                   textColor: Theme.of(context).textTheme.button.color,
//                 )
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     // widget._animationController.dispose();
//     super.dispose();
//   }
// }
