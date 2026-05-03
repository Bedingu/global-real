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
    FirebaseApp.configure()
    GMSServices.provideAPIKey("AIzaSyAfkTMK6054qNC78q6p-UBv3BF8ig9EmVQ")
    
    // Push notifications
    UNUserNotificationCenter.current().delegate = self
    application.registerForRemoteNotifications()
    
    let result = super.application(application, didFinishLaunchingWithOptions: launchOptions)
    GeneratedPluginRegistrant.register(with: self)
    return result
  }
}
