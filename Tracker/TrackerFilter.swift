import Foundation

enum TrackerFilter: String, CaseIterable {
    case all = "all"
    case today = "today"
    case completed = "completed"
    case uncompleted = "uncompleted"
    
    var localizedTitle: String {
        switch self {
        case .all:
            return NSLocalizedString("filter_all", comment: "Все трекеры")
        case .today:
            return NSLocalizedString("filter_today", comment: "Трекеры на сегодня")
        case .completed:
            return NSLocalizedString("filter_completed", comment: "Завершённые")
        case .uncompleted:
            return NSLocalizedString("filter_uncompleted", comment: "Незавершённые")
        }
    }
    
    /// Показывать ли галочку для этого фильтра
    var shouldShowCheckmark: Bool {
        switch self {
        case .all, .today:
            return false
        case .completed, .uncompleted:
            return true
        }
    }
}
