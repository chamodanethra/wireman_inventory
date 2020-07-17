import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/products.dart';

class NewProduct extends StatefulWidget {
  final Function addNewProduct;
  NewProduct(this.addNewProduct);

  @override
  _NewProductState createState() => _NewProductState();
}

class _NewProductState extends State<NewProduct> {
  final _nameController = TextEditingController();
  final _productCodeController = TextEditingController();
  final _primaryQtyController = TextEditingController();
  final _lorryQtyController = TextEditingController();
  DateTime _selectedDate;
  var isDuplicateCode = false;
  var _isLoading = false;

  @override
  void initState() {
    _productCodeController.addListener(() {
      setState(() {
        isDuplicateCode = Provider.of<Products>(context, listen: false)
            .isProductAvailable(
                _productCodeController.text.toUpperCase().trim());
      });
    });
    super.initState();
  }

  Future<void> _submitData() async {
    final enteredName = _nameController.text.trim();
    final enteredProductCode = _productCodeController.text.toUpperCase().trim();
    final enteredPrimaryQty = _primaryQtyController.text.trim();
    final enteredLorryQty = _lorryQtyController.text.trim();
    final enteredDate = _selectedDate;

    if (enteredName.isEmpty ||
        enteredProductCode.isEmpty ||
        enteredPrimaryQty.isEmpty ||
        enteredLorryQty.isEmpty ||
        enteredDate == null ||
        isDuplicateCode) {
      return;
    }
    var primaryQty = int.tryParse(enteredPrimaryQty);
    var lorryQty = int.tryParse(enteredLorryQty);
    if (primaryQty == null || lorryQty == null) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    await widget.addNewProduct(
      enteredName,
      enteredProductCode,
      primaryQty,
      lorryQty,
      enteredDate,
    );

    setState(() {
      _isLoading = false;
    });
    Navigator.of(context).pop();
  }

  void _presentDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020, 5, 29),
      lastDate: DateTime.now(),
    ).then((selectedDate) {
      if (selectedDate == null) {
        return;
      }
      setState(() {
        _selectedDate = selectedDate;
      });
    });
  }

  double max(double a, double b) {
    if (a > b) {
      return a;
    }
    return b;
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(
            child: const CircularProgressIndicator(),
          )
        : Card(
            child: Container(
              height: 410 +
                  (max(
                    MediaQuery.of(context).viewInsets.bottom + 40 - 238,
                    0,
                  )),
              color: Color.fromARGB(50, 186, 35, 35),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: <Widget>[
                      Expanded(
                        flex: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            decoration: InputDecoration(
                                labelText: 'Name',
                                enabledBorder: isDuplicateCode
                                    ? const OutlineInputBorder(
                                        borderSide: const BorderSide(
                                            color: Colors.red, width: 1.0),
                                      )
                                    : null),
                            controller: _nameController,
                            onSubmitted: (_) => _submitData(),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            decoration: InputDecoration(
                                labelText: 'Product Code',
                                enabledBorder: isDuplicateCode
                                    ? const OutlineInputBorder(
                                        borderSide: const BorderSide(
                                            color: Colors.red, width: 1.0),
                                      )
                                    : null),
                            controller: _productCodeController,
                            onSubmitted: (_) => _submitData(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            decoration:
                                const InputDecoration(labelText: 'Primary Qty'),
                            controller: _primaryQtyController,
                            keyboardType: TextInputType.number,
                            onSubmitted: (_) => _submitData(),
                          ),
                        ),
                      ),
                      Expanded(child: const SizedBox()),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            decoration:
                                const InputDecoration(labelText: 'Lorry Qty'),
                            controller: _lorryQtyController,
                            keyboardType: TextInputType.number,
                            onSubmitted: (_) => _submitData(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    height: 70,
                    child: Row(
                      // mainAxisAlignment: ,
                      children: <Widget>[
                        const Text('Available From Date'),
                        FlatButton(
                          textColor: Theme.of(context).primaryColor,
                          child: Text(
                            _selectedDate == null
                                ? 'Choose Date!'
                                : '${DateFormat.yMd().format(_selectedDate)}',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          onPressed: _presentDatePicker,
                        ),
                        RaisedButton(
                          onPressed: _submitData,
                          child: const Text('Add'),
                          color: Theme.of(context).primaryColor,
                          textColor: Theme.of(context).textTheme.button.color,
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            elevation: 5,
          );
  }

  @override
  void dispose() {
    _productCodeController.dispose();
    super.dispose();
  }
}
