import 'package:flutter/material.dart';
import 'screens/admin_screen/main_layout.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const MiAppWeb());
}

class MiAppWeb extends StatelessWidget {
  const MiAppWeb({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'WIN BIN :D',
      theme: ThemeData(fontFamily: 'Courier'),
      home: const MainLayout(),
    );
  }
}
