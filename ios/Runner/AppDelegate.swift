import UIKit
import Flutter
import GoogleMaps
import Firebase

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate{
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    //set api key for maps
    GMSServices.provideAPIKey("AIzaSyCluGMsV1MadS-nQpHqkmCe7OgV4-pTUek")

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
