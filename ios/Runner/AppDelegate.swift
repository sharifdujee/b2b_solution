import UIKit
import Flutter
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {

  override func application(
      _ application: UIApplication,
      didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    // 1. Provide Google Maps API key (must be before plugin registration)
    GMSServices.provideAPIKey("AIzaSyDCp_EGIWaoVYOeML3Kl8YiPN1az3hV9WA")

    // 2. Register all generated plugins (including google_maps_flutter)
    GeneratedPluginRegistrant.register(with: self)

    // Optional: you can add debug print to confirm it runs
    // print("Google Maps API key registered & plugins initialized")

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}