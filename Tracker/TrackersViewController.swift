import UIKit

final class TrackersViewController: UIViewController {
    
    // MARK: - Данные
    private var categories: [TrackerCategory] = []
    private var completedTrackers: [TrackerRecord] = []
    private var visibleCategories: [TrackerCategory] = []
    private var currentDate: Date = Date()
    private var searchText: String = ""
    
    // MARK: - Фильтры
    private var currentFilter: TrackerFilter {
        didSet {
            UserDefaults.standard.set(currentFilter.rawValue, forKey: "selectedFilter")
        }
    }
    
    // MARK: - Store-классы
    private let trackerStore = TrackerStore()
    private let categoryStore = TrackerCategoryStore()
    private let recordStore = TrackerRecordStore()
    
    // MARK: - UI Элементы
    
    private lazy var addButton: UIBarButtonItem = {
        let button = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(didTapAddButton)
        )
        button.tintColor = UIColor(named: "YPBlack") ?? .black
        return button
    }()
    
    private lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .compact
        picker.tintColor = UIColor(named: "YPBlack") ?? .black
        picker.locale = Locale(identifier: "ru_RU")
        picker.calendar.locale = Locale(identifier: "ru_RU")
        picker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        return picker
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("trackers_title", comment: "Заголовок главного экрана")
        label.font = UIFont(name: "SFProText-Bold", size: 34) ?? .systemFont(ofSize: 34, weight: .bold)
        label.textColor = UIColor(named: "YPBlack") ?? .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var searchTextField: UISearchTextField = {
        let searchField = UISearchTextField()
        searchField.placeholder = NSLocalizedString("search_placeholder", comment: "Плейсхолдер поиска")
        searchField.backgroundColor = UIColor(named: "YPBackgroundSearch")
        searchField.layer.cornerRadius = 10
        searchField.font = UIFont(name: "SFProText-Regular", size: 17) ?? .systemFont(ofSize: 17)
        
        let magnifyingGlass = UIImage(systemName: "magnifyingglass")
        let leftView = UIImageView(image: magnifyingGlass)
        leftView.tintColor = UIColor(named: "YPGrey") ?? .systemGray
        searchField.leftView = leftView
        searchField.leftViewMode = .always
        
        searchField.translatesAutoresizingMaskIntoConstraints = false
        return searchField
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(TrackerCell.self, forCellWithReuseIdentifier: TrackerCell.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        collectionView.contentInset.bottom = 100 // Отступ для кнопки фильтров
        return collectionView
    }()
    
    private lazy var filtersButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("filters_button", comment: "Кнопка Фильтры"), for: .normal)
        button.titleLabel?.font = UIFont(name: "SFProText-Regular", size: 17) ?? .systemFont(ofSize: 17)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(named: "YPBlue") ?? .systemBlue
        button.layer.cornerRadius = 16
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        button.addTarget(self, action: #selector(didTapFiltersButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var placeholderImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Plug")
        imageView.tintColor = UIColor(named: "YPBlack") ?? .black
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("empty_state_title", comment: "Заглушка пустого списка")
        label.font = UIFont(name: "SFProText-Medium", size: 12) ?? .systemFont(ofSize: 12, weight: .medium)
        label.textColor = UIColor(named: "YPBlack") ?? .black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Init
    init() {
        let savedFilter = UserDefaults.standard.string(forKey: "selectedFilter") ?? TrackerFilter.all.rawValue
        self.currentFilter = TrackerFilter(rawValue: savedFilter) ?? .all
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Жизненный цикл
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "YPWhite")
        
        setupNavBar()
        setupViews()
        setupConstraints()
        setupKeyboardDismissGesture()
        
        trackerStore.delegate = self
        categoryStore.delegate = self
        recordStore.delegate = self
        
        loadData()
    }
    
    // MARK: - Настройка навигационной панели
    private func setupNavBar() {
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.title = ""
        
        navigationItem.leftBarButtonItem = addButton
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
    }
    
    // MARK: - Добавление элементов на экран
    private func setupViews() {
        view.addSubview(titleLabel)
        view.addSubview(searchTextField)
        view.addSubview(collectionView)
        view.addSubview(filtersButton)
        view.addSubview(placeholderImageView)
        view.addSubview(placeholderLabel)
        
        searchTextField.addTarget(self, action: #selector(searchTextDidChange(_:)), for: .editingChanged)
    }
    
    // MARK: - Констрейнты
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 88),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.widthAnchor.constraint(equalToConstant: 254),
            titleLabel.heightAnchor.constraint(equalToConstant: 41),
            
            searchTextField.topAnchor.constraint(equalTo: view.topAnchor, constant: 136),
            searchTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            searchTextField.heightAnchor.constraint(equalToConstant: 36),
            
            collectionView.topAnchor.constraint(equalTo: searchTextField.bottomAnchor, constant: 16),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            filtersButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filtersButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            filtersButton.heightAnchor.constraint(equalToConstant: 50),
            
            placeholderImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20),
            placeholderImageView.widthAnchor.constraint(equalToConstant: 80),
            placeholderImageView.heightAnchor.constraint(equalToConstant: 80),
            
            placeholderLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderLabel.topAnchor.constraint(equalTo: placeholderImageView.bottomAnchor, constant: 8),
            placeholderLabel.widthAnchor.constraint(equalToConstant: 343),
            placeholderLabel.heightAnchor.constraint(equalToConstant: 18)
        ])
    }
    
    // MARK: - Закрытие клавиатуры
    private func setupKeyboardDismissGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Загрузка данных из Core Data
    private func loadData() {
        do {
            categories = try categoryStore.fetchCategories()
            completedTrackers = try recordStore.fetchRecords()
            updateVisibleCategories()
        } catch {
            print("[TrackersViewController] Ошибка загрузки данных: \(error)")
        }
    }
    
    // MARK: - Фильтрация трекеров
    private func updateVisibleCategories() {
        // 1. Фильтр по дню недели
        let weekday = Calendar.current.component(.weekday, from: currentDate)
        let weekdaysMap: [Int: Weekday] = [
            1: .sunday, 2: .monday, 3: .tuesday, 4: .wednesday,
            5: .thursday, 6: .friday, 7: .saturday
        ]
        
        guard let currentWeekday = weekdaysMap[weekday] else { return }
        
        let categoriesByDay = categories.compactMap { category -> TrackerCategory? in
            let filteredTrackers = category.trackers.filter { tracker in
                guard let schedule = tracker.schedule else { return true }
                return schedule.contains(currentWeekday)
            }
            return filteredTrackers.isEmpty ? nil : TrackerCategory(title: category.title, trackers: filteredTrackers)
        }
        
        // 2. Фильтр по поиску
        let categoriesBySearch: [TrackerCategory]
        if searchText.isEmpty {
            categoriesBySearch = categoriesByDay
        } else {
            let lowercasedText = searchText.lowercased()
            categoriesBySearch = categoriesByDay.compactMap { category -> TrackerCategory? in
                let filteredTrackers = category.trackers.filter { tracker in
                    tracker.title.lowercased().contains(lowercasedText)
                }
                return filteredTrackers.isEmpty ? nil : TrackerCategory(title: category.title, trackers: filteredTrackers)
            }
        }
        
        // 3. Фильтр по статусу (завершённые / незавершённые)
        visibleCategories = applyStatusFilter(categoriesBySearch)
        
        collectionView.reloadData()
        updatePlaceholderVisibility()
        updateFiltersButtonVisibility()
    }
    
    // MARK: - Фильтр по статусу
    private func applyStatusFilter(_ categories: [TrackerCategory]) -> [TrackerCategory] {
        switch currentFilter {
        case .all, .today:
            return categories
        case .completed:
            return categories.compactMap { category -> TrackerCategory? in
                let filtered = category.trackers.filter { isTrackerCompleted($0, on: currentDate) }
                return filtered.isEmpty ? nil : TrackerCategory(title: category.title, trackers: filtered)
            }
        case .uncompleted:
            return categories.compactMap { category -> TrackerCategory? in
                let filtered = category.trackers.filter { !isTrackerCompleted($0, on: currentDate) }
                return filtered.isEmpty ? nil : TrackerCategory(title: category.title, trackers: filtered)
            }
        }
    }
    
    /// Проверяет, выполнен ли трекер на указанную дату
    private func isTrackerCompleted(_ tracker: Tracker, on date: Date) -> Bool {
        completedTrackers.contains {
            $0.trackerId == tracker.id && Calendar.current.isDate($0.date, inSameDayAs: date)
        }
    }
    
    // MARK: - Показать/скрыть заглушку
    private func updatePlaceholderVisibility() {
        let isEmpty = visibleCategories.isEmpty
        placeholderImageView.isHidden = !isEmpty
        placeholderLabel.isHidden = !isEmpty
        collectionView.isHidden = isEmpty
        
        if isEmpty {
            let isSearching = !searchText.isEmpty
            let isFiltering = currentFilter == .completed || currentFilter == .uncompleted
            
            if isSearching || isFiltering {
                placeholderImageView.image = UIImage(named: "ErrorTrackers")
                placeholderLabel.text = NSLocalizedString("nothing_found_title", comment: "Ничего не найдено")
            } else {
                placeholderImageView.image = UIImage(named: "Plug")
                placeholderLabel.text = NSLocalizedString("empty_state_title", comment: "Заглушка пустого списка")
            }
        }
    }
    
    // MARK: - Видимость кнопки фильтров
    private func updateFiltersButtonVisibility() {
        // Скрываем, если нет трекеров вообще на выбранный день (без учёта фильтров по статусу и поиска)
        let weekday = Calendar.current.component(.weekday, from: currentDate)
        let weekdaysMap: [Int: Weekday] = [
            1: .sunday, 2: .monday, 3: .tuesday, 4: .wednesday,
            5: .thursday, 6: .friday, 7: .saturday
        ]
        guard let currentWeekday = weekdaysMap[weekday] else { return }
        
        let hasTrackersOnDay = categories.contains { category in
            category.trackers.contains { tracker in
                guard let schedule = tracker.schedule else { return true }
                return schedule.contains(currentWeekday)
            }
        }
        
        filtersButton.isHidden = !hasTrackersOnDay
    }
    
    // MARK: - Действия
    
    @objc private func didTapAddButton() {
        let createVC = CreateTrackerViewController()
        createVC.delegate = self
        let navController = UINavigationController(rootViewController: createVC)
        present(navController, animated: true)
    }
    
    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        currentDate = sender.date
        updateVisibleCategories()
    }
    
    @objc private func searchTextDidChange(_ textField: UISearchTextField) {
        searchText = textField.text ?? ""
        updateVisibleCategories()
    }
    
    @objc private func didTapFiltersButton() {
        let filtersVC = FiltersViewController(selectedFilter: currentFilter)
        filtersVC.onFilterSelected = { [weak self] filter in
            self?.applyFilter(filter)
        }
        present(filtersVC, animated: true)
    }
    
    private func applyFilter(_ filter: TrackerFilter) {
        currentFilter = filter
        
        // Для «Трекеры на сегодня» — переключаем дату на сегодня
        if filter == .today {
            currentDate = Date()
            datePicker.date = currentDate
        }
        
        updateVisibleCategories()
    }
    
    // MARK: - Контекстное меню: действия
    
    private func editTracker(_ tracker: Tracker) {
        print("[TrackersViewController] Редактировать трекер: \(tracker.title)")
    }
    
    private func confirmDeleteTracker(_ tracker: Tracker) {
        let alert = UIAlertController(
            title: NSLocalizedString("delete_alert_title", comment: "Заголовок подтверждения удаления"),
            message: nil,
            preferredStyle: .actionSheet
        )
        
        let deleteAction = UIAlertAction(
            title: NSLocalizedString("delete_alert_delete", comment: "Кнопка Удалить в алерте"),
            style: .destructive
        ) { [weak self] _ in
            self?.deleteTracker(tracker)
        }
        
        let cancelAction = UIAlertAction(
            title: NSLocalizedString("delete_alert_cancel", comment: "Кнопка Отменить в алерте"),
            style: .cancel
        )
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        if let popover = alert.popoverPresentationController {
            popover.sourceView = view
            popover.sourceRect = CGRect(
                x: view.bounds.midX,
                y: view.bounds.midY,
                width: 0,
                height: 0
            )
            popover.permittedArrowDirections = []
        }
        
        present(alert, animated: true)
    }
    
    private func deleteTracker(_ tracker: Tracker) {
        do {
            try trackerStore.deleteTracker(tracker)
        } catch {
            print("[TrackersViewController] Ошибка удаления трекера: \(error)")
        }
    }
}

