import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'globals.dart';
import 'routes/dashboard.dart';

void main() {
  runApp(OsumPie());
}

class OsumPie extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DynamicTheme(
      defaultBrightness: globalBrightness,
      data: (brightness) {
        final primaryColor = (brightness == Brightness.dark) ? Colors.white : Colors.blue[800];
        SystemChrome.setSystemUIOverlayStyle((brightness == Brightness.light)
            ? SystemUiOverlayStyle(
                statusBarColor: Colors.white,
                statusBarIconBrightness: Brightness.dark,
                systemNavigationBarColor: Colors.white,
                systemNavigationBarIconBrightness: Brightness.dark)
            : SystemUiOverlayStyle(
                statusBarColor: Colors.black,
                statusBarIconBrightness: Brightness.light,
                systemNavigationBarColor: Colors.black,
                systemNavigationBarIconBrightness: Brightness.light));
        return ThemeData(
            brightness: brightness,
            tabBarTheme: TabBarTheme(
              labelColor: (brightness == Brightness.dark) ? Colors.white : Colors.blueGrey,
            ),
            appBarTheme: AppBarTheme(
              iconTheme: IconThemeData(color: primaryColor),
              textTheme: TextTheme(
                  headline6: GoogleFonts.openSans(
                      textStyle: TextStyle(
                color: primaryColor,
                fontSize: 25.0,
                fontWeight: FontWeight.bold,
              ))),
              color: (brightness == Brightness.dark) ? Colors.black54 : Colors.white,
              shadowColor: (brightness == Brightness.dark) ? Colors.black54 : Colors.blueGrey[50].withOpacity(0.5),
              elevation: 13.0,
            ),
            dividerColor: Colors.blueGrey[100],
            primaryColor: Colors.blue[800],
            visualDensity: VisualDensity.adaptivePlatformDensity,
            floatingActionButtonTheme: FloatingActionButtonThemeData(
              backgroundColor: primaryColor,
            ));
      },
      themedWidgetBuilder: (context, theme) => MaterialApp(
        theme: theme,
        title: 'Osum Pie',
        home: DashboardRoute(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
