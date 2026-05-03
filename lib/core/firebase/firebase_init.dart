import 'package:firebase_core/firebase_core.dart';
// After running `flutterfire configure`, this import will resolve:
import 'package:ts_management/firebase_options.dart';

Future<void> initFirebase() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}