// MARK: - UICollectionViewDataSource
extension TrackersViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return visibleCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return visibleCategories[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TrackerCell.identifier,
            for: indexPath
        ) as? TrackerCell else {
            return UICollectionViewCell()
        }
        
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.row]
        
        let isCompleted = isTrackerCompleted(tracker, on: currentDate)
        let daysCount = completedTrackers.filter { $0.trackerId == tracker.id }.count
        
        cell.configure(with: tracker, isCompleted: isCompleted, daysCount: daysCount)
        cell.delegate = self
        
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - 8) / 2
        return CGSize(width: width, height: 148)
    }
}

// MARK: - TrackerCellDelegate
extension TrackersViewController: TrackerCellDelegate {
    
    func trackerCellDidTapComplete(_ cell: TrackerCell, trackerId: UUID) {
        if currentDate > Date() {
            print(NSLocalizedString("future_date_error", comment: ""))
            return
        }
        
        let record = TrackerRecord(trackerId: trackerId, date: currentDate)
        
        do {
            if try recordStore.isCompleted(trackerId: trackerId, on: currentDate) {
                try recordStore.deleteRecord(record)
            } else {
                try recordStore.addRecord(record)
            }
            completedTrackers = try recordStore.fetchRecords()
            updateVisibleCategories()
        } catch {
            print("[TrackersViewController] Ошибка изменения отметки: \(error)")
        }
    }
}

