import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        
        // Проверяем, проходил ли пользователь онбординг
        let onboardingCompleted = UserDefaults.standard.bool(forKey: "onboardingCompleted")
        
        if onboardingCompleted {
            // Онбординг уже пройден — показываем главный экран
            window?.rootViewController = TabBarController()
        } else {
            // Первый запуск — показываем онбординг
            let onboardingVC = OnboardingViewController(
                transitionStyle: .scroll,
                navigationOrientation: .horizontal
            )
            window?.rootViewController = onboardingVC
        }
        
        window?.makeKeyAndVisible()
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }
}
