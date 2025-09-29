import SwiftUI

private enum SortChoice: Equatable {
    case newestFirst
    case oldestFirst
    case onlyActive
    case onlyDone
    case type(TaskType)
}

struct MainView: View {
    @EnvironmentObject var router: AppRouter
    @State private var tasks: [TaskModel] = []
    @State private var editMode: EditMode = .inactive

    @State private var showSortMenu = false
    @State private var sortChoice: SortChoice = .newestFirst

    private var displayedActive: [TaskModel] {
        applyOrder(applyTypeFilterIfNeeded(tasks.filter { !$0.isDone }))
    }
    private var displayedDone: [TaskModel] {
        applyOrder(applyTypeFilterIfNeeded(tasks.filter { $0.isDone }))
    }

    private var showActiveSection: Bool {
        switch sortChoice {
        case .onlyDone: return false
        default: return !displayedActive.isEmpty
        }
    }
    private var showDoneSection: Bool {
        switch sortChoice {
        case .onlyActive: return false
        default: return !displayedDone.isEmpty
        }
    }

    private func applyTypeFilterIfNeeded(_ items: [TaskModel]) -> [TaskModel] {
        switch sortChoice {
        case .type(let t): return items.filter { $0.type == t }
        default: return items
        }
    }

    private func applyOrder(_ items: [TaskModel]) -> [TaskModel] {
        switch sortChoice {
        case .newestFirst: return items.reversed()
        case .oldestFirst, .onlyActive, .onlyDone, .type: return items
        }
    }

    var body: some View {
        ZStack(alignment: .top) {
            Color(hex: "1D4268").ignoresSafeArea()

            if showSortMenu {

                Color.black.opacity(0.001)
                    .ignoresSafeArea()
                    .onTapGesture { withAnimation { showSortMenu = false } }

                SortMenu(
                    selected: $sortChoice,
                    onSelect: { choice in
                        sortChoice = choice
                        withAnimation { showSortMenu = false }
                    },
                    onClose: { withAnimation { showSortMenu = false } }
                )
                .padding(.top, Device.isSmall ? 27 : 5)
                .padding(.leading, Device.isSmall ? 105 : 140)
                .transition(.move(edge: .top).combined(with: .opacity))
                .zIndex(2)
            }

            VStack(spacing: 0) {
                HeaderCard(
                    onAdd: { router.openAddTask() },
                    onOpenSettings: { router.openSettings() },
                    onOpenSort: {
                        withAnimation(
                            .spring(response: 0.35, dampingFraction: 0.85)
                        ) {
                            showSortMenu.toggle()
                        }
                    }
                )

                if tasks.isEmpty {
                    EmptyListView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    listContent
                }

                Spacer(minLength: 0)
            }
            .ignoresSafeArea(edges: .top)
        }
        .onAppear { reload() }
    }

    @ViewBuilder
    private var listContent: some View {
        List {
            if showActiveSection {
                Section(header: sectionHeader("Active")) {
                    ForEach(
                        Array(displayedActive.enumerated()),
                        id: \.element.id
                    ) { index, task in
                        TaskRow(
                            task: task,
                            isDone: task.isDone,
                            onToggle: { toggle(task) }
                        )
                        .listRowBackground(Color(hex: "1D4268"))
                        .listRowInsets(
                            EdgeInsets(
                                top: 0,
                                leading: 16,
                                bottom: 0,
                                trailing: 16
                            )
                        )
                        .overlay(alignment: .bottom) {
                            separatorLine(
                                for: index,
                                total: displayedActive.count
                            )
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                delete(task)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            .labelStyle(.iconOnly)
                            .tint(.red)
                        }
                        .swipeActions(edge: .leading, allowsFullSwipe: false) {
                            Button {
                                router.openEditTask(task)
                            } label: {
                                Image(systemName: "pencil")
                            }
                            .labelStyle(.iconOnly)
                            .tint(Color(hex: "7EAC2F"))
                        }
                        .contentShape(Rectangle())
                        .onTapGesture { router.openTaskDetails(task) }
                    }
                    .onMove { indices, newOffset in
                        move(inDone: false, from: indices, to: newOffset)
                    }
                }
            }

            if showDoneSection {
                Section(header: sectionHeader("Done")) {
                    ForEach(Array(displayedDone.enumerated()), id: \.element.id)
                    { index, task in
                        TaskRow(
                            task: task,
                            isDone: task.isDone,
                            onToggle: { toggle(task) }
                        )
                        .listRowBackground(Color(hex: "1D4268"))
                        .listRowInsets(
                            EdgeInsets(
                                top: 0,
                                leading: 16,
                                bottom: 0,
                                trailing: 16
                            )
                        )
                        .overlay(alignment: .bottom) {
                            separatorLine(
                                for: index,
                                total: displayedDone.count
                            )
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                delete(task)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            .labelStyle(.iconOnly)
                            .tint(.red)
                        }
                        .swipeActions(edge: .leading, allowsFullSwipe: false) {
                            Button {
                                router.openEditTask(task)
                            } label: {
                                Image(systemName: "pencil")
                            }
                            .labelStyle(.iconOnly)
                            .tint(Color(hex: "7EAC2F"))
                        }
                        .contentShape(Rectangle())
                        .onTapGesture { router.openTaskDetails(task) }
                    }
                    .onMove { indices, newOffset in
                        move(inDone: true, from: indices, to: newOffset)
                    }
                }
            }
        }
        .listStyle(.plain)
        .listRowSpacing(0)
        .scrollContentBackground(.hidden)
        .environment(\.defaultMinListRowHeight, 1)
        .background(Color(hex: "1D4268"))
        .tint(Color(hex: "276AA5"))
        .toolbar { EditButton() }
        .environment(\.editMode, $editMode)
    }

