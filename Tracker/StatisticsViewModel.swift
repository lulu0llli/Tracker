import Foundation

final class StatisticsViewModel {
    
    // MARK: - Байдинги
    var onStatisticsChange: ((Int) -> Void)?
    
    // MARK: - Данные
    private(set) var completedCount: Int = 0 {
        didSet {
            onStatisticsChange?(completedCount)
        }
    }
    
    // MARK: - Store
    private let recordStore = TrackerRecordStore()
    
    // MARK: - Init
    init() {
        recordStore.delegate = self
        loadStatistics()
    }
    
    // MARK: - Загрузка
    func loadStatistics() {
        do {
            let records = try recordStore.fetchRecords()
            completedCount = records.count
        } catch {
            print("[StatisticsViewModel] Ошибка загрузки статистики: \(error)")
            completedCount = 0
        }
    }
}

// MARK: - TrackerRecordStoreDelegate
extension StatisticsViewModel: TrackerRecordStoreDelegate {
    func didUpdate(_ update: TrackerRecordStoreUpdate) {
        loadStatistics()
    }
}
