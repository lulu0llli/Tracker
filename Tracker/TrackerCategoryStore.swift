import CoreData
import UIKit

// MARK: - Делегат Store (без Core Data)
protocol TrackerCategoryStoreDelegate: AnyObject {
    func didUpdate(_ update: TrackerCategoryStoreUpdate)
}

// MARK: - Структура обновлений
struct TrackerCategoryStoreUpdate {
    let insertedIndexes: IndexSet
    let deletedIndexes: IndexSet
}

final class TrackerCategoryStore: NSObject {
    
    // MARK: - Свойства
    private let context: NSManagedObjectContext
    private let colorMarshalling = UIColorMarshalling()
    
    weak var delegate: TrackerCategoryStoreDelegate?
    
    private var insertedIndexes: IndexSet?
    private var deletedIndexes: IndexSet?
    
    // MARK: - NSFetchedResultsController
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData> = {
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "title", ascending: true)
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
    
    /// Получить все категории с трекерами
    func fetchCategories() throws -> [TrackerCategory] {
        guard let objects = fetchedResultsController.fetchedObjects else { return [] }
        
        return objects.compactMap { categoryCoreData -> TrackerCategory? in
            guard let title = categoryCoreData.title else { return nil }
            
            let trackers = (categoryCoreData.trackers as? Set<TrackerCoreData>)?.compactMap { trackerCoreData -> Tracker? in
                guard let id = trackerCoreData.id,
                      let trackerTitle = trackerCoreData.title,
                      let colorHex = trackerCoreData.color,
                      let emoji = trackerCoreData.emoji else { return nil }
                
                let color = colorMarshalling.color(from: colorHex)
                let schedule = trackerCoreData.schedule?
                    .split(separator: ",")
                    .compactMap { Weekday(rawValue: String($0)) }
                
                return Tracker(
                    id: id,
                    title: trackerTitle,
                    color: color,
                    emoji: emoji,
                    schedule: schedule
                )
            } ?? []
            
            return TrackerCategory(title: title, trackers: trackers)
        }
    }
    
    /// Добавить новую категорию
    func addCategory(title: String) throws {
        let category = TrackerCategoryCoreData(context: context)
        category.title = title
        try context.save()
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexes = IndexSet()
        deletedIndexes = IndexSet()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdate(TrackerCategoryStoreUpdate(
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
