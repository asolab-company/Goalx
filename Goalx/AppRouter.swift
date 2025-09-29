import Combine
import SwiftUI

enum Route {
    case loading
    case onboarding
    case menu
    case settings
    case addTask
    case editTask(TaskModel)
    case taskDetails(TaskModel)
}

extension Route {
    var key: String {
        switch self {
        case .loading: return "loading"
        case .onboarding: return "onboarding"
        case .menu: return "menu"
        case .settings: return "settings"
        case .addTask: return "addTask"
        case .taskDetails(let t): return "task-\(t.name)-\(t.type.rawValue)"
        case .editTask(let t):
            return "edit-\(t.name)-\(t.type.rawValue)"
        }
    }
}

final class AppRouter: ObservableObject {
    @Published var route: Route = .loading

    func start() {
        if UserDefaults.standard.bool(forKey: "didSeeOnboarding") {
            openMenu()
        } else {
            route = .onboarding
        }
    }

    func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: "didSeeOnboarding")
        openMenu()
    }

    func openMenu() { route = .menu }
    func openSettings() { route = .settings }
    func openAddTask() { route = .addTask }
    func openTaskDetails(_ t: TaskModel) { route = .taskDetails(t) }
    func openEditTask(_ task: TaskModel) { route = .editTask(task) }
}
