import 'dart:io'; // for File
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:file_picker/file_picker.dart';
import 'package:all_sensors2/all_sensors2.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'loadCsvDataScreen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sensors Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<double>? _accelerometerValues;
  List<double>? _gyroscopeValues;
  List<StreamSubscription<dynamic>> _streamSubscriptions = <StreamSubscription<dynamic>>[];

  @override
  Widget build(BuildContext context) {
    final List<String>? accelerometer =
    _accelerometerValues?.map((double v) => v.toStringAsFixed(1))?.toList();
    final List<String>? gyroscope =
    _gyroscopeValues?.map((double v) => v.toStringAsFixed(1))?.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sensor Example'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Padding(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('Accelerometer: $accelerometer'),
              ],
            ),
            padding: const EdgeInsets.all(16.0),
          ),
          Padding(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('Gyroscope: $gyroscope'),
              ],
            ),
            padding: const EdgeInsets.all(16.0),
          ),
          InkWell(
            onTap: (){
             csvDataView(context,accelerometer!);
            },
            child: Text('CLick me'),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    for (StreamSubscription<dynamic> subscription in _streamSubscriptions) {
      subscription.cancel();
    }
  }

  @override
  void initState() {
    _streamSubscriptions
        .add(accelerometerEvents!.listen((AccelerometerEvent event) {
      setState(() {
        _accelerometerValues = <double>[DateTime.now().millisecondsSinceEpoch.toDouble(),event.x, event.y, event.z];
      });
    }));
    _streamSubscriptions.add(gyroscopeEvents!.listen((GyroscopeEvent event) {
      setState(() {
        _gyroscopeValues = <double>[DateTime.now().millisecondsSinceEpoch.toDouble(),event.x, event.y, event.z];
      });
    }));
    super.initState();

  }
  Future<void> csvDataView(context,List list) async{
  List<List<dynamic>> csvData=[
    ["time",'z','y','x'],
    list,
  ];
  String csv=ListToCsvConverter().convert(csvData);
  final String dir=(await getApplicationSupportDirectory()).path;
  final String path='$dir/${DateTime.now()} Accelrometer.csv';
  final  File file = File(path);
  await file.writeAsString(csv,mode: FileMode.append);
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) {
        return LoadCsvDataScreen(path: path);
      },
    ),
  );
  // await file.writeAsString(csvData);
  }
}