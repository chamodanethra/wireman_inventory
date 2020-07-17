import 'package:Wireman_Inventory/providers/product.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/cached_transaction_date.dart';

class NewTransaction extends StatefulWidget {
  final bool isIncreasing;
  final AnimationController _animationController;
  final double displayHeight;
  final int currentSelectedTabIndex;
  final Product product;

  NewTransaction(
    this.isIncreasing,
    this._animationController,
    this.displayHeight,
    this.currentSelectedTabIndex,
    this.product,
  );

  @override
  _NewTransactionState createState() => _NewTransactionState();
}

class _NewTransactionState extends State<NewTransaction> {
  Animation<double> opacityAnimation;
  Tween<double> opacityTween = Tween<double>(begin: 0.0, end: 1.0);
  Tween<double> marginTopTween;

  Animation<double> marginTopAnimation;
  AnimationStatus animationStatus;
  final _qtyController = TextEditingController();
  var _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = Provider.of<CachedTransactionDate>(context, listen: false)
        .cachedTransactionDate;
    marginTopTween = Tween<double>(
        begin: widget.displayHeight, end: widget.displayHeight - 310);
    marginTopAnimation = marginTopTween.animate(
      CurvedAnimation(
        parent: widget._animationController,
        curve: Curves.easeIn,
      ),
    )..addListener(() {
        animationStatus = widget._animationController.status;

        if (animationStatus == AnimationStatus.dismissed) {
          Navigator.of(context).pop();
        }

        if (this.mounted) {
          setState(() {});
        }
      });
  }

  void _submitData(bool shouldOverwrite) async {
    if (_qtyController.text.trim().isEmpty) {
      return;
    }
    var enteredQty = int.tryParse(_qtyController.text.trim());
    if (enteredQty == null) {
      return;
    }
    if (enteredQty < 0) {
      return;
    }

    if (!widget.isIncreasing) {
      enteredQty = -enteredQty;
    }

    if (await widget.product.validateStockQuantities(enteredQty, _selectedDate,
        widget.currentSelectedTabIndex == 0, shouldOverwrite, context)) {
      widget._animationController.reverse();
      Provider.of<CachedTransactionDate>(context, listen: false)
          .setCachedTransactionDate(_selectedDate);
    }
    // Navigator.of(context).pop();
  }

  void _presentDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    ).then((selectedDate) {
      if (selectedDate != null) {
        setState(() {
          _selectedDate = selectedDate;
        });
      }
    });
  }

  double max(double a, double b) {
    if (a > b) {
      return a;
    }
    return b;
  }

  int min(int a, int b) {
    if (a < b) {
      return a;
    }
    return b;
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: opacityTween.animate(widget._animationController),
      child: GestureDetector(
        onTap: () {
          widget._animationController.reverse();
        },
        child: Material(
          color: Colors.transparent,
          child: GestureDetector(
            onTap: () {
              // widget._animationController.reverse();
            },
            child: Container(
              transform: Matrix4.translationValues(
                0.0,
                widget._animationController.status != AnimationStatus.forward
                    ? -max(
                        MediaQuery.of(context).viewInsets.bottom +
                            70 +
                            30 -
                            238,
                        0) // remove 30
                    : 0,
                0.0,
              ),
              margin: EdgeInsets.only(
                top: marginTopAnimation.value,
              ),
              color: widget.isIncreasing ? Colors.green[100] : Colors.red[100],
              padding: const EdgeInsets.all(10),
              child: ListView(
                children: [
                  TextField(
                    autocorrect: false,
                    enableSuggestions: false,
                    decoration: const InputDecoration(labelText: 'Qty'),
                    controller: _qtyController,
                    keyboardType: TextInputType.number,
                    // onSubmitted: (_) => _submitData(),
                  ),
                  Container(
                    height: 70,
                    child: Row(
                      children: <Widget>[
                        Text(
                            '${widget.isIncreasing ? widget.currentSelectedTabIndex == 1 ? 'Loading' : 'GRN' : widget.currentSelectedTabIndex == 1 ? 'Sales' : 'Loading'} Date: ${DateFormat.yMd().format(_selectedDate)}'),
                        FlatButton(
                          textColor: Theme.of(context).primaryColor,
                          child: const Text(
                            'Choose Date',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          onPressed: _presentDatePicker,
                        )
                      ],
                    ),
                  ),
                  Container(
                    height: 70,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        RaisedButton(
                          onPressed: () => _submitData(true),
                          child: const Text('New Transaction'),
                          color: Theme.of(context).primaryColor,
                          textColor: Theme.of(context).textTheme.button.color,
                        ),
                        RaisedButton(
                          onPressed: () => _submitData(false),
                          child: const Text('Add Transaction'),
                          color: Theme.of(context).primaryColor,
                          textColor: Theme.of(context).textTheme.button.color,
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // widget._animationController.dispose();
    super.dispose();
  }
}
