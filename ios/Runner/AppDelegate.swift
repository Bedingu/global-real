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
    // Firebase — configurado com opções explícitas em vez de depender do
    // GoogleService-Info.plist estar embutido no bundle. O plist não está
    // referenciado no projeto Xcode, então FirebaseApp.configure() sem
    // argumentos lançava NSException no launch (crash de inicialização).
    if FirebaseApp.app() == nil {
      let options = FirebaseOptions(
        googleAppID: "1:712132251153:ios:52663061757229dbb32bb0",
        gcmSenderID: "712132251153"
      )
      options.apiKey = "AIzaSyC_ec2PS7sof_SNVe5m2JteT8HYjKb-t5U"
      options.projectID = "globalreal-app"
      options.storageBucket = "globalreal-app.firebasestorage.app"
      options.bundleID = "com.globalreal.app"
      FirebaseApp.configure(options: options)
    }

    // Push Notifications
    UNUserNotificationCenter.current().delegate = self
    application.registerForRemoteNotifications()

    // Google Maps
    GMSServices.provideAPIKey("AIzaSyAfkTMK6054qNC78q6p-UBv3BF8ig9EmVQ")

    // Flutter plugins
    GeneratedPluginRegistrant.register(with: self)

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
