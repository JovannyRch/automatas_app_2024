import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

class RegexInputScreen extends StatefulWidget {
  const RegexInputScreen({super.key});

  @override
  State<RegexInputScreen> createState() => _RegexInputScreenState();
}

class _RegexInputScreenState extends State<RegexInputScreen> {
  //EditTextController
  final TextEditingController _controller = TextEditingController();

  final List<String> _initialSamples = [
    'a.b',
    'a+b',
    'a*',
    'a+',
    'a?',
    'a.b+c',
  ];

  @override
  void initState() {
    String initialSample =
        _initialSamples[Random().nextInt(_initialSamples.length)];
    _controller.text = initialSample;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: <Widget>[
          _operatorsInfoTable(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter a regular expression',
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            child: const Text('Convert to Automata'),
          ),
          //Clean button
          ElevatedButton(
            onPressed: () {
              _controller.clear();
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  Widget _operatorsInfoTable() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Table(
        border: TableBorder.all(),
        children: const <TableRow>[
          TableRow(
            children: <Widget>[
              TableCell(
                child: Center(child: Text('Operator')),
              ),
              TableCell(
                child: Center(child: Text('Description')),
              ),
            ],
          ),
          TableRow(
            children: <Widget>[
              TableCell(
                child: Center(child: Text('.')),
              ),
              TableCell(
                child: Center(child: Text('Concatenation')),
              ),
            ],
          ),
          TableRow(
            children: <Widget>[
              TableCell(
                child: Center(child: Text('+')),
              ),
              TableCell(
                child: Center(child: Text('Union')),
              ),
            ],
          ),
          TableRow(
            children: <Widget>[
              TableCell(
                child: Center(child: Text('*')),
              ),
              TableCell(
                child: Center(child: Text('Kleene closure')),
              ),
            ],
          ),
          TableRow(
            children: <Widget>[
              TableCell(
                child: Center(child: Text('+')),
              ),
              TableCell(
                child: Center(child: Text('Positive closure')),
              ),
            ],
          ),
          TableRow(
            children: <Widget>[
              TableCell(
                child: Center(child: Text('?')),
              ),
              TableCell(
                child: Center(child: Text('Zero or one')),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
