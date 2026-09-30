import UIKit
import CoreData

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {

    // MARK: - Core Data Stack
    
    /// Persistent Container — управляет всем стеком Core Data
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TrackerModel")
        
        // Загружаем хранилища (создаются автоматически при первом запуске)
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                // Если не удалось, крашим
                assertionFailure("Не удалось загрузить хранилище: \(error), \(error.userInfo)")
            }
        }
        
        return container
    }()
    
    // MARK: - Core Data Saving Support
    
    /// Сохраняет изменения контекста в базу данных
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                assertionFailure("Не удалось сохранить контекст: \(nserror), \(nserror.userInfo)")
            }
        }
    }

    // MARK: - Application Lifecycle
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        return true
    }

    // MARK: - UISceneSession Lifecycle

    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        let sceneConfiguration = UISceneConfiguration(
            name: "Default Configuration",
            sessionRole: connectingSceneSession.role
        )
        sceneConfiguration.delegateClass = SceneDelegate.self
        return sceneConfiguration
    }

    func application(
        _ application: UIApplication,
        didDiscardSceneSessions sceneSessions: Set<UISceneSession>
    ) {
        // Called when the user discards a scene session.
    }
}
