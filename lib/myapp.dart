import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:to_do_list/screens/home_page.dart';
import 'provider/todo_provider.dart';
import 'utils/theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ToDoProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'TO DO List',
        theme: buildTheme(),
        home: const HomePage(),
      ),
    );
  }
}
