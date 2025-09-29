import SwiftUI

struct OnboardingView: View {
    var onContinue: () -> Void = {}

    var body: some View {
        ZStack(alignment: .top) {
            Color(hex: "1D4268").ignoresSafeArea()
            Image("onb_img")
                .resizable()
                .scaledToFit()

            GeometryReader { geo in
                VStack {
                    Spacer()

                    TopRoundedContainer(bottomInset: geo.safeAreaInsets.bottom)
                    {
                        VStack(spacing: 10) {
                            Text("What you get with the app")
                                .foregroundColor(.white)
                                .font(.system(size: 24, weight: .bold))
                                .padding(.bottom)

                            VStack(alignment: .leading, spacing: 2) {
                                BulletRow(
                                    "Stay organized",
                                    "all tasks in one view."
                                )
                                BulletRow(
                                    "Simple & fast",
                                    "manage tasks in one tap."
                                )
                                BulletRow(
                                    "Smart categories",
                                    "separate your goals."
                                )
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.bottom)

                            Button(action: { onContinue() }) {
                                ZStack {
                                    Text("Continue")
                                        .font(.system(size: 20, weight: .bold))
                                    HStack {
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .font(
                                                .system(size: 20, weight: .bold)
                                            )
                                    }
                                    .padding(.horizontal)
                                }
                                .padding(.vertical, 14)
                                .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(GreenCTAStyle())
                            .padding(.bottom, 8)

                            TermsFooter().padding(
                                .bottom,
                                Device.isSmall ? 0 : 60
                            )
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }.ignoresSafeArea()
    }
}

private struct BulletRow: View {
    let title: String
    let description: String

    init(_ title: String, _ description: String) {
        self.title = title
        self.description = description
    }

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {

            Circle()
                .fill(Color(hex: "#1295F5"))
                .frame(width: 6, height: 6)

            (Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color(hex: "#1295F5"))
                + Text(" – \(description)")
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.white))
            Spacer()
        }
    }
}

private struct TermsFooter: View {
    var body: some View {
        VStack(spacing: 2) {
            Text("By Proceeding You Accept")
                .foregroundColor(Color.init(hex: "808080"))
                .font(.footnote)

            HStack(spacing: 0) {
                Text("Our ")
                    .foregroundColor(Color.init(hex: "808080"))
                    .font(.footnote)

                Link("Terms Of Use", destination: AppLinks.termsOfUse)
                    .font(.footnote)
                    .foregroundColor(Color.init(hex: "1295F5"))

                Text(" And ")
                    .foregroundColor(Color.init(hex: "808080"))
                    .font(.footnote)

                Link("Privacy Policy", destination: AppLinks.privacyPolicy)
                    .font(.footnote)
                    .foregroundColor(Color.init(hex: "1295F5"))

            }
        }
        .frame(maxWidth: .infinity)
        .multilineTextAlignment(.center)
    }
}

private struct GreenCTAStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .background(
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: "#7EAC2F"), Color(hex: "#7EAC2F"),
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            )
            .foregroundColor(.white)
            .overlay(
                Capsule()
                    .stroke(
                        Color.white.opacity(
                            configuration.isPressed ? 0.25 : 0.12
                        ),
                        lineWidth: 1
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .shadow(radius: configuration.isPressed ? 2 : 6, y: 2)
    }
}

struct TopRoundedContainer<Content: View>: View {
    let bottomInset: CGFloat
    let content: Content

    init(bottomInset: CGFloat, @ViewBuilder content: () -> Content) {
        self.bottomInset = bottomInset
        self.content = content()
    }

    var body: some View {
        VStack { content }

            .padding(.horizontal, 24)
            .padding(.top, 16)

            .padding(.bottom, max(16, bottomInset + 8))
            .frame(maxWidth: .infinity, alignment: .top)

            .background(
                Color.black.opacity(0.5)
                    .ignoresSafeArea(edges: .bottom)
            )

            .clipShape(
                RoundedCorner(radius: 24, corners: [.topLeft, .topRight])
            )

    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

extension Text {

    func link(_ url: URL) -> some View {
        Link(destination: url) { self }
    }
}

#Preview {
    OnboardingView {
        print("Finished")
    }
}
