import Foundation

extension DateFormatter {
    static let noteDate: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    static let displayDate: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "M月d日 EEEE"
        f.locale = Locale(identifier: "zh_CN")
        return f
    }()

    static let timeOnly: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f
    }()
}

extension Date {
    var noteDateString: String {
        DateFormatter.noteDate.string(from: self)
    }

    var displayDateString: String {
        DateFormatter.displayDate.string(from: self)
    }

    var timeString: String {
        DateFormatter.timeOnly.string(from: self)
    }
}
