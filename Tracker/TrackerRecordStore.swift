import CoreData
import UIKit

// MARK: - Делегат Store (без Core Data)
protocol TrackerRecordStoreDelegate: AnyObject {
    func didUpdate(_ update: TrackerRecordStoreUpdate)
}

// MARK: - Структура обновлений
struct TrackerRecordStoreUpdate {
    let insertedIndexes: IndexSet
    let deletedIndexes: IndexSet
}

final class TrackerRecordStore: NSObject {
    
    // MARK: - Свойства
    private let context: NSManagedObjectContext
    
    weak var delegate: TrackerRecordStoreDelegate?
    
    private var insertedIndexes: IndexSet?
    private var deletedIndexes: IndexSet?
    
    // MARK: - NSFetchedResultsController
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerRecordCoreData> = {
        let fetchRequest = TrackerRecordCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "date", ascending: false)
        ]
        
        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        controller.delegate = self
        try? controller.performFetch()
        return controller
    }()
    
    // MARK: - Init
    override convenience init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
    }
    
    // MARK: - CRUD
    
    /// Добавить запись о выполнении
    func addRecord(_ record: TrackerRecord) throws {
        let recordCoreData = TrackerRecordCoreData(context: context)
        recordCoreData.trackerId = record.trackerId
        recordCoreData.date = Calendar.current.startOfDay(for: record.date)
        try context.save()
    }
    
    /// Удалить запись
    func deleteRecord(_ record: TrackerRecord) throws {
        let request: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        let startOfDay = Calendar.current.startOfDay(for: record.date)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
        request.predicate = NSPredicate(
            format: "trackerId == %@ AND date >= %@ AND date < %@",
            record.trackerId as CVarArg,
            startOfDay as CVarArg,
            endOfDay as CVarArg
        )
        if let object = try context.fetch(request).first {
            context.delete(object)
            try context.save()
        }
    }
    
    /// Получить все записи
    func fetchRecords() throws -> [TrackerRecord] {
        guard let objects = fetchedResultsController.fetchedObjects else { return [] }
        return objects.compactMap { recordCoreData in
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

// MARK: - NSFetchedResultsControllerDelegate
extension TrackerRecordStore: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexes = IndexSet()
        deletedIndexes = IndexSet()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdate(TrackerRecordStoreUpdate(
            insertedIndexes: insertedIndexes ?? IndexSet(),
            deletedIndexes: deletedIndexes ?? IndexSet()
        ))
        insertedIndexes = nil
        deletedIndexes = nil
    }
    
    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?
    ) {
        switch type {
        case .delete:
            if let indexPath = indexPath {
                deletedIndexes?.insert(indexPath.item)
            }
        case .insert:
            if let newIndexPath = newIndexPath {
                insertedIndexes?.insert(newIndexPath.item)
            }
        default:
            break
        }
    }
}
