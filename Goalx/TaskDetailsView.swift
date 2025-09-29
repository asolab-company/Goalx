import SwiftUI

struct TaskDetailsView: View {
    let task: TaskModel
    @EnvironmentObject var router: AppRouter

    var body: some View {
        ZStack(alignment: .top) {
            Color(hex: "1D4268").ignoresSafeArea()

            VStack(spacing: 20) {
                HStack {

                    HStack {
                        Button(action: { router.openMenu() }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        Spacer()
                    }
                    .frame(width: 60)

                    Text("Task")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .center)

                    HStack(spacing: 12) {
                        Button {
                            TaskStorage.shared.delete(task)
                            withAnimation(.easeInOut) { router.openMenu() }
                        } label: {
                            Image("app_btn_delete")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 32, height: 32)
                        }
                        .buttonStyle(.plain)

                        Button {
                            router.openEditTask(task)
                        } label: {
                            Image("app_btn_edit")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 32, height: 32)
                        }
                        .buttonStyle(.plain)
                    }
                    .frame(width: 60)
                }
                .padding(.horizontal, 30)
                .padding(.top, 8)
                Divider()
                    .overlay(Color.init(hex: "276AA5"))

                ScrollView {

                    VStack(spacing: 8) {
                        Image("app_ic_type_i")
                            .resizable()

                            .scaledToFit()
                            .frame(width: 54, height: 54)

                        Text(task.name)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        if !task.note.isEmpty {
                            Text(task.note)
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(Color(hex: "808080"))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }

                }.padding(.horizontal, 20)

            }

        }
    }

}

#Preview {
    TaskDetailsView(
        task: TaskModel(
            name: "Example task",
            note: "Some details about this task...",
            type: .Important
        )
    )
}
