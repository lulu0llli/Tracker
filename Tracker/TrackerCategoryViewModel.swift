import Foundation

final class TrackerCategoryViewModel {
    
    // MARK: - Байндинги
    var onCategoriesChange: (() -> Void)?
    var onError: ((String) -> Void)?
    
    // MARK: - Данные
    private(set) var categories: [TrackerCategory] = []
    private(set) var selectedCategoryIndex: Int?
    
    private let categoryStore: TrackerCategoryStore
    
    // MARK: - Init
    init(categoryStore: TrackerCategoryStore = TrackerCategoryStore()) {
        self.categoryStore = categoryStore
    }
    
    // MARK: - Загрузка
    func fetchCategories() {
        do {
            categories = try categoryStore.fetchCategories()
            
            // Сбрасываем выбранный индекс, если он больше не существует
            if let index = selectedCategoryIndex, index >= categories.count {
                selectedCategoryIndex = nil
            }
            
            onCategoriesChange?()
        } catch {
            onError?("Ошибка загрузки: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Добавление
    func addCategory(title: String) {
        do {
            try categoryStore.addCategory(title: title)
            fetchCategories()
        } catch {
            onError?("Ошибка добавления: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Количество
    var numberOfCategories: Int {
        categories.count
    }
    
    // MARK: - Получить категорию
    func category(at index: Int) -> TrackerCategory? {
        guard index >= 0, index < categories.count else { return nil }
        return categories[index]
    }
    
    // MARK: - Выбор категории
    func selectCategory(at index: Int) {
        guard index >= 0, index < categories.count else { return }
        selectedCategoryIndex = index
        onCategoriesChange?()
    }
    
    // MARK: - Проверка: выбрана ли категория по индексу
    func isSelected(at index: Int) -> Bool {
        return selectedCategoryIndex == index
    }
    
    // MARK: - Выбранная категория
    var selectedCategory: TrackerCategory? {
        guard let index = selectedCategoryIndex else { return nil }
        return category(at: index)
    }
}
