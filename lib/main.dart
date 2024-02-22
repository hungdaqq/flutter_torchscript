import 'package:pytorch_lite_example/run_model_by_camera_demo.dart';
import 'package:pytorch_lite_example/run_model_by_image_demo.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  runApp(const BottomNavigationBarApp());
}

class BottomNavigationBarApp extends StatelessWidget {
  const BottomNavigationBarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: BottomNavigationBarExample(),
    );
  }
}

class BottomNavigationBarExample extends StatefulWidget {
  const BottomNavigationBarExample({super.key});

  @override
  State<BottomNavigationBarExample> createState() =>
      _BottomNavigationBarExampleState();
}

class _BottomNavigationBarExampleState
    extends State<BottomNavigationBarExample> {
  int _selectedIndex = 0;
  List<Widget>? _widgetOptions;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initPages();
    });
  }

  initPages() async {
    _widgetOptions = [
      const RunModelByImageDemo(),
      const RunModelByCameraDemo()
    ];
    setState(() {});
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white38,
        centerTitle: true,
        toolbarHeight: 36,
        // title: Image.asset('assets/images/tfl_logo.png'),
        title: const Text(
          "ĐATN PHÂN LOẠI HÀNH VI TÀI XẾ",
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.image),
            onPressed: () => _onItemTapped(0),
          ),
          IconButton(
            icon: const Icon(Icons.camera),
            onPressed: () => _onItemTapped(1),
          ),
        ],
      ),
      body: Center(
        child: _widgetOptions?.elementAt(_selectedIndex),
      ),
    );
  }
}
