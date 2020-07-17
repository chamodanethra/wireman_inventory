import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/products_screen.dart';
import '../providers/products.dart';

class CategoryItem extends StatefulWidget {
  final String title;
  final Color color;
  final Image image;

  CategoryItem({
    @required this.title,
    @required this.image,
    @required this.color,
  });

  @override
  _CategoryItemState createState() => _CategoryItemState();
}

class _CategoryItemState extends State<CategoryItem> {
  int _unsavedProductsCount = 0;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context)
            .push(
          MaterialPageRoute(
            builder: (context) => ProductsScreen(
              title: widget.title,
            ),
          ),
        )
            .then((value) {
          setState(() {
            _unsavedProductsCount =
                Provider.of<Products>(context, listen: false)
                    .getCategoryCountValue(widget.title);
          });
        });
      },
      child: Stack(
        children: [
          Card(
            child: Column(
              children: <Widget>[
                Expanded(
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(15)),
                        child: this.widget.image,
                      ),
                      CustomPaint(
                        child: Container(
                          height: 300,
                          width: 310,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  widget.title,
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            elevation: 4,
            margin: const EdgeInsets.all(10),
            color: this.widget.color,
          ),
          if (_unsavedProductsCount != 0)
            Positioned(
              right: 15 / 2,
              child: Container(
                alignment: Alignment.center,
                padding: EdgeInsets.all(1),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(18),
                ),
                constraints: BoxConstraints(
                  minWidth: 36,
                  minHeight: 36,
                ),
                child: Text(
                  '$_unsavedProductsCount',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
