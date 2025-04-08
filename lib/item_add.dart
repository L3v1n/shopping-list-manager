import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ItemAdd extends StatefulWidget {
  const ItemAdd({super.key});

  @override
  State<ItemAdd> createState() => _ItemAddState();
}

class _ItemAddState extends State<ItemAdd> {
  final _formKey = GlobalKey<FormState>();
  final _productNameController = TextEditingController();
  final _stockController = TextEditingController(text: '0');
  final _priceController = TextEditingController();
  int _stockValue = 0;
  bool _isTyped = true;

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
        title: Text('Add item'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
          child: Column(
            children: [
              // PRODUCT NAME
              TextFormField(
                controller: _productNameController,
                keyboardType: TextInputType.text,
                maxLength: 32,
                decoration: InputDecoration(
                  border: OutlineInputBorder(), 
                  labelText: 'Product Name',
                  counterText: '',
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
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Quantity',
                        counterText: '',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter quantity';
                        }
                        if (value.startsWith('0')) {
                          return 'Quantity cannot be 0';
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
                  if (_isTyped && value.length > 1 && value.startsWith('0') && !value.startsWith('0.')) {
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
              // DONE BUTTON
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
                        }
                      );
                    }
                  }, 
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.black
                  ),
                  child: Text('Done',
                    style: TextStyle(color: Colors.white,),
                    ),
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