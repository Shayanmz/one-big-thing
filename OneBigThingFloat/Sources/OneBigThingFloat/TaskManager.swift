import Foundation

struct TaskData: Codable {
    let task: String
    let date: String
    let createdAt: String
}

class TaskManager {
    static let shared = TaskManager()

    private let fileURL: URL

    private init() {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let oneBigThingDir = appSupport.appendingPathComponent("OneBigThing")

        // Create directory if needed
        try? FileManager.default.createDirectory(at: oneBigThingDir, withIntermediateDirectories: true)

        fileURL = oneBigThingDir.appendingPathComponent("current-task.json")
    }

    func loadTask() -> TaskData? {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return nil
        }

        do {
            let data = try Data(contentsOf: fileURL)
            let task = try JSONDecoder().decode(TaskData.self, from: data)

            // Check if task is from today
            let today = formatDate(Date())
            if task.date != today {
                // Task is stale, remove it
                try? FileManager.default.removeItem(at: fileURL)
                return nil
            }

            return task
        } catch {
            print("Error loading task: \(error)")
            return nil
        }
    }

    func saveTask(_ task: String) {
        let taskData = TaskData(
            task: task,
            date: formatDate(Date()),
            createdAt: ISO8601DateFormatter().string(from: Date())
        )

        do {
            let data = try JSONEncoder().encode(taskData)
            try data.write(to: fileURL)
        } catch {
            print("Error saving task: \(error)")
        }
    }

    func clearTask() {
        try? FileManager.default.removeItem(at: fileURL)
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}
