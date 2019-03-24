import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:string_mask/string_mask.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Awake!',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Awake!'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String number;
  bool valid = false;
  TimeOfDay _time = new TimeOfDay.now();
  bool timeChosen = false;
  bool numberAdded = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  var snack = new SnackBar(content: new Text("Call successfully scheduled"));

  Future<Null> selectTime(BuildContext context) async {
    final TimeOfDay picked =
        await showTimePicker(context: context, initialTime: _time);
    if (picked != null) {
      timeChosen = true;
      debugPrint("Date selected ${picked.toString()}");
      setState(() {
        _time = picked;
      });
    }
  }

  void submitNumber() {
    debugPrint(number);
    if (number != null) {
      debugPrint(number);
      var url = "https://kay59oc7qj.execute-api.us-east-1.amazonaws.com/prod";
      http
          .post(url,
              body:
                  '{"name": "null", "number": "+1${number.toString()}", "day": "Saturday"}')
          .then((response) {
        print("Response status: ${response.statusCode}");
        print("Response body: ${response.body}");
        _scaffoldKey.currentState.showSnackBar(snack);
      });
    } else
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Invalid Phone Number'),
            content: null,
            actions: <Widget>[
              FlatButton(
                child: Text('Ok'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
  }

  Future<Null> getPhoneNumber() async {
    var string = await showDialog(
        context: context,
        child: new AlertDialog(
          title: new Text('Enter Phone Number:'),
          content: new Container(
            child: TextField(
              keyboardType: TextInputType.numberWithOptions(
                  decimal: false, signed: false),
              inputFormatters: [
                BlacklistingTextInputFormatter(
                    new RegExp('[\\-|\\ |\\, | \\.]'))
              ],
              style: Theme.of(context).textTheme.display1,
              onChanged: (val) => validateNumber(val),
              onEditingComplete: () {
                Navigator.pop(context, number);
              },
            ),
          ),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Ok"),
              onPressed: () {
                Navigator.pop(context, number);
              },
            )
          ],
        ));
    debugPrint(number);
    if (number == null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Invalid Phone Number'),
            content: null,
            actions: <Widget>[
              FlatButton(
                child: Text('Ok'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return;
    }
    if (isValidNumber(number)) {
      var formatter = new StringMask('0000000000');
      number = formatter.apply(number);
    }
  }

  bool isValidNumber(String val) {
    if (val.length != 10) {
      return false;
    }
    return true;
  }

  String validateNumber(String val) {
    var formatter = new StringMask('0000000000');
    if (val.length != 10) {
      number = null;
      numberAdded = false;
      return "bad";
    }
    var result = formatter.apply(val);
    number = result;
    numberAdded = true;
    return result;
  }

  var readablePhoneNumber = new StringMask('(000) 000-0000');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: new Container(
        child: new Center(
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Text(
                'Schedule call to: ',
                textAlign: TextAlign.center,
                textScaleFactor: 1.2,
                style: Theme.of(context).textTheme.body1,
              ),
              new MaterialButton(
                  child: new Text(
                    '${timeChosen ? _time.format(context) : "Tap to Choose Time"}',
                    textAlign: TextAlign.center,
                    textScaleFactor: 1.0,
                    style: Theme.of(context).textTheme.display1,
                  ),
                  onPressed: () {
                    selectTime(context);
                  }),
              new MaterialButton(
                  child: new Text(
                    '${number == null ? "Add Phone Number" : readablePhoneNumber.apply(number)}',
                    textAlign: TextAlign.center,
                    textScaleFactor: .8,
                    style: Theme.of(context).textTheme.display1,
                  ),
                  onPressed: () {
                    getPhoneNumber();
                  }),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: submitNumber,
        tooltip: 'Schedule Call',
        child: Icon(Icons.phone),
      ),
    );
  }
}