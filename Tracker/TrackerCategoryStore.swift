import CoreData
import UIKit

final class TrackerCategoryStore {
    
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
    
    /// Получить все категории с трекерами
    func fetchCategories() throws -> [TrackerCategory] {
        let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        let result = try context.fetch(request)
        
        return result.compactMap { (categoryCoreData: TrackerCategoryCoreData) -> TrackerCategory? in
            guard let title = categoryCoreData.title else { return nil }
            
            let trackers = (categoryCoreData.trackers as? Set<TrackerCoreData>)?.compactMap { (trackerCoreData: TrackerCoreData) -> Tracker? in
                guard let id = trackerCoreData.id,
                      let trackerTitle = trackerCoreData.title,
                      let colorHex = trackerCoreData.color,
                      let emoji = trackerCoreData.emoji else { return nil }
                
                let color = UIColorMarshalling().color(from: colorHex)
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
