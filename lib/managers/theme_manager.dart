import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class IdehShopTheme {
  const IdehShopTheme(this.name, this.data);

  final String name;
  final ThemeData data;
}

IdehShopTheme lightIdehShopTheme = IdehShopTheme('Light', _buildLightTheme());

ThemeData _buildLightTheme() {
  const Color primaryColor = Color.fromRGBO(0, 154, 226, 1.0);
  const Color primaryColorLight = Color.fromRGBO(0, 188, 226, 1.0);
  const Color secondaryColor = Color.fromRGBO(0, 86, 152, 1.0);
  // const Color secondaryColor = Color.fromRGBO(50, 180, 232, 1.0);
  final ThemeData base = ThemeData.light();
  final ColorScheme colorScheme = const ColorScheme.light().copyWith(
    primary: primaryColor,
    secondary: secondaryColor,
  );
  return base.copyWith(
    accentColor: secondaryColor,
    accentColorBrightness: Brightness.light,
    accentIconTheme: IconThemeData(
      color: Color.fromRGBO(255, 255, 255, 1.0),
      size: 25.0,
    ),
    accentTextTheme: base.accentTextTheme.apply(
      fontFamily: 'Shabnam-Light-FD',
    ),
    appBarTheme: AppBarTheme(
      brightness: Brightness.dark,
      textTheme: TextTheme(
        headline6: TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
          fontFamily: 'Shabnam-Light-FD',
        ),
      ),
    ),
    backgroundColor: secondaryColor,
    brightness: Brightness.light,
    buttonColor: secondaryColor,
    buttonTheme: ButtonThemeData(
      buttonColor: secondaryColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          5.0,
        ),
      ),
    ),
    cardTheme: base.cardTheme.copyWith(
      elevation: 0.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.zero),
        side: BorderSide(
          style: BorderStyle.none,
        ),
      ),
      margin: EdgeInsets.all(
        0.0,
      ),
    ),
    chipTheme: base.chipTheme.copyWith(
      labelStyle: TextStyle(
        fontFamily: 'Shabnam-Light-FD',
      ),
      secondaryLabelStyle: TextStyle(
        fontFamily: 'Shabnam-Light-FD',
      ),
    ),
    colorScheme: colorScheme,
    disabledColor: Colors.grey,
    errorColor: Colors.redAccent,
    floatingActionButtonTheme: base.floatingActionButtonTheme.copyWith(
      foregroundColor: secondaryColor,
      backgroundColor: secondaryColor,
      elevation: 0.0,
    ),
    iconTheme: base.iconTheme.copyWith(
      color: secondaryColor,
      size: 25.0,
    ),
    indicatorColor: secondaryColor,
    inputDecorationTheme: InputDecorationTheme(
      fillColor: Colors.white,
      filled: true,
      border: OutlineInputBorder(
        borderSide: BorderSide(
          style: BorderStyle.solid,
          color: base.accentColor,
        ),
      ),
      contentPadding: EdgeInsets.all(10.0),
      labelStyle: TextStyle(
        fontSize: 16.0,
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: base.accentColor,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: base.accentColor),
        borderRadius: BorderRadius.circular(12),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: base.errorColor),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: base.accentColor),
        borderRadius: BorderRadius.circular(12),
      ),
      hintStyle: TextStyle(fontSize: 15),
    ),
    primaryColor: primaryColor,
    primaryColorBrightness: Brightness.light,
    primaryColorLight: primaryColor,
    primaryIconTheme: IconThemeData(
      color: secondaryColor,
      size: 25.0,
    ),
    primaryTextTheme: base.primaryTextTheme
        .copyWith(
          caption: base.primaryTextTheme.caption.copyWith(
            color: primaryColorLight,
          ),
          headline5: base.primaryTextTheme.headline5.copyWith(
            color: Color.fromRGBO(40, 46, 52, 1.0),
          ),
          overline: base.primaryTextTheme.overline.copyWith(
            color: Color.fromRGBO(40, 46, 52, 1.0),
          ),
          subtitle1: base.primaryTextTheme.subtitle1.copyWith(
            color: primaryColorLight,
          ),
        )
        .apply(
          fontFamily: 'Shabnam-Light-FD',
        ),
    scaffoldBackgroundColor: Colors.grey[200],
    snackBarTheme: base.snackBarTheme.copyWith(
      backgroundColor: secondaryColor,
      actionTextColor: secondaryColor,
      contentTextStyle: base.textTheme.bodyText2.copyWith(
        color: Colors.white,
      ),
      behavior: SnackBarBehavior.fixed,
    ),
    tabBarTheme: TabBarTheme(
      labelStyle: TextStyle(
        fontSize: 16.0,
        fontFamily: 'Shabnam-Light-FD',
        fontWeight: FontWeight.bold,
      ),
      unselectedLabelStyle: TextStyle(
        fontSize: 16.0,
        fontFamily: 'Shabnam-Light-FD',
        fontWeight: FontWeight.bold,
      ),
    ),
    textTheme: base.textTheme
        .copyWith(
          // large & head texts
          headline5: base.primaryTextTheme.headline5.copyWith(
            color: Color.fromRGBO(40, 46, 52, 1.0),
            fontFamily: 'Shabnam-Light-FD',
            fontSize: 22.0,
          ),
          // primary & head texts
          subtitle1: base.primaryTextTheme.subtitle1.copyWith(
            color: Color.fromRGBO(40, 46, 52, 1.0),
            fontFamily: 'Shabnam-Light-FD',
            fontSize: 18.0,
          ),
          // primary text , bold
          headline6: base.textTheme.headline6.copyWith(
            color: Color.fromRGBO(40, 46, 52, 1.0),
            fontFamily: 'Shabnam-Light-FD',
            fontSize: 20.0,
          ),
          // little smaller than subtitle1 , bold
          subtitle2: base.textTheme.subtitle2.copyWith(
            color: Color.fromRGBO(40, 46, 52, 1.0),
            fontFamily: 'Shabnam-Light-FD',
            fontSize: 16.0,
          ),
          // smallest style
          overline: base.textTheme.overline.copyWith(
            color: Color.fromRGBO(40, 46, 52, 1.0),
            fontFamily: 'Shabnam-Light-FD',
            fontSize: 12.0,
          ),
          // default
          bodyText2: base.textTheme.bodyText2.copyWith(
            color: Color.fromRGBO(40, 46, 52, 1.0),
            fontFamily: 'Shabnam-Light-FD',
            fontSize: 14.0,
            fontWeight: FontWeight.bold,
          ),
          // emphasizing bodyText2
          bodyText1: base.textTheme.bodyText1.copyWith(
            color: Color.fromRGBO(40, 46, 52, 1.0),
            fontFamily: 'Shabnam-Light-FD',
            fontSize: 14.0,
          ),
          // large & bold style
          headline4: base.textTheme.headline4.copyWith(
            color: Color.fromRGBO(40, 46, 52, 1.0),
            fontFamily: 'Shabnam-Light-FD',
            fontSize: 20.0,
          ),
          // large style
          headline3: base.textTheme.headline3.copyWith(
            color: Color.fromRGBO(40, 46, 52, 1.0),
            fontFamily: 'Shabnam-Light-FD',
            fontSize: 22.0,
          ),
          // large style
          headline2: base.textTheme.headline2.copyWith(
            color: Color.fromRGBO(40, 46, 52, 1.0),
            fontFamily: 'Shabnam-Light-FD',
            fontSize: 24.0,
          ),
          // large style
          headline1: base.textTheme.headline1.copyWith(
            color: Color.fromRGBO(40, 46, 52, 1.0),
            fontFamily: 'Shabnam-Light-FD',
            fontSize: 26.0,
          ),
          // auxiliary text for images
          caption: base.textTheme.caption.copyWith(
            color: Color.fromRGBO(40, 46, 52, 1.0),
            fontFamily: 'Shabnam-Light-FD',
            fontSize: 13.0,
          ),
          // raised button & flat button
          button: base.textTheme.button.copyWith(
            color: Colors.white,
            fontFamily: 'Shabnam-Light-FD',
            fontWeight: FontWeight.bold,
          ),
        )
        .apply(
          fontFamily: 'Shabnam-Light-FD',
        ),
    toggleableActiveColor: secondaryColor,
  );
}
