import SwiftUI

struct BlockingPromptView: View {
    @State private var taskText: String = ""
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        ZStack {
            // Semi-transparent background
            Color.black.opacity(0.85)
                .ignoresSafeArea()

            VStack(spacing: 30) {
                // Title
                VStack(spacing: 12) {
                    Text("Good Morning")
                        .font(.system(size: 48, weight: .light))
                        .foregroundColor(.white)

                    Text("What's your one big thing for today?")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                }

                // Subtitle
                Text("The one thing that, if you accomplished it today,\nwould make it a productive day.")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.6))
                    .multilineTextAlignment(.center)

                // Input field
                VStack(spacing: 20) {
                    TextField("Enter your one big thing...", text: $taskText)
                        .textFieldStyle(.plain)
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                )
                        )
                        .frame(width: 500)
                        .focused($isTextFieldFocused)
                        .onSubmit {
                            submitTask()
                        }

                    // Submit button
                    Button(action: submitTask) {
                        HStack {
                            Text("Start My Day")
                                .font(.system(size: 18, weight: .semibold))
                            Image(systemName: "arrow.right")
                        }
                        .foregroundColor(.black)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(taskText.isEmpty ? Color.white.opacity(0.5) : Color.white)
                        )
                    }
                    .buttonStyle(.plain)
                    .disabled(taskText.isEmpty)
                }
            }
        }
        .onAppear {
            // Focus the text field when view appears
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isTextFieldFocused = true
            }
        }
    }

    private func submitTask() {
        let trimmed = taskText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        // Update shared state - this will trigger the app delegate's observer
        AppState.shared.submittedTask = trimmed
    }
}
