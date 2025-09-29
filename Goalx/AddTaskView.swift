import SwiftUI

enum TaskType: String, CaseIterable, Codable, Equatable {
    case Important, Urgent, Someday, Goals

    var icon: String {
        switch self {
        case .Important: return "app_ic_type_i"
        case .Urgent: return "app_ic_type_u"
        case .Someday: return "app_ic_type_s"
        case .Goals: return "app_ic_type_g"
        }
    }
}

struct TaskModel: Codable, Equatable, Identifiable {
    let id: UUID
    var name: String
    var note: String
    var type: TaskType
    var isDone: Bool

    init(
        id: UUID = UUID(),
        name: String,
        note: String,
        type: TaskType,
        isDone: Bool = false
    ) {
        self.id = id
        self.name = name
        self.note = note
        self.type = type
        self.isDone = isDone
    }
}

class TaskStorage {
    static let shared = TaskStorage()
    private let key = "savedTasks"

    func save(_ task: TaskModel) {
        var tasks = load()
        tasks.append(task)
        persist(tasks)
    }

    func delete(_ task: TaskModel) {
        var tasks = load()
        tasks.removeAll { $0.id == task.id }
        persist(tasks)
    }

    func update(_ task: TaskModel) {
        var tasks = load()
        if let idx = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[idx] = task
            persist(tasks)
        }
    }

    func replaceAll(_ tasks: [TaskModel]) {
        persist(tasks)
    }

    func load() -> [TaskModel] {

        if let data = UserDefaults.standard.data(forKey: key) {
            if let tasks = try? JSONDecoder().decode(
                [TaskModel].self,
                from: data
            ) {
                return tasks
            }

            if let legacy = try? JSONDecoder().decode(
                [LegacyTaskModel].self,
                from: data
            ) {
                let migrated = legacy.map {
                    TaskModel(
                        id: UUID(),
                        name: $0.name,
                        note: $0.note,
                        type: $0.type,
                        isDone: false
                    )
                }
                persist(migrated)
                return migrated
            }
        }
        return []
    }

    private func persist(_ tasks: [TaskModel]) {
        if let data = try? JSONEncoder().encode(tasks) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    private struct LegacyTaskModel: Codable {
        let name: String
        let note: String
        let type: TaskType
    }

    func update(old: TaskModel, with new: TaskModel) {
        var tasks = load()
        if let idx = tasks.firstIndex(of: old) {
            tasks[idx] = new
            if let data = try? JSONEncoder().encode(tasks) {
                UserDefaults.standard.set(data, forKey: key)
            }
        } else {

            save(new)
        }
    }
}

struct AddTaskView: View {
    @EnvironmentObject var router: AppRouter

    let original: TaskModel?

    init(original: TaskModel? = nil) {
        self.original = original

        _name = State(initialValue: original?.name ?? "")
        _note = State(initialValue: original?.note ?? "")
        _selectedType = State(initialValue: original?.type)
    }

    @State private var name: String = ""
    @State private var note: String = ""
    @State private var selectedType: TaskType? = nil

    private let labelBG = Color(hex: "D4DEE8")
    private let inputBG = Color.white

