import 'package:covid_19/constant.dart';
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

class Counter extends StatefulWidget {
  var myGroup = AutoSizeGroup();
  final int number;
  final int deltanumber;
  final Color color;
  final String title;
   Counter({
    Key key,
    this.myGroup,
    this.deltanumber,
    this.number,
    this.color,
    this.title,
  }) : super(key: key);

  @override
  _CounterState createState() => _CounterState();
}

class _CounterState extends State<Counter> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(6),
          height: 25,
          width: 25,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color.withOpacity(.26),
          ),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.transparent,
              border: Border.all(
                color: widget.color,
                width: 2,
              ),
            ),
          ),
        ),
        SizedBox(height: 10),

        Text(
          "${widget.deltanumber}",
          style: TextStyle(
            fontSize: 12,
            color: widget.color,
          ),
        ),


        AutoSizeText(
            "${widget.number}",
          group: widget.myGroup,
          maxLines: 1,
            style: TextStyle(
              fontSize: 30,//18
              color: widget.color,
            ),
          ),



        AutoSizeText(widget.title, style: kSubTextStyle,maxLines: 1,),
      ],
    );
  }
}


