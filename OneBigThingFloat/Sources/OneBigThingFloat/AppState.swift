import Foundation
import Combine

class AppState: ObservableObject {
    static let shared = AppState()

    @Published var submittedTask: String? = nil

    private init() {}
}
