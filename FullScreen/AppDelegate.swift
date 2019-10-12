import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    private let window: UIWindow = {
        let window = UIWindow()
        window.rootViewController = PlayerViewController()
        return window
    }()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window.makeKeyAndVisible()
        return true
    }
}

