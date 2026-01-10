import Foundation
import AppKit

class WindowPositionManager {
    static let shared = WindowPositionManager()

    private let xKey = "floatingWindowX"
    private let yKey = "floatingWindowY"

    private init() {}

    func savePosition(_ origin: CGPoint) {
        UserDefaults.standard.set(origin.x, forKey: xKey)
        UserDefaults.standard.set(origin.y, forKey: yKey)
    }

    func loadPosition() -> CGPoint? {
        guard UserDefaults.standard.object(forKey: xKey) != nil,
              UserDefaults.standard.object(forKey: yKey) != nil else {
            return nil
        }

        let x = UserDefaults.standard.double(forKey: xKey)
        let y = UserDefaults.standard.double(forKey: yKey)
        return CGPoint(x: x, y: y)
    }

    func clearPosition() {
        UserDefaults.standard.removeObject(forKey: xKey)
        UserDefaults.standard.removeObject(forKey: yKey)
    }
}
