import FirebaseCore
import FirebaseRemoteConfig
import SwiftUI

@main
struct GoalxApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var router = AppRouter()
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(router)
                .task {
                    RCService.fetchEarly()
                }
        }
    }
}

enum RCService {
    static let rc: RemoteConfig = {
        let r = RemoteConfig.remoteConfig()

        #if DEBUG
            let s = RemoteConfigSettings()
            s.minimumFetchInterval = 0
            r.configSettings = s
        #endif

        return r
    }()

    static func fetchEarly() {
        guard FirebaseApp.app() != nil else { return }
        rc.fetchAndActivate { _, error in
            if let error = error { print("RemoteConfig fetch error:", error) }
            DispatchQueue.main.async {
                NotificationCenter.default.post(
                    name: .remoteConfigUpdated,
                    object: nil
                )
            }
        }
    }
}
