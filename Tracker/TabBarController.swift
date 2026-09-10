import UIKit

final class TabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Вкладка "Трекеры"
        let trackersVC = TrackersViewController()
        let trackersNavController = UINavigationController(rootViewController: trackersVC)
        trackersNavController.tabBarItem = UITabBarItem(
            title: "Трекеры",
            image: UIImage(named: "Trackers")?.withRenderingMode(.alwaysTemplate),
            selectedImage: UIImage(named: "Trackers")?.withRenderingMode(.alwaysTemplate)
        )
        
        // Вкладка "Статистика"
        let statisticsVC = StatisticsViewController()
        statisticsVC.tabBarItem = UITabBarItem(
            title: "Статистика",
            image: UIImage(named: "Statistics")?.withRenderingMode(.alwaysTemplate),
            selectedImage: UIImage(named: "Statistics")?.withRenderingMode(.alwaysTemplate)
        )
        
        viewControllers = [trackersNavController, statisticsVC]
        
        // Цвета TabBar 
        tabBar.tintColor = UIColor(named: "Blue") ?? UIColor(red: 55/255, green: 114/255, blue: 231/255, alpha: 1) // #3772E7
        tabBar.unselectedItemTintColor = UIColor(red: 174/255, green: 175/255, blue: 180/255, alpha: 1) // #AEAFB4
        tabBar.backgroundColor = .white
        tabBar.isTranslucent = false
    }
}
