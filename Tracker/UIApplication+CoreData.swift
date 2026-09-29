import UIKit
import CoreData

extension UIApplication {
    /// Быстрый доступ к контексту Core Data
    var viewContext: NSManagedObjectContext {
        guard let appDelegate = delegate as? AppDelegate else {
            fatalError("AppDelegate не найден")
        }
        return appDelegate.persistentContainer.viewContext
    }
}
