import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ph_picker_view_controller/ph_picker_view_controller.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _output = '';
  final _phPickerViewControllerPlugin = PhPickerViewController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              const Text('Pick assets by clicking the + button'),
              const SizedBox(
                height: 10,
              ),
              Text(_output),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _pickAssets,
          tooltip: 'Select an asset',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Future<void> _pickAssets() async {
    try {
      var results = await _phPickerViewControllerPlugin.pick(
        filter: {
          'any': ['images', 'videos'],
        },
        preferredAssetRepresentationMode: AssetRepresentationMode.current,
        selection: Selection.ordered,
        selectionLimit: 3,
        fetchURL: true,
      );
      if (results == null) {
        return;
      }

      var output = '';

      // Print all file paths and lengths.
      for (var file in results) {
        output += 'File info: $file\n';

        if (file.path != null) {
          var length = await File(file.path!).length();
          output += 'File length: $length\n';
        }

        output += '------------\n\n';
      }

      setState(() {
        _output = output;
      });
    } catch (err) {
      setState(() {
        _output = err.toString();
      });
    }
  }
}
