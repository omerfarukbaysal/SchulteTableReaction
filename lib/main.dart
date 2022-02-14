import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Schulte Table Reaction',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Schulte Table Reaction'),
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
  bool flag = true;
  Stream<int> timerStream;
  StreamSubscription<int> timerSubscription;
  Stream<int> stopWatchStream() {
    StreamController<int> streamController;
    Timer timer;
    Duration timerInterval = Duration(milliseconds: 1);
    int counter = 0;

    void stopTimer() {
      if (timer != null) {
        timer.cancel();
        timer = null;
        counter = 0;
        streamController.close();
      }
    }

    void tick(_) {
      counter++;
      streamController.add(counter);
      if (!flag) {
        stopTimer();
      }
    }

    void startTimer() {
      timer = Timer.periodic(timerInterval, tick);
    }

    streamController = StreamController<int>(
      onListen: startTimer,
      onCancel: stopTimer,
      onResume: startTimer,
      onPause: stopTimer,
    );

    return streamController.stream;
  }

  var stopwatch = new Stopwatch();

  List<int> numbers = [
    1,
    2,
    3,
    4,
    5,
    6,
    7,
    8,
    9,
    10,
    11,
    12,
    13,
    14,
    15,
    16,
    17,
    18,
    19,
    20,
    21,
    22,
    23,
    24,
    25,
  ];

  int number = 1;
  bool isFinished = false;
  String milisecondsStr = '00';
  String secondsStr = '00';
  double score = 0;

  // List shuffle function
  List shuffle(List items) {
    var random = new Random();
    for (var i = items.length - 1; i > 0; i--) {
      var n = random.nextInt(i + 1);
      var temp = items[i];
      items[i] = items[n];
      items[n] = temp;
    }
    return items;
  }

  @override
  void initState() {
    super.initState();

    // Shuffle the list
    shuffle(numbers);

    // Start stopwatch and listen
    stopwatch.start();
    timerStream = stopWatchStream();
    timerSubscription = timerStream.listen((int newTick) {
      setState(() {
        secondsStr = (stopwatch.elapsed.inSeconds).toString();
        milisecondsStr = (stopwatch.elapsedMilliseconds % 1000).toString();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
            margin: EdgeInsets.only(top: 20, bottom: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                  children: [
                    Text("Best Score:"),
                    Text('$score'),
                  ],
                ),
                Row(
                  children: [
                    Text("Timer:"),
                    Text(
                      '$secondsStr.$milisecondsStr',
                    ),
                  ],
                ),
              ],
            ),
          ),
          Flexible(
            child: Container(
              child: GridView.count(
                crossAxisCount: 5,
                children: List.generate(25, (index) {
                  return Container(
                    decoration: BoxDecoration(
                      color: (numbers[index] == number) ? Colors.green : Colors.transparent,
                      border: Border.all(
                        width: 1,
                      ),
                    ),
                    child: InkWell(
                      onTap: () {
                        if ((number) == numbers[index]) {
                          // Chosen number is correct
                          if (number == 25) {
                            // The game has ended
                            double temp = double.parse(secondsStr + "." + milisecondsStr);
                            if (temp < score || score == 0) {
                              score = temp;
                            }

                            timerSubscription.cancel();
                            timerStream = null;
                            stopwatch.stop();
                            stopwatch.reset();
                            setState(() {
                              secondsStr = '00';
                              milisecondsStr = '00';
                            });
                            isFinished = true;
                          }
                          number += 1;
                        }
                      },
                      child: Center(
                          child: Visibility(
                        visible: (numbers[index] == number) ? true : false,
                        child: Text(
                          '${numbers[index]}',
                          style: Theme.of(context).textTheme.headline5,
                        ),
                      )),
                    ),
                  );
                }),
              ),
            ),
          ),
          Container(
              margin: EdgeInsets.only(bottom: 100),
              child: Visibility(
                visible: isFinished,
                child: RaisedButton(
                    onPressed: () {
                      setState(() {
                        // Shuffle list of numbers and set the next number to 1
                        shuffle(numbers);
                        number = 1;

                        // Reset the stopwatch and start it again
                        stopwatch.stop();
                        stopwatch.reset();
                        stopwatch.start();
                        timerStream = stopWatchStream();
                        timerSubscription = timerStream.listen((int newTick) {
                          setState(() {
                            secondsStr = (stopwatch.elapsed.inSeconds).toString();
                            milisecondsStr = (stopwatch.elapsedMilliseconds % 1000).toString();
                          });
                        });

                        // Hide "Play Again" Button
                        isFinished = false;
                      });
                    },
                    child: Text("Play Again")),
              ))
        ],
      ),
    );
  }
}
