import Foundation
import YandexMobileMetrica

final class AnalyticsService {
    
    static let shared = AnalyticsService()
    private init() {}
    
    // MARK: - Открытие экрана
    func reportOpen(screen: String) {
        let params: [AnyHashable: Any] = [
            "event": "open",
            "screen": screen
        ]
        report(event: "open", params: params)
    }
    
    // MARK: - Закрытие экрана
    func reportClose(screen: String) {
        let params: [AnyHashable: Any] = [
            "event": "close",
            "screen": screen
        ]
        report(event: "close", params: params)
    }
    
    // MARK: - Клик на кнопку
    func reportClick(screen: String, item: String) {
        let params: [AnyHashable: Any] = [
            "event": "click",
            "screen": screen,
            "item": item
        ]
        report(event: "click", params: params)
    }
    
    // MARK: - Внутренний метод отправки
    private func report(event: String, params: [AnyHashable: Any]) {
        YMMYandexMetrica.reportEvent(event, parameters: params, onFailure: { error in
            print("[AnalyticsService] Ошибка отправки события \(event): \(error.localizedDescription)")
        })
        
        // Логирование для тестов (по ТЗ)
        print("[Analytics] Event: \(params["event"] ?? ""), Screen: \(params["screen"] ?? ""), Item: \(params["item"] ?? "-")")
    }
}