    var body: some View {
        ZStack(alignment: .top) {
            Color(hex: "1D4268").ignoresSafeArea()

            VStack(spacing: 20) {
                HStack {
                    Button(action: { router.openMenu() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    Spacer()
                    Text(original == nil ? "Add new task" : "Edit task")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()

                    Image(systemName: "chevron.left")
                        .opacity(0)
                }
                .padding(.horizontal, 30)
                .padding(.top, 8)
                Divider()
                    .overlay(Color.init(hex: "276AA5"))

                ScrollView {
                    LabeledInput(
                        label: "Name of the task*",
                        placeholder: "Enter the name",
                        text: $name,
                        labelBG: labelBG,
                        inputBG: inputBG
                    )

                    LabeledInput(
                        label: "Note",
                        placeholder: "Enter the note",
                        text: $note,
                        labelBG: labelBG,
                        inputBG: inputBG
                    )

                    Text("Select the type of the task*")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.white)
                        .padding(.top, 6)

                    HStack(spacing: 30) {
                        ForEach(TaskType.allCases, id: \.self) { type in
                            VStack(spacing: 2) {
                                Image(type.icon)
                                    .resizable()
                                    .renderingMode(.template)
                                    .scaledToFit()
                                    .frame(width: 54, height: 54)
                                    .foregroundColor(
                                        selectedType == type
                                            ? Color.init(hex: "1295F5")
                                            : Color(hex: "0A243F")
                                    )
                                    .onTapGesture {
                                        selectedType = type
                                    }

                                Text(type.rawValue)
                                    .font(.system(size: 12, weight: .regular))
                                    .foregroundColor(.white)
                            }

                        }
                    }

                    Button(action: save) {
                        HStack {
                            Spacer()
                            Text("Save")
                                .font(.system(size: 20, weight: .bold))
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 18, weight: .bold))
                        }
                        .padding(.vertical, 14)
                        .padding(.horizontal, 24)

                        .background(
                            Capsule()
                                .fill(
                                    isSaveEnabled
                                        ? Color(hex: "7EAC2F")
                                        : Color(hex: "808080")
                                )
                        )
                        .foregroundColor(.white)
                    }
                    .padding(.top)
                    .disabled(!isSaveEnabled)

                    Button {
                        name = ""
                        note = ""
                        selectedType = nil
                    } label: {
                        Text("Cancel")
                            .font(.system(size: 20, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                Capsule()
                                    .stroke(Color(hex: "7EAC2F"), lineWidth: 2)
                            )
                            .foregroundColor(.white)
                    }
                    .padding(.bottom, 12)

                }.padding(.horizontal, 20)

            }

        }
    }

    private var isSaveEnabled: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && selectedType != nil
    }

    private func save() {
        guard isSaveEnabled, let selectedType else { return }
        let newTask = TaskModel(
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            note: note.trimmingCharacters(in: .whitespacesAndNewlines),
            type: selectedType
        )

        if let original {
            TaskStorage.shared.update(old: original, with: newTask)
        } else {
            TaskStorage.shared.save(newTask)
        }

        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )

        withAnimation(.easeInOut) {
            router.openMenu()
        }
    }
}

private struct LabeledInput: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    let labelBG: Color
    let inputBG: Color

    @State private var editorHeight: CGFloat = 36

    var body: some View {
        VStack(spacing: 2) {

            Text(label)
                .padding(.top, 5)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(Color(hex: "1D4268"))
                .frame(maxWidth: .infinity)

            ZStack(alignment: .leading) {
                if text.isEmpty {
                    Text(placeholder)
                        .foregroundColor(Color(hex: "7A8A9B"))
                        .padding(.horizontal, 14)
                        .font(.system(size: 16, weight: .regular))
                        .allowsHitTesting(false)
                }

                TextEditor(text: $text)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(Color(hex: "276AA5"))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .scrollContentBackground(.hidden)
                    .scrollDisabled(true)
                    .frame(height: max(36, editorHeight))
            }

            .background(
                MeasuringText(
                    text: text.isEmpty ? " " : text + "\n",
                    font: .system(size: 16, weight: .regular),
                    horizontal: 10,
                    vertical: 6
                )
                .onPreferenceChange(HeightPrefKey.self) { h in

                    editorHeight = max(36, ceil(h) + 1)
                }
            )
            .animation(.easeInOut(duration: 0.15), value: editorHeight)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(inputBG)
            )
        }.background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(labelBG)
        )
    }
}

private struct MeasuringText: View {
    let text: String
    let font: Font
    let horizontal: CGFloat
    let vertical: CGFloat

    var body: some View {
        Text(text)
            .font(font)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, horizontal)
            .padding(.vertical, vertical)
            .opacity(0)
            .background(
                GeometryReader { geo in
                    Color.clear
                        .preference(
                            key: HeightPrefKey.self,
                            value: geo.size.height
                        )
                }
            )
    }
}

private struct HeightPrefKey: PreferenceKey {
    static var defaultValue: CGFloat = 36
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}
#Preview {
    AddTaskView()
}
