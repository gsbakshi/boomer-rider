import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import './providers/auth.dart';

import './screens/splash_screen.dart';
import './screens/auth_screen.dart';
import './screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: Auth(),
        ),
      ],
      child: Consumer<Auth>(
        builder: (ctx, auth, _) => MaterialApp(
          title: 'Boomer Rider App',
          debugShowCheckedModeBanner: false,
          theme: themeData,
          home: auth.isAuth
              ? HomeScreen()
              : FutureBuilder(
                  future: auth.tryAutoLogin(),
                  builder: (ctx, snapshot) =>
                      snapshot.connectionState == ConnectionState.waiting
                          ? SplashScreen()
                          : AuthScreen(),
                ),
          routes: routes,
        ),
      ),
    );
  }

  Map<String, WidgetBuilder> get routes {
    return {
      SplashScreen.routeName: (ctx) => SplashScreen(),
      AuthScreen.routeName: (ctx) => AuthScreen(),
      HomeScreen.routeName: (ctx) => HomeScreen(),
    };
  }
}

final themeData = ThemeData(
  primarySwatch: Colors.grey,
  primaryColor: Colors.white,
  accentColor: Color(0xffD1793F),
  fontFamily: 'Open Sans',
  focusColor: Color(0xffD1793F),
  textTheme: TextTheme(
    headline4: TextStyle(
      fontSize: 24,
      color: Color(0xffD1793F),
      fontWeight: FontWeight.w700,
    ),
    headline5: TextStyle(
      fontSize: 20,
      color: Colors.white,
      fontWeight: FontWeight.w700,
    ),
  ),
  scaffoldBackgroundColor: Color(0xff423833),
  appBarTheme: AppBarTheme(
    backgroundColor: Color(0xff423833),
    iconTheme: IconThemeData(
      color: Color(0xffD1793F),
    ),
    textTheme: TextTheme(
      headline6: TextStyle(
        color: Color(0xffD1793F),
        fontSize: 20,
      ),
    ),
  ),
);
