import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ItemEdit extends StatefulWidget {
  final String name;
  final int quantity;
  final String price;
  final int index;
  final int? id;

  const ItemEdit({
    super.key,
    required this.name,
    required this.quantity,
    required this.price,
    required this.index,
    this.id,
  });

  @override
  State<ItemEdit> createState() => _ItemEditState();
}

class _ItemEditState extends State<ItemEdit> {
  final _formKey = GlobalKey<FormState>();
  late var _productNameController = TextEditingController();
  late var _stockController = TextEditingController(text: '0');
  late var _priceController = TextEditingController();

  late int _stockValue = 0;
  bool _isTyped = false;

  // LOAD DATA FROM SELECTED ITEM
  @override
  void initState() {
    super.initState();
    _productNameController = TextEditingController(text: widget.name);
    _stockController = TextEditingController(text: widget.quantity.toString());
    _priceController = TextEditingController(text: widget.price);
    _stockValue = widget.quantity;
  }

  // REFRESH THE TEXT CONTROLLER
  @override
  void dispose() {
    _productNameController.dispose();
    _stockController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  // ADD QUANTITY
  void _incrementCounter() {
    setState(() {
      _stockValue++;
      _stockController.text = _stockValue.toString();
    });
  }

  // SUB QUANTITY
  void _decrementCounter() {
    setState(() {
      if (_stockValue > 0) {
        _stockValue--;
        _stockController.text = _stockValue.toString();
      }
      if (_stockValue == 0) {
        _isTyped = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Edit item'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
          child: Column(
            children: [
              // PRODUCT ID DISPLAY
              if (widget.id != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: TextFormField(
                    initialValue: '${widget.id}',
                    readOnly: true,
                    enabled: false,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Product ID',
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                  ),
                ),
              // PRODUCT NAME
              TextFormField(
                controller: _productNameController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  border: OutlineInputBorder(), 
                  labelText: 'Product Name',
                  ),
                // VALIDATION
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter product name';
                  }
                  if (!RegExp(r'^[a-zA-Z]').hasMatch(value)) {
                  return 'Product name cannot start with numbers or symbols';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    // QUANTITY
                    child: TextFormField(
                      controller: _stockController,
                      keyboardType: TextInputType.number,
                      maxLength: 9,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Quantity',
                        counterText: '',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter quantity';
                        }
                        return null;
                      },
                      // VALIDATION
                      onChanged: (value) {
                        if (_isTyped && value.length > 1 && value.startsWith('0')) {
                          final newValue = value.substring(1);
                          _stockController.value = TextEditingValue(
                            text: newValue,
                            selection: TextSelection.collapsed(offset: newValue.length),
                          );
                          _stockValue = int.tryParse(newValue) ?? 0;
                          _isTyped = false;
                        } else {
                          _stockValue = int.tryParse(value) ?? 0;
                          if (value != '0') {
                            _isTyped = false;
                          }
                        }
                        setState(() {});
                      },
                    ),
                  ),
                  // QUANTITY BUTTON
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Column(
                      children: [
                        IconButton(
                          icon: Icon(Icons.add),
                          onPressed: _incrementCounter,
                        ),
                        IconButton(
                          icon: Icon(Icons.remove),
                          onPressed: _decrementCounter,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              // PRICE
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  TextInputFormatter.withFunction(
                    (oldValue, newValue) {
                      if (newValue.text.isEmpty) {
                        return newValue;
                      }
                      if (newValue.text.split('.').length > 2) {
                        return oldValue;
                      }
                      if (RegExp(r'^[0-9]+\.?[0-9]*$').hasMatch(newValue.text)) {
                        return newValue;
                      }
                      return oldValue;
                    },
                  )
                ],
                maxLength: 9,
                decoration: InputDecoration(
                  border: OutlineInputBorder(), 
                  labelText: 'Price',
                  hintText: '₱',
                  counterText: '',
                  ),
                // VALIDATION
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter price';
                  }
                  if (value == '0.') {
                    return 'Please complete the decimal value';
                  }
                  if (value.startsWith('0') && !value.startsWith('0.')) {
                    return 'Invalid price format';
                  }
                  try {
                  double numValue = double.parse(value);
                    if (numValue == 0) {
                      return 'Price cannot be 0';
                    }
                  } catch (e) {
                    return 'Invalid price format';
                  }
                  return null;
                },
                // VALIDATION
                onChanged: (value) {
                  if (_isTyped && value.length > 1 && value.startsWith('0')) {
                    final newValue = value.substring(1);
                    _priceController.value = TextEditingValue(
                      text: newValue,
                      selection: TextSelection.collapsed(offset: newValue.length),
                    );
                  }
                  setState(() {});
                },
              ),
              Spacer(),
              // UPDATE BUTTON
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: (){
                    if (_formKey.currentState!.validate()) {
                      Navigator.pop(
                        context, {
                          'name': _productNameController.text,
                          'quantity': _stockValue,
                          'price': _priceController.text,
                          'index': widget.index,
                          'id': widget.id,
                        }
                      );
                    }
                  }, 
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.black
                  ),
                  child: Text('Update',
                    style: TextStyle(color: Colors.white,),
                    ),
                  ),
              ),
              SizedBox(height: 8),
              // DELETE BUTTON
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: (){
                    Navigator.pop(context, 
                      {
                        'index': widget.index,
                        'delete': true,
                      }
                    );
                  }, 
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.red,
                    width: 1.5,),
                    foregroundColor: Colors.red
                  ),
                  child: Text('Delete'),
                  ),
              ),
              SizedBox(height: 8)
            ],
          ),
        ),
      ),
    );
  }
}