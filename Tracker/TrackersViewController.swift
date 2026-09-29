import UIKit

final class TrackersViewController: UIViewController {
    
    // MARK: - Данные
    private var categories: [TrackerCategory] = []           // Все категории с трекерами
    private var completedTrackers: [TrackerRecord] = []      // Записи о выполненных трекерах
    private var visibleCategories: [TrackerCategory] = []    // Категории, видимые на выбранную дату
    private var currentDate: Date = Date()                   // Текущая выбранная дата
    
    // MARK: - Store-классы (слой абстракции от Core Data)
    private let trackerStore = TrackerStore()
    private let categoryStore = TrackerCategoryStore()
    private let recordStore = TrackerRecordStore()
    
    // MARK: - UI Элементы
    
    // Кнопка "+" в левом верхнем углу (для добавления трекера)
    private lazy var addButton: UIBarButtonItem = {
        let button = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(didTapAddButton)
        )
        button.tintColor = UIColor(named: "YPBlack") ?? .black
        return button
    }()
    
    // Кнопка с датой в правом верхнем углу (UIDatePicker)
    private lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .compact
        picker.overrideUserInterfaceStyle = .light
        picker.tintColor = UIColor(named: "YPBlack") ?? .black
        picker.locale = Locale(identifier: "ru_RU")
        picker.calendar.locale = Locale(identifier: "ru_RU")
        picker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        return picker
    }()
    
    // Заголовок "Трекеры" (большой, слева)
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Трекеры"
        label.font = UIFont(name: "SFProText-Bold", size: 34) ?? .systemFont(ofSize: 34, weight: .bold)
        label.textColor = UIColor(named: "YPBlack") ?? .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Поле поиска (UISearchTextField)
    private lazy var searchTextField: UISearchTextField = {
        let searchField = UISearchTextField()
        searchField.placeholder = "Поиск"
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
    
    // Коллекция для отображения трекеров (UICollectionView)
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
        return collectionView
    }()
    
    // Картинка-заглушка "Plug" (звёздочка)
    private lazy var placeholderImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Plug")
        imageView.tintColor = UIColor(named: "YPBlack") ?? .black
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    // Текст заглушки "Что будем отслеживать?"
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Что будем отслеживать?"
        label.font = UIFont(name: "SFProText-Medium", size: 12) ?? .systemFont(ofSize: 12, weight: .medium)
        label.textColor = UIColor(named: "YPBlack") ?? .black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Жизненный цикл
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupNavBar()
        setupViews()
        setupConstraints()
        setupKeyboardDismissGesture()
        
        loadData() // 🔥 Загружаем данные из Core Data
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
        view.addSubview(placeholderImageView)
        view.addSubview(placeholderLabel)
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
    
    // MARK: - Фильтрация трекеров по дате
    private func updateVisibleCategories() {
        let weekday = Calendar.current.component(.weekday, from: currentDate)
        let weekdaysMap: [Int: Weekday] = [
            1: .sunday, 2: .monday, 3: .tuesday, 4: .wednesday,
            5: .thursday, 6: .friday, 7: .saturday
        ]
        
        guard let currentWeekday = weekdaysMap[weekday] else { return }
        
        visibleCategories = categories.compactMap { category in
            let filteredTrackers = category.trackers.filter { tracker in
                guard let schedule = tracker.schedule else { return true }
                return schedule.contains(currentWeekday)
            }
            return filteredTrackers.isEmpty ? nil : TrackerCategory(title: category.title, trackers: filteredTrackers)
        }
        
        collectionView.reloadData()
        updatePlaceholderVisibility()
    }
    
    // MARK: - Показать/скрыть заглушку
    private func updatePlaceholderVisibility() {
        let isEmpty = visibleCategories.isEmpty
        placeholderImageView.isHidden = !isEmpty
        placeholderLabel.isHidden = !isEmpty
        collectionView.isHidden = isEmpty
    }
    
    // MARK: - Действия
    
    // Нажатие на кнопку "+"
    @objc private func didTapAddButton() {
        let createVC = CreateTrackerViewController()
        createVC.delegate = self
        let navController = UINavigationController(rootViewController: createVC)
        present(navController, animated: true)
    }
    
    // Изменение даты в UIDatePicker
    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        currentDate = sender.date
        updateVisibleCategories()
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
        
        // Проверяем, выполнен ли трекер на текущую дату
        let isCompleted = completedTrackers.contains {
            $0.trackerId == tracker.id && Calendar.current.isDate($0.date, inSameDayAs: currentDate)
        }
        // Считаем количество выполнений за всю историю
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
        // Нельзя отмечать будущие даты
        if currentDate > Date() {
            print("Нельзя отметить будущую дату")
            return
        }
        
        let record = TrackerRecord(trackerId: trackerId, date: currentDate)
        
        do {
            // Проверяем, есть ли уже запись на эту дату
            if try recordStore.isCompleted(trackerId: trackerId, on: currentDate) {
                try recordStore.deleteRecord(record) // Снимаем отметку
            } else {
                try recordStore.addRecord(record)    // Ставим отметку
            }
            // Обновляем данные из базы
            completedTrackers = try recordStore.fetchRecords()
            collectionView.reloadData()
        } catch {
            print("[TrackersViewController] Ошибка изменения отметки: \(error)")
        }
    }
}

// MARK: - CreateTrackerViewControllerDelegate
extension TrackersViewController: CreateTrackerViewControllerDelegate {
    
    func didCreateTracker(_ tracker: Tracker, categoryTitle: String) {
        do {
            // Сохраняем трекер в Core Data
            try trackerStore.addTracker(tracker, toCategoryWithTitle: categoryTitle)
            // Перезагружаем данные
            loadData()
        } catch {
            print("[TrackersViewController] Ошибка добавления трекера: \(error)")
        }
    }
}
