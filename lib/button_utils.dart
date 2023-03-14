import 'dart:async';

import 'package:flutter/material.dart';

class ButtonUtils {
  static const buttonTextStyle = TextStyle(color: Colors.white);

  static Widget blueButtonWithProgressThatChangesOnCompletion(
      String textString, Function onPressed, Widget widgetAfterCompletion) {
    return RaisedButtonWithProgress(
      textString,
      onPressed,
      Colors.blue,
      widgetAfterCompletion: widgetAfterCompletion,
    );
  }

  static Widget blueButtonWithProgress(String textString, {required VoidCallback onPressed}) {
    return RaisedButtonWithProgress(
      textString,
      onPressed,
      Colors.blue,
    );
  }

  static RaisedButtonWithProgress brownButtonWithProgress(String textString, {VoidCallback? onPressed}) {
    return RaisedButtonWithProgress(
      textString,
      onPressed,
      Colors.brown,
    );
  }
}

class ButtonWithTextChange extends StatefulWidget {
  final Function onPressed;

  const ButtonWithTextChange(this.onPressed, {super.key});

  @override
  ButtonWithTextChangeState createState() => ButtonWithTextChangeState();
}

class ButtonWithTextChangeState extends State<ButtonWithTextChange> {
  String text = '';

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        text,
        style: const TextStyle(fontSize: 8),
      ),
    );
  }

  onPressed() async {
    if (text.isEmpty) {
      text = await widget.onPressed();
    } else {
      text = '';
    }
    setState(() {});
  }
}

class RaisedButtonWithProgress extends StatefulWidget {
  Function? onPressed;
  final String textString;
  final Color buttonColor;
  final Widget? widgetAfterCompletion;

  RaisedButtonWithProgress(
    this.textString,
    this.onPressed,
    this.buttonColor, {
    super.key,
    this.widgetAfterCompletion,
  });

  _RaisedButtonWithProgressState? _state;

  /// Provided for functions whose callBack actions complete immediately.
  void overrideProgress() {
    _state!.overrideState();
  }

  @override
  State<StatefulWidget> createState() {
    _state = _RaisedButtonWithProgressState();
    return _state!;
  }
}

class _RaisedButtonWithProgressState extends State<RaisedButtonWithProgress> with TickerProviderStateMixin {
  int _state = 0;
  bool _completed = false;

  @override
  Widget build(BuildContext context) {
    if (_completed && widget.widgetAfterCompletion != null) {
      return widget.widgetAfterCompletion!;
    }

    return ElevatedButton(
      style: OutlinedButton.styleFrom(
        shape: const StadiumBorder(),
        backgroundColor: widget.buttonColor,
      ),
      onPressed: () async {
        setState(() {
          if (_state == 0) {
            _state = 1;
          }
        });

        await Future(widget.onPressed as FutureOr Function()).then((_) {
          setState(() {
            _state = 0;
            _completed = true;
          });
        });
      },
      child: Padding(
        padding: const EdgeInsets.all(3.0),
        child: setUpButtonChild(),
      ),
    );
  }

  Widget setUpButtonChild() {
    if (_state == 0) {
      return Text(
        widget.textString,
        style: ButtonUtils.buttonTextStyle,
      );
    } else if (_state == 1) {
      return const CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      );
    } else {
      return const Icon(
        Icons.check,
        color: Colors.white,
      );
    }
  }

  void overrideState() {
    setState(() {
      if (_state == 0) {
        _state = 1;
      } else {
        _state = 0;
      }
    });
  }

  void animateButton() {
//    Timer(Duration(milliseconds: 3300), () {
//      setState(() {
//        _state = 2;
//      });
//    });
  }
}
