import SwiftUI
import AppKit
import Combine

@main
struct OneBigThingFloatApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var floatingWindow: NSWindow?
    var promptWindow: KeyableWindow?
    var cancellables = Set<AnyCancellable>()

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Parse command line arguments
        let args = CommandLine.arguments

        if args.contains("--quit") {
            NSApp.terminate(nil)
            return
        }

        // Check if task already exists for today
        let existingTask = TaskManager.shared.loadTask()

        if args.contains("--prompt") {
            if existingTask != nil {
                // Task already set for today - just show floating window
                NSApp.setActivationPolicy(.accessory)
                showFloatingWindow()
            } else {
                // No task yet - show blocking prompt
                NSApp.setActivationPolicy(.regular)
                showBlockingPrompt()
            }
        } else {
            // Default: show floating window if task exists
            NSApp.setActivationPolicy(.accessory)
            showFloatingWindow()
        }
    }

    func showBlockingPrompt() {
        // Create full-screen blocking prompt
        guard let screen = NSScreen.main else { return }

        // Observe the shared state for task submission
        AppState.shared.$submittedTask
            .compactMap { $0 }  // Only proceed when task is non-nil
            .first()  // Only handle once
            .receive(on: DispatchQueue.main)
            .sink { [weak self] task in
                self?.handleTaskSubmission(task)
            }
            .store(in: &cancellables)

        let contentView = BlockingPromptView()

        promptWindow = KeyableWindow(
            contentRect: screen.frame,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )

        promptWindow?.level = .screenSaver
        promptWindow?.backgroundColor = NSColor.black.withAlphaComponent(0.8)
        promptWindow?.isOpaque = false
        promptWindow?.hasShadow = false
        promptWindow?.ignoresMouseEvents = false
        promptWindow?.contentView = NSHostingView(rootView: contentView)
        promptWindow?.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]

        // Critical: Make window key and activate app
        promptWindow?.makeKeyAndOrderFront(nil)
        promptWindow?.makeFirstResponder(promptWindow?.contentView)
        NSApp.activate(ignoringOtherApps: true)
    }

    func handleTaskSubmission(_ task: String) {
        log("handleTaskSubmission called with: \(task)")

        // Save task
        TaskManager.shared.saveTask(task)
        log("Task saved")

        // Close prompt
        self.promptWindow?.orderOut(nil)
        self.promptWindow?.close()
        self.promptWindow = nil

        // Relaunch the app without --prompt to show floating window
        log("Relaunching app")
        let appURL = Bundle.main.bundleURL
        let config = NSWorkspace.OpenConfiguration()
        config.createsNewApplicationInstance = true
        NSWorkspace.shared.openApplication(at: appURL, configuration: config) { _, _ in }

        // Use _exit() for immediate termination without any cleanup (avoids crash)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            _exit(0)
        }
    }

    func log(_ message: String) {
        let logFile = "/tmp/onebighing-debug.log"
        let timestamp = ISO8601DateFormatter().string(from: Date())
        let line = "[\(timestamp)] \(message)\n"
        if let data = line.data(using: .utf8) {
            if FileManager.default.fileExists(atPath: logFile) {
                if let handle = FileHandle(forWritingAtPath: logFile) {
                    handle.seekToEndOfFile()
                    handle.write(data)
                    handle.closeFile()
                }
            } else {
                FileManager.default.createFile(atPath: logFile, contents: data)
            }
        }
    }

    func showFloatingWindow() {
        log("showFloatingWindow: starting")

        // Check if there's a task to show
        guard let task = TaskManager.shared.loadTask() else {
            log("showFloatingWindow: no task found, terminating")
            NSApp.terminate(nil)
            return
        }
        log("showFloatingWindow: task loaded: \(task.task)")

        let contentView = FloatingReminderView(task: task.task) { [weak self] in
            self?.completeTask()
        }

        // Create hosting view to measure content size
        let hostingView = NSHostingView(rootView: contentView)
        hostingView.frame.size = hostingView.fittingSize
        log("showFloatingWindow: hostingView size: \(hostingView.fittingSize)")

        // The view has extra padding (120px) around it for radiating rings
        let ringPadding: CGFloat = 120

        let windowSize = CGSize(
            width: hostingView.fittingSize.width,
            height: hostingView.fittingSize.height
        )

        // Position at top-right of screen with padding
        // Account for ring padding so the visible toast is positioned correctly
        let initialRect: NSRect
        if let screen = NSScreen.main {
            let screenPadding: CGFloat = 20  // padding from screen edges
            // The toast visual is inset by ringPadding from the window edges
            let x = screen.visibleFrame.maxX - windowSize.width + ringPadding - screenPadding
            let y = screen.visibleFrame.maxY - windowSize.height + ringPadding - screenPadding
            initialRect = NSRect(x: x, y: y, width: windowSize.width, height: windowSize.height)
            log("showFloatingWindow: top-right at: \(initialRect)")
        } else {
            initialRect = NSRect(x: 100, y: 100, width: windowSize.width, height: windowSize.height)
            log("showFloatingWindow: no screen, using fallback position")
        }

        floatingWindow = FloatingWindow(
            contentRect: initialRect,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        log("showFloatingWindow: window created")

        floatingWindow?.level = .floating
        floatingWindow?.backgroundColor = .clear
        floatingWindow?.isOpaque = false
        floatingWindow?.hasShadow = false  // We handle shadow in SwiftUI
        floatingWindow?.contentView = hostingView
        floatingWindow?.isMovableByWindowBackground = true
        floatingWindow?.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]

        // Show the window - use orderFrontRegardless for accessory apps
        log("showFloatingWindow: about to show window")
        floatingWindow?.orderFrontRegardless()
        log("showFloatingWindow: window shown, isVisible: \(floatingWindow?.isVisible ?? false)")
    }

    func completeTask() {
        // Close the floating window immediately
        floatingWindow?.orderOut(nil)
        floatingWindow?.close()
        floatingWindow = nil

        // Clear the task
        TaskManager.shared.clearTask()

        // Trigger Raycast confetti
        if let confettiURL = URL(string: "raycast://extensions/raycast/raycast/confetti") {
            NSWorkspace.shared.open(confettiURL)
        }

        // Terminate app
        NSApp.terminate(nil)
    }
}

// Custom window class for floating reminder (draggable)
class FloatingWindow: NSWindow {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }
}

// Custom window class for blocking prompt (accepts keyboard input)
class KeyableWindow: NSWindow {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }

    override var acceptsFirstResponder: Bool { true }

    // Prevent escape from closing the window
    override func cancelOperation(_ sender: Any?) {
        // Do nothing - don't allow escape to close
    }

    // Prevent cmd+w from closing
    override func performClose(_ sender: Any?) {
        // Do nothing - don't allow closing
    }
}
