import 'package:flutter/material.dart';

const headerStyle =
    TextStyle(fontSize: 35, fontWeight: FontWeight.w900, fontFamily: 'Corben');
const subHeaderStyle = TextStyle(
    fontSize: 16.0, fontWeight: FontWeight.w500, fontFamily: 'Corben');
const statsStyle = TextStyle(
    fontSize: 12.0, fontWeight: FontWeight.w300, fontFamily: 'Corben');
const poemStyle = TextStyle(
    fontSize: 23.0, fontWeight: FontWeight.w500, fontFamily: 'Corben');
const poemStyleT = TextStyle(
    fontSize: 24.0,
    fontWeight: FontWeight.w700,
    fontFamily: 'Corben',
    fontStyle: FontStyle.italic,
    height: 1.5);

const poemBadgeStyle = TextStyle(
    fontSize: 30.0,
    fontWeight: FontWeight.w500,
    fontFamily: 'Corben',
    color: Colors.black45,
    backgroundColor: Colors.black12);

var poemBadgeStyleRed = TextStyle(
    fontSize: 30.0,
    fontWeight: FontWeight.w500,
    fontFamily: 'Corben',
    color: Colors.black45,
    backgroundColor: Colors.red.shade100);

// class with attribute for text
class AttrString {
  String text;
  String attr;

  AttrString(this.text, this.attr);
}
