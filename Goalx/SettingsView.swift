import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var router: AppRouter
    @Environment(\.openURL) private var openURL
    @State private var showShare = false

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
                    Text("Setting")
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

                SettingsRow(
                    icon: "ic_terms",
                    title: "Terms and Conditions",
                    action: { openURL(AppLinks.termsOfUse) }
                )

                Divider()
                    .overlay(Color.init(hex: "276AA5"))

                SettingsRow(
                    icon: "ic_privacy",
                    title: "Privacy",
                    action: { openURL(AppLinks.privacyPolicy) }
                )

                Divider()
                    .overlay(Color.init(hex: "276AA5"))

                SettingsRow(
                    icon: "ic_share",
                    title: "Share app",
                    action: { showShare = true }
                )
                Divider()
                    .overlay(Color.init(hex: "276AA5"))

            }

        }
        .sheet(isPresented: $showShare) {
            ShareSheet(items: AppLinks.shareItems)
        }
    }

}

private struct SettingsRow: View {
    let icon: String
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 20) {
                Image(icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)

                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 20)
            .frame(height: 25)
        }
        .buttonStyle(.plain)
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(
            activityItems: items,
            applicationActivities: nil
        )
    }
    func updateUIViewController(
        _ vc: UIActivityViewController,
        context: Context
    ) {}
}

#Preview {
    SettingsView()
}
