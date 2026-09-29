import CoreData
import UIKit

final class TrackerStore {
    
    // MARK: - Свойства
    private let context: NSManagedObjectContext
    private let colorMarshalling = UIColorMarshalling()
    
    // MARK: - Init
    convenience init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    // MARK: - CRUD
    
    /// Добавить новый трекер в указанную категорию
    func addTracker(_ tracker: Tracker, toCategoryWithTitle title: String) throws {
        // Находим или создаём категорию
        let categoryRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        categoryRequest.predicate = NSPredicate(format: "title == %@", title)
        let categories = try context.fetch(categoryRequest)
        
        let category: TrackerCategoryCoreData
        if let existingCategory = categories.first {
            category = existingCategory
        } else {
            category = TrackerCategoryCoreData(context: context)
            category.title = title
        }
        
        // Создаём трекер
        let trackerCoreData = TrackerCoreData(context: context)
        trackerCoreData.id = tracker.id
        trackerCoreData.title = tracker.title
        trackerCoreData.color = colorMarshalling.hexString(from: tracker.color)
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.schedule = tracker.schedule?.map { $0.rawValue }.joined(separator: ",")
        trackerCoreData.category = category
        
        try context.save()
    }
    
    /// Получить все трекеры
    func fetchTrackers() throws -> [Tracker] {
        let request: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        let result = try context.fetch(request)
        return result.compactMap { trackerCoreData in
            guard let id = trackerCoreData.id,
                  let title = trackerCoreData.title,
                  let colorHex = trackerCoreData.color,
                  let emoji = trackerCoreData.emoji else { return nil }
            
            let color = colorMarshalling.color(from: colorHex)
            let schedule = trackerCoreData.schedule?
                .split(separator: ",")
                .compactMap { Weekday(rawValue: String($0)) }
            
            return Tracker(
                id: id,
                title: title,
                color: color,
                emoji: emoji,
                schedule: schedule
            )
        }
    }
    
    /// Удалить трекер
    func deleteTracker(_ tracker: Tracker) throws {
        let request: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", tracker.id as CVarArg)
        if let object = try context.fetch(request).first {
            context.delete(object)
            try context.save()
        }
    }
}
