import CoreData
import UIKit

final class TrackerRecordStore {
    
    // MARK: - Свойства
    private let context: NSManagedObjectContext
    
    // MARK: - Init
    convenience init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    // MARK: - CRUD
    
    /// Добавить запись о выполнении
    func addRecord(_ record: TrackerRecord) throws {
        let recordCoreData = TrackerRecordCoreData(context: context)
        recordCoreData.trackerId = record.trackerId
        recordCoreData.date = record.date
        try context.save()
    }
    
    /// Удалить запись
    func deleteRecord(_ record: TrackerRecord) throws {
        let request: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        request.predicate = NSPredicate(
            format: "trackerId == %@ AND date == %@",
            record.trackerId as CVarArg,
            record.date as CVarArg
        )
        if let object = try context.fetch(request).first {
            context.delete(object)
            try context.save()
        }
    }
    
    /// Получить все записи
    func fetchRecords() throws -> [TrackerRecord] {
        let request: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        let result = try context.fetch(request)
        return result.compactMap { recordCoreData in
            guard let trackerId = recordCoreData.trackerId,
                  let date = recordCoreData.date else { return nil }
            return TrackerRecord(trackerId: trackerId, date: date)
        }
    }
    
    /// Получить количество выполнений для трекера
    func completedCount(for trackerId: UUID) throws -> Int {
        let request: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "trackerId == %@", trackerId as CVarArg)
        return try context.count(for: request)
    }
    
    /// Проверить, выполнен ли трекер на дату
    func isCompleted(trackerId: UUID, on date: Date) throws -> Bool {
        let request: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        let startOfDay = Calendar.current.startOfDay(for: date)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
        request.predicate = NSPredicate(
            format: "trackerId == %@ AND date >= %@ AND date < %@",
            trackerId as CVarArg,
            startOfDay as CVarArg,
            endOfDay as CVarArg
        )
        return try context.count(for: request) > 0
    }
}