    @ViewBuilder private func separatorLine(for index: Int, total: Int)
        -> some View
    {
        if index < total {
            Rectangle().fill(Color(hex: "276AA5")).frame(height: 1)
        }
    }

    private func sectionHeader(_ title: String) -> some View {
        HStack {
            Spacer()
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color(hex: "276AA5"))
            Spacer()
        }
    }

    private func reload() { tasks = TaskStorage.shared.load() }

    private func delete(_ task: TaskModel) {
        TaskStorage.shared.delete(task)
        reload()
    }

    private func toggle(_ task: TaskModel) {
        guard let idx = tasks.firstIndex(where: { $0.id == task.id }) else {
            return
        }
        tasks[idx].isDone.toggle()
        TaskStorage.shared.replaceAll(tasks)
    }

    private func move(inDone: Bool, from indices: IndexSet, to newOffset: Int) {
        var section = inDone ? displayedDone : displayedActive
        section.move(fromOffsets: indices, toOffset: newOffset)
        let other = inDone ? displayedActive : displayedDone
        tasks = inDone ? (other + section) : (section + other)
        TaskStorage.shared.replaceAll(tasks)
    }
}

private struct EmptyListView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image("app_bg_empty").resizable().scaledToFit().frame(
                width: 128,
                height: 188
            )
            Text("Your list is empty").font(.system(size: 16, weight: .regular))
                .foregroundColor(.white)
        }
    }
}

private struct TaskRow: View {
    let task: TaskModel
    let isDone: Bool
    var onToggle: () -> Void = {}

    var body: some View {
        HStack(spacing: 12) {
            Image(task.type.icon).resizable().scaledToFit().frame(
                width: 54,
                height: 54
            )
            VStack(alignment: .leading, spacing: 6) {
                Text(task.name).font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .fixedSize(horizontal: false, vertical: true)
                if !task.note.isEmpty {
                    Text(task.note)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(Color(hex: "808080"))
                        .fixedSize(horizontal: false, vertical: true)
                        .lineSpacing(2)
                }
            }
            Spacer()
            Button(action: onToggle) {
                ZStack {
                    Circle().fill(Color.black.opacity(0.25)).frame(
                        width: 24,
                        height: 24
                    )
                    if isDone {
                        Image(systemName: "checkmark.circle.fill")
                            .resizable().scaledToFit().frame(
                                width: 24,
                                height: 24
                            )
                            .foregroundColor(Color(hex: "1295F5"))
                            .transition(.scale)
                    }
                }
                .contentShape(Circle())
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 15)
    }
}

private struct HeaderCard: View {
    var onAdd: () -> Void
    var onOpenSettings: () -> Void
    var onOpenSort: () -> Void

    var body: some View {
        ZStack {
            BottomRoundedRectangle(radius: 28)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "#3BA2EA"), Color(hex: "#2D51B1")],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 5)
                .frame(height: 300)
                .ignoresSafeArea(edges: .top)

