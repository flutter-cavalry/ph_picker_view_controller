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
  List<PHPickerResult>? _results;
  String? _err;
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
              const Text('Select an asset by clicking the + button'),
              if (_err != null)
                Text('Error: $_err')
              else if (_results != null)
                ..._results!.map((s) => Text('ID: ${s.id} URL: ${s.url}')),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _select,
          tooltip: 'Select an asset',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Future<void> _select() async {
    try {
      var results = await _phPickerViewControllerPlugin.pick(
        filter: {
          'any': ['livePhotos', 'videos'],
        },
        preferredAssetRepresentationMode: AssetRepresentationMode.current,
        selection: Selection.ordered,
        selectionLimit: 3,
        fetchURL: true,
      );
      if (results == null) {
        return;
      }
      setState(() {
        _err = null;
        _results = results;
      });
    } catch (err) {
      setState(() {
        _err = err.toString();
      });
    }
  }
}
