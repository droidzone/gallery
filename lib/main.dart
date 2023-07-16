import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:gallery/stores/app_state.dart';
import 'package:gallery/stores/appstate.middleware.dart';
import 'package:gallery/stores/initial_state.dart';
import 'package:gallery/stores/reducer.dart';
import 'package:gallery/views/start_view.dart';
import 'package:logging/logging.dart';
import 'package:redux/redux.dart';

Future<void> main() async {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    // print(
    //     '${record.level.name}: ${record.time}: ${record.loggerName}: ${record.message}');
    print('Gallery: ${record.loggerName}: ${record.message}');
  });
  WidgetsFlutterBinding.ensureInitialized();

  final store = Store<AppState>(
    updateReducer,
    middleware: [loadFilesMiddleware],
    initialState: initialState,
  );
  // final store = DevToolsStore<AppState>(
  //   updateReducer,
  //   middleware: [loadFilesMiddleware],
  //   initialState: initialState,
  // );
  runApp(MyApp(
    store: store,
  ));
}

class MyApp extends StatelessWidget {
  final Store<AppState> store;

  const MyApp({super.key, required this.store});

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
        home: StartView(),
      ),
    );
  }
}