// MARK: - CreateTrackerViewControllerDelegate
extension TrackersViewController: CreateTrackerViewControllerDelegate {
    
    func didCreateTracker(_ tracker: Tracker, categoryTitle: String) {
        do {
            try trackerStore.addTracker(tracker, toCategoryWithTitle: categoryTitle)
            loadData()
        } catch {
            print("[TrackersViewController] Ошибка добавления трекера: \(error)")
        }
    }
}

// MARK: - TrackerStoreDelegate
extension TrackersViewController: TrackerStoreDelegate {
    func didUpdate(_ update: TrackerStoreUpdate) {
        loadData()
    }
}

// MARK: - TrackerCategoryStoreDelegate
extension TrackersViewController: TrackerCategoryStoreDelegate {
    func didUpdate(_ update: TrackerCategoryStoreUpdate) {
        loadData()
    }
}

// MARK: - TrackerRecordStoreDelegate
extension TrackersViewController: TrackerRecordStoreDelegate {
    func didUpdate(_ update: TrackerRecordStoreUpdate) {
        loadData()
    }
}

// MARK: - UICollectionViewDelegate (контекстное меню)
extension TrackersViewController: UICollectionViewDelegate {
    
    func collectionView(
        _ collectionView: UICollectionView,
        contextMenuConfigurationForItemAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.row]
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
            guard let self = self else { return nil }
            
            let editAction = UIAction(
                title: NSLocalizedString("context_menu_edit", comment: "Пункт меню Редактировать")
            ) { _ in
                self.editTracker(tracker)
            }
            
            let deleteAction = UIAction(
                title: NSLocalizedString("context_menu_delete", comment: "Пункт меню Удалить"),
                attributes: .destructive
            ) { _ in
                self.confirmDeleteTracker(tracker)
            }
            
            return UIMenu(children: [editAction, deleteAction])
        }
    }
}
