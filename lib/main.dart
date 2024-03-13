import 'package:async_flutter/home_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const HomeScreen(),
        routes: <String, WidgetBuilder>{
          '/home': (BuildContext context) => const HomeScreen(),
        });
  }
}


// lấy dữ liệu từ api
// hiển thị lên màn hình
// chưa lấy xong: hiển thị icon loading
// lấy xong dữ liệu hiển thị lên màn hình