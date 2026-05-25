import 'package:flutter/material.dart';

class ResponsiveHelper{
  // check karo k agar screen web ya tablet jitni bari h
  static bool isWebOrDesktop(BuildContext context){
    return MediaQuery.of(context).size.width>600;
  }

  // web screen sk liayay dynamic horizontal padding
  static double getHorizontalPadding(BuildContext context){
    double width = MediaQuery.of(context).size.width;
    // centers content tightly on ultra wide screens
    if(width > 1200) return width * 0.35;
    // standard web padding
    if(width > 600) return width * 0.2;
    // standard mobile padding
    return 20.0;
  }

}


