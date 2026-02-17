import SwiftUI

@main
struct HabitTrackerApp: App {
    init() {
        NotificationManager.shared.requestAuthorization()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
