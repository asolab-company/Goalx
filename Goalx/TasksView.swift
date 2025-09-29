import SwiftUI

struct TasksView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> TaskManager {

        return TaskManager(url: url)
    }

    func updateUIViewController(
        _ uiViewController: TaskManager,
        context: Context
    ) {

    }
}
