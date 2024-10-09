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
  List<PHPickerResult> _results = [];
  final _phPickerViewControllerPlugin = PhPickerViewController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: SingleChildScrollView(
            child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text('Pick assets by clicking the + button'),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(_output),
                    const SizedBox(
                      height: 10,
                    ),
                    if (_results.isNotEmpty)
                      OutlinedButton(
                          onPressed: () async {
                            try {
                              final res = await _phPickerViewControllerPlugin
                                  .delete(_results.map((e) => e.id).toList());
                              setState(() {
                                _output = 'Deleted: $res';
                                _results = [];
                              });
                            } catch (err) {
                              setState(() {
                                _output = err.toString();
                              });
                            }
                          },
                          child: const Text('Delete'))
                  ],
                ))),
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
        appendLiveVideos: true,
      );
      if (results == null) {
        setState(() {
          _output = 'No assets selected';
          _results = [];
        });
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
        _results = results;
      });
    } catch (err) {
      setState(() {
        _output = err.toString();
      });
    }
  }
}
