import SwiftUI
import AppKit

struct FloatingReminderView: View {
    let task: String
    let onComplete: () -> Void

    @State private var isButtonHovered: Bool = false
    @State private var pulseScale: CGFloat = 1.0
    @State private var ringScales: [CGFloat] = [1, 1, 1]
    @State private var ringOpacities: [Double] = [0, 0, 0]

    // Timer for 30-minute heartbeat
    let heartbeatTimer = Timer.publish(every: 30 * 60, on: .main, in: .common).autoconnect()

    // Extra padding around the content for rings to expand into
    private let ringPadding: CGFloat = 120

    var body: some View {
        ZStack {
            // Radiating rings (behind the main content)
            // These are circles that expand outward from the toast
            ForEach(0..<3, id: \.self) { index in
                RoundedRectangle(cornerRadius: 24 + (ringScales[index] - 1) * 50)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color(hex: "8B5CF6").opacity(ringOpacities[index]),
                                Color(hex: "6D28D9").opacity(ringOpacities[index] * 0.5)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 2.5
                    )
                    .scaleEffect(ringScales[index])
                    .opacity(ringOpacities[index])
            }

            // Main content
            HStack(spacing: 24) {
                // Task text (draggable area)
                Text(task)
                    .font(.system(size: 28, weight: .medium))
                    .foregroundColor(.white.opacity(0.95))
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                // Complete button
                Button(action: onComplete) {
                    Text("Complete")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(.white)
                        .fixedSize()
                        .padding(.horizontal, 28)
                        .padding(.vertical, 14)
                        .background(
                            LinearGradient(
                                colors: isButtonHovered
                                    ? [Color(hex: "8B5CF6"), Color(hex: "7C3AED")]
                                    : [Color(hex: "7C3AED"), Color(hex: "6D28D9")],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .clipShape(Capsule())
                        .shadow(color: Color(hex: "7C3AED").opacity(0.4), radius: 8, x: 0, y: 4)
                }
                .buttonStyle(.plain)
                .onHover { hovering in
                    withAnimation(.easeInOut(duration: 0.15)) {
                        isButtonHovered = hovering
                    }
                }
            }
            .padding(.leading, 32)
            .padding(.trailing, 20)
            .padding(.vertical, 20)
            .background(
                ZStack {
                    // Dark blurred background
                    VisualEffectBlur(material: .hudWindow, blendingMode: .behindWindow)
                    Color.black.opacity(0.75)
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color.white.opacity(0.15), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.4), radius: 20, x: 0, y: 8)
            .scaleEffect(pulseScale)
        }
        // Add padding around the entire view so rings can expand beyond the toast
        .padding(ringPadding)
        .onReceive(heartbeatTimer) { _ in
            triggerHeartbeat()
        }
        .onAppear {
            // Initial heartbeat after 2 seconds to show it's working
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                triggerHeartbeat()
            }
        }
    }

    private func triggerHeartbeat() {
        // 3 pulses with 2 seconds between each
        for pulseIndex in 0..<3 {
            let delay = Double(pulseIndex) * 2.0

            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                // Scale pulse
                withAnimation(.easeInOut(duration: 0.15)) {
                    pulseScale = 1.08
                }
                withAnimation(.easeInOut(duration: 0.15).delay(0.15)) {
                    pulseScale = 1.0
                }

                // Trigger radiating rings
                triggerRings()
            }
        }
    }

    private func triggerRings() {
        // Stagger the rings with more delay between them
        for ringIndex in 0..<3 {
            let delay = Double(ringIndex) * 0.25

            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                // Reset ring
                ringScales[ringIndex] = 1.0
                ringOpacities[ringIndex] = 0.6

                // Animate ring expanding and fading - slower and more dramatic
                withAnimation(.easeOut(duration: 1.8)) {
                    ringScales[ringIndex] = 2.0
                    ringOpacities[ringIndex] = 0
                }
            }
        }
    }
}

// Visual effect blur for macOS
struct VisualEffectBlur: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode

    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
    }
}

// Hex color extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
