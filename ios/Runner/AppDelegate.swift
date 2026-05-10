import Flutter
import UIKit
import GoogleMaps
import FirebaseCore
import FirebaseMessaging

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // 1) Registrar plugins primeiro
    GeneratedPluginRegistrant.register(with: self)
    
    // 2) Firebase
    FirebaseApp.configure()
    
    // 3) Google Maps
    GMSServices.provideAPIKey("AIzaSyAfkTMK6054qNC78q6p-UBv3BF8ig9EmVQ")
    
    // 4) Push notifications
    UNUserNotificationCenter.current().delegate = self
    application.registerForRemoteNotifications()
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
