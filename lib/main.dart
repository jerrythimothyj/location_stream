import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:poly/poly.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void main() => runApp(MyApp());

Location location = new Location();
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

bool _serviceEnabled;
PermissionStatus _permissionGranted;

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  double _latitude = 0;
  double _longitude = 0;
  bool _isUserInsideFence = false;
  Polygon copyOfFirstPolygon = Polygon([
    // Point(18.4851825, 73.8498851),
    // Point(18.4849214, 73.8498675),
    // Point(18.4855965, 73.8520493),
    // Point(18.4859711, 73.8512369),
    // Point(18.4857828, 73.8500299),
    // Point(18.4851825, 73.8498851)

    Point(25.101207, 55.173328),
    Point(25.101044, 55.172996),
    Point(25.100772, 55.173214),
    Point(25.100993, 55.173519),
    Point(25.101207, 55.173328),
  ]);

  @override
  initState() {
    super.initState();

    var initializationSettingsAndroid =
        new AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);

    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
  }

  Future onSelectNotification(String payload) async {
    showDialog(
        context: context,
        builder: (_) => new AlertDialog(
            title: const Text("Here is your payload"),
            content: new Text("Payload: $payload")));
  }

  // Method 1
  Future _showNotificationWithSound(isUserInsideFence) async {
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        'your channel id', 'your channel name', 'your channel description',
        sound: 'slow_spring_board',
        importance: Importance.Max,
        priority: Priority.High);
    var iOSPlatformChannelSpecifics =
        new IOSNotificationDetails(sound: "slow_spring_board.aiff");
    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      'User fence status changed',
      'user inside fence: $isUserInsideFence',
      platformChannelSpecifics,
      payload: 'Custom_Sound',
    );
  }

  void _incrementCounter() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.DENIED) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.GRANTED) {
        return;
      }
    }

    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter = 0;
      _latitude = 0;
      _longitude = 0;
      _isUserInsideFence = false;
    });

    // _locationData = await location.getLocation();
    // print(_locationData);

    location.onLocationChanged().listen((LocationData currentLocation) {
      // print(currentLocation);

      var newIsUserInsideFence = copyOfFirstPolygon.contains(
          currentLocation.latitude, currentLocation.longitude);

      if (newIsUserInsideFence != _isUserInsideFence) {
        print("state is changing");
        _showNotificationWithSound(newIsUserInsideFence);
      }

      setState(() {
        // This call to setState tells the Flutter framework that something has
        // changed in this State, which causes it to rerun the build method below
        // so that the display can reflect the updated values. If we changed
        // _counter without calling setState(), then the build method would not be
        // called again, and so nothing would appear to happen.
        _counter++;
        _latitude = currentLocation.latitude;
        _longitude = currentLocation.longitude;
        _isUserInsideFence = copyOfFirstPolygon.contains(
            currentLocation.latitude, currentLocation.longitude);
      });

      print(
          "$_counter. Polygon a contains :(${currentLocation.latitude}, ${currentLocation.longitude}) - $_isUserInsideFence");
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            Text(
              'Latitude: $_latitude',
            ),
            Text(
              'Longitude: $_longitude',
            ),
            Text(
                "$_counter. Polygon a contains :($_latitude, $_longitude) - ${copyOfFirstPolygon.contains(_latitude, _longitude)}"),
            // new RaisedButton(
            //   onPressed: _showNotificationWithSound,
            //   child: new Text('Show Notification With Sound'),
            // ),
            new SizedBox(
              height: 30.0,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
