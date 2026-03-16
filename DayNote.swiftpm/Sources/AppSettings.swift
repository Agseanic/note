import Foundation
import SwiftUI

class AppSettings: ObservableObject {
    @AppStorage("enableiCloud") var enableiCloud: Bool = false
    @AppStorage("enableAISummary") var enableAISummary: Bool = false
    @AppStorage("aiAPIKey") var aiAPIKey: String = ""
    @AppStorage("dailyReminderEnabled") var dailyReminderEnabled: Bool = false
    @AppStorage("dailyReminderHour") var dailyReminderHour: Int = 22
    @AppStorage("dailyReminderMinute") var dailyReminderMinute: Int = 0
}
