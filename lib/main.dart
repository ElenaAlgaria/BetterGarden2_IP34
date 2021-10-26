import 'package:biodiversity/models/garden.dart';
import 'package:biodiversity/models/global_model.dart';
import 'package:biodiversity/models/information_object_amount_container.dart';
import 'package:biodiversity/models/map_interactions_container.dart';
import 'package:biodiversity/models/user.dart';
import 'package:biodiversity/screens/login_page/login_page.dart';
import 'package:biodiversity/screens/my_garden_page/my_garden_page.dart';
import 'package:biodiversity/services/service_provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

/// The mainActivity of the flutter app
// ignore: use_key_in_widget_constructors
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _initialization = Firebase.initializeApp();

    return ModelBinding(
      initialModel: GlobalModel(
        platform: defaultTargetPlatform,
        textDirection: TextDirection.ltr,
      ),
      child: FutureBuilder(
        future: _initialization,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('Something went wrong'),
            );
          }
          if (snapshot.connectionState == ConnectionState.done) {
            // load services and the related content
            ServiceProvider.instance;
            return MultiProvider(
              providers: [
                ChangeNotifierProvider(
                  create: (context) => User.empty(),
                  lazy: false,
                ),
                ChangeNotifierProxyProvider<User, Garden>(
                    create: (context) => Garden.empty(),
                    update: (context, user, garden) =>
                        garden..loadGardenFromUser(user),
                    lazy: false),
                ChangeNotifierProvider(
                    create: (context) => MapInteractionContainer.empty()),
                ChangeNotifierProvider(
                    create: (context) => InformationObjectAmountContainer())
              ],
              child: MaterialApp(
                title: 'Better Gardens',
                theme: ThemeData(
                  buttonBarTheme: const ButtonBarThemeData(
                      alignment: MainAxisAlignment.spaceBetween),
                  // This is the theme of your application.
                  //brightness: Brightness.dark, // set this for darkmode
                  primarySwatch: createMaterialColor(const Color(0xFFC05410)),

                  disabledColor:
                      Theme.of(context).colorScheme.onPrimary.withOpacity(0.5),
                  dividerColor: Colors.grey,
                  bottomSheetTheme: const BottomSheetThemeData(
                      backgroundColor: Colors.yellow,
                      modalBackgroundColor: Colors.orange),
                  errorColor: Colors.redAccent,
                  // This makes the visual density adapt to the platform that you
                  // run the app on. For desktop platforms, the controls will be
                  // smaller and closer together
                  // (more dense)
                  // than on mobile platforms.
                  visualDensity: VisualDensity.adaptivePlatformDensity,
                ),
                home: auth.FirebaseAuth.instance.currentUser != null
                    ? MyGarden()
                    : LoginPage(),
              ),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  ///Creates a MaterialColor from a given Color
  MaterialColor createMaterialColor(Color color) {
    List strengths = <double>[.05];
    Map swatch = <int, Color>{};
    final r = color.red, g = color.green, b = color.blue;

    for (var i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    strengths.forEach((strength) {
      final ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    });
    return MaterialColor(color.value, swatch);
  }
}