            HStack(alignment: .top, spacing: 0) {
                VStack(alignment: .center, spacing: 16) {
                    HintBubble(
                        text:
                            "Swipe left on the bar if you\nwant to delete the task.\nSwipe right if you want to\nchange the task.\nDrag & Drop - to swap tasks"
                    )
                    Button(action: onAdd) {
                        HStack(spacing: 10) {
                            Text("Add new task").font(
                                .system(size: 16, weight: .semibold)
                            )
                            Spacer(minLength: 0)
                            Image(systemName: "plus").font(
                                .system(size: 18, weight: .bold)
                            )
                        }
                        .padding(.horizontal, 16)
                        .frame(width: 176, height: 50)
                        .background(
                            Capsule().fill(Color(hex: "#7EAC2F"))
                                .shadow(
                                    color: .black.opacity(0.25),
                                    radius: 6,
                                    y: 3
                                )
                        )
                        .foregroundColor(.white)
                    }
                    .buttonStyle(.plain)
                }

                Spacer(minLength: 8)

                VStack(alignment: .trailing, spacing: 12) {
                    HStack(spacing: 15) {
                        IconButton(imageName: "app_ic_sort", action: onOpenSort)
                        IconButton(
                            imageName: "app_ic_settings",
                            action: onOpenSettings
                        )
                    }
                    Image("app_ic_goal").resizable().scaledToFit().frame(
                        width: 148,
                        height: 148
                    ).padding(.top)
                }
            }
            .padding(.horizontal, 10)
            .padding(.top, Device.isSmall ? 30 : 60)
            .padding(.bottom, 10)
        }
        .frame(height: 295)
        .clipShape(BottomRoundedRectangle(radius: 28))
    }
}

private struct HintBubble: View {
    let text: String
    var body: some View {
        VStack(spacing: 10) {
            Image("app_ic_idea").resizable().scaledToFit().frame(
                width: 24,
                height: 24
            )
            Text(text).font(.system(size: 12, weight: .regular))
                .foregroundColor(.white)
                .lineSpacing(2).multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 30, style: .continuous).fill(
                Color.black.opacity(0.2)
            )
        )
    }
}

struct BottomRoundedRectangle: Shape {
    var radius: CGFloat
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: [.bottomLeft, .bottomRight],
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

private struct IconButton: View {
    let imageName: String
    var action: () -> Void
    var body: some View {
        Button(action: action) {
            Image(imageName).resizable().scaledToFit().frame(
                width: 32,
                height: 32
            )
        }
        .buttonStyle(.plain)
    }
}

private struct SortMenu: View {
    @Binding var selected: SortChoice
    var onSelect: (SortChoice) -> Void
    var onClose: () -> Void

    var body: some View {
        ZStack(alignment: .topTrailing) {

            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(Color.black.opacity(0.55))
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(Color.white.opacity(0.05), lineWidth: 1)
                )

            VStack(spacing: 0) {

                HStack {
                    Spacer()
                    Button(action: onClose) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .padding(10)
                    }
                }
                .padding(.trailing, 6)

                VStack(alignment: .leading, spacing: 7) {
                    row("Newest first", isOn: selected == .newestFirst) {
                        onSelect(.newestFirst)
                    }
                    row("Oldest first", isOn: selected == .oldestFirst) {
                        onSelect(.oldestFirst)
                    }
                    row("Active", isOn: selected == .onlyActive) {
                        onSelect(.onlyActive)
                    }
                    row("Done", isOn: selected == .onlyDone) {
                        onSelect(.onlyDone)
                    }
                    row("Important", isOn: selected == .type(.Important)) {
                        onSelect(.type(.Important))
                    }
                    row("Urgent", isOn: selected == .type(.Urgent)) {
                        onSelect(.type(.Urgent))
                    }
                    row("Someday", isOn: selected == .type(.Someday)) {
                        onSelect(.type(.Someday))
                    }
                    row("Goals", isOn: selected == .type(.Goals)) {
                        onSelect(.type(.Goals))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 20)
                .padding(.top, 30)
            }
        }
        .frame(maxWidth: 180, alignment: .leading)
        .fixedSize(horizontal: false, vertical: true)

        .background(
            TopNub()
                .fill(.ultraThinMaterial)
                .overlay(Color.black.opacity(0.25))
                .frame(width: 36, height: 36)
                .offset(x: 220, y: -18)
        )
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .shadow(color: .black.opacity(0.4), radius: 10, y: 6)
    }

    private func row(_ title: String, isOn: Bool, action: @escaping () -> Void)
        -> some View
    {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.white)
                Spacer(minLength: 12)
                ZStack {
                    Circle()
                        .fill(Color.black.opacity(0.35))
                        .frame(width: 24, height: 24)
                    if isOn {
                        Circle()
                            .fill(Color(hex: "1295F5"))
                            .frame(width: 24, height: 24)
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

private struct TopNub: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let r = rect.width / 2
        p.addRoundedRect(in: rect, cornerSize: CGSize(width: r, height: r))
        return p
    }
}

#Preview {
    MainView()
}
