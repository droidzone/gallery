import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:gallery/stores/app_state.dart';
import 'package:gallery/stores/initial_state.dart';
import 'package:gallery/stores/reducer.dart';
import 'package:gallery/views/start_view.dart';
import 'package:redux/redux.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final store = Store<AppState>(
    updateReducer,
    // middleware: [fetchAppointmentsMiddleware],
    initialState: initialState,
  );
  runApp(MyApp(
    store: store,
  ));
}

class MyApp extends StatelessWidget {
  final Store<AppState> store;

  MyApp({super.key, required this.store});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return StoreProvider(
      store: store,
      child: MaterialApp(
        title: 'Super Gallery',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const StartView(),
      ),
    );
  }
}
