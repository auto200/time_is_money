import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

void showLayoutGuidelines() {
  debugPaintSizeEnabled = true;
}

void main() {
  runApp(const MyApp());
  // showLayoutGuidelines();
}

final MILLISECONDS_IN_HOUR = const Duration(hours: 1).inMilliseconds;

String formatDuration(Duration d) =>
    d.toString().split('.').first.padLeft(8, "0");

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Time is Money',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Time is Money'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  num _hourlyWage = 1000;
  num _earnings = 0;
  DateTime? _lastTickTime;
  Timer? _timer;
  Duration _totalElapsedMilliseconds = const Duration();
  late num _earningsPerMillisecond = _hourlyWage / MILLISECONDS_IN_HOUR;

  final _formKey = GlobalKey<FormState>();

  void setHourlyWage(num wage) {
    setState(() {
      _hourlyWage = wage;
      _earningsPerMillisecond = _hourlyWage / MILLISECONDS_IN_HOUR;
    });
  }

  void toggleTimer() {
    if (_timer != null) {
      _timer?.cancel();
      setState(() {
        _timer = null;
        _lastTickTime = null;
      });
      return;
    }
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (_lastTickTime == null) {
        _lastTickTime = DateTime.now();
        return;
      }
      setState(() {
        final elapsedMilliseconds =
            DateTime.now().difference(_lastTickTime!).inMilliseconds;
        _earnings += _earningsPerMillisecond * elapsedMilliseconds;
        _lastTickTime = DateTime.now();
        _totalElapsedMilliseconds = _totalElapsedMilliseconds +
            Duration(milliseconds: elapsedMilliseconds);
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Tak Ci leci pitos modro:',
            ),
            Text("Your hourly wage: $_hourlyWage"),
            Text("Elapsed time: ${formatDuration(_totalElapsedMilliseconds)}"),
            Text(
              '${_earnings.toStringAsFixed(2)} zł', // TODO: change fixed currency
              style: Theme.of(context).textTheme.headline4,
            ),
            RawMaterialButton(
              onPressed: toggleTimer,
              elevation: 2.0,
              fillColor: Colors.white,
              padding: const EdgeInsets.all(15.0),
              shape: const CircleBorder(),
              child: Icon(
                _timer == null ? Icons.play_arrow : Icons.pause,
                size: 35.0,
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
                  title: const Text("Set hourly wage"),
                  content: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            initialValue: _hourlyWage.toString(),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            decoration: const InputDecoration(
                              hintText: "Hourly wage",
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Provide correct value";
                              }
                            },
                            onSaved: (value) {
                              if (value == null) return;
                              // TODO: check if there is a better solution
                              final isProbablyDouble = value.contains(".");
                              final number = isProbablyDouble
                                  ? double.tryParse(value)
                                  : int.tryParse(value);
                              if (number == null) return;
                              setHourlyWage(number);
                            },
                          ),
                          DropdownButtonFormField(
                            value: "PLN",
                            items: const <String>["PLN", "asdf"]
                                .map((el) => DropdownMenuItem(
                                      value: el,
                                      child: Text(el),
                                    ))
                                .toList(),
                            onChanged: (_) {},
                          ),
                        ],
                      ),
                    ),
                  ),
                  actions: <Widget>[
                    TextButton(
                        onPressed: () {
                          if (_formKey.currentState == null) return;
                          if (!_formKey.currentState!.validate()) return;
                          _formKey.currentState!.save();
                          Navigator.of(context).pop();
                        },
                        child: const Text("ok"))
                  ],
                )),
        tooltip: 'Increment',
        child: const Icon(Icons.settings),
      ),
    );
  }
}
