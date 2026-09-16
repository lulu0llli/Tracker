import Foundation

extension Int {
    // Возвращает правильную форму слова "день" для числа
    var daysWord: String {
        let lastTwoDigits = self % 100
        let lastDigit = self % 10
        
        if (11...14).contains(lastTwoDigits) { return "дней" }
        if lastDigit == 1 { return "день" }
        if (2...4).contains(lastDigit) { return "дня" }
        return "дней"
    }
}
