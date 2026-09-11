import UIKit

final class TrackersViewController: UIViewController {
    
    // MARK: - Данные
    private var categories: [TrackerCategory] = []           // Все категории с трекерами
    private var completedTrackers: [TrackerRecord] = []      // Записи о выполненных трекерах
    private var visibleCategories: [TrackerCategory] = []    // Категории, видимые на выбранную дату
    private var currentDate: Date = Date()                   // Текущая выбранная дата
    
    // MARK: - UI Элементы
    
    // Кнопка "+" в левом верхнем углу (для добавления трекера)
    private lazy var addButton: UIBarButtonItem = {
        let button = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(didTapAddButton)
        )
        button.tintColor = UIColor(named: "YPBlack") ?? .black // #1A1B22
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
    }()// !!! у даты на главном экране: font-family: SF Pro; font-weight: 400; font-style: Regular; font-size: 17px; leading-trim: NONE; line-height: 22px; letter-spacing: 0px; text-align: right; background: #1A1B22;

    
    // Заголовок "Трекеры" (большой, слева)
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Трекеры"
        label.font = UIFont(name: "SFProText-Bold", size: 34) ?? .systemFont(ofSize: 34, weight: .bold)
        label.textColor = UIColor(named: "YPBlack") ?? .black // #1A1B22
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Поле поиска (UISearchTextField)
    private lazy var searchTextField: UISearchTextField = {
        let searchField = UISearchTextField()
        searchField.placeholder = "Поиск"
        searchField.backgroundColor = UIColor(named: "YPBackgroundSearch") // #7676801F (12% прозрачности)
        searchField.layer.cornerRadius = 10
        searchField.font = UIFont(name: "SFProText-Regular", size: 17) ?? .systemFont(ofSize: 17) // !!! Текст "Поиск" font-family: SF Pro; font-weight: 400; font-style: Regular; font-size: 17px; leading-trim: NONE; line-height: 22px; letter-spacing: 0px; background: #AEAFB4;
        
        // Иконка лупы слева
        let magnifyingGlass = UIImage(systemName: "magnifyingglass")
        let leftView = UIImageView(image: magnifyingGlass)
        leftView.tintColor = UIColor(named: "YPGrey") ?? .systemGray // #AEAFB4
        searchField.leftView = leftView
        searchField.leftViewMode = .always
        
        searchField.translatesAutoresizingMaskIntoConstraints = false
        return searchField
    }()
    
    // Коллекция для отображения трекеров (UICollectionView)
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 8   // Отступ между ячейками по горизонтали
        layout.minimumLineSpacing = 8        // Отступ между строками
        
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
        
        setupNavBar()             // Настройка навигационной панели
        setupViews()              // Добавление элементов на экран
        setupConstraints()        // Установка констрейнтов
        addTestData()             // Добавление тестовых данных
        updateVisibleCategories() // Фильтрация трекеров по текущей дате
        setupKeyboardDismissGesture()
    }
    
    // MARK: - Настройка навигационной панели
    private func setupNavBar() {
        // Отключаем стандартный заголовок, используем свой UILabel
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.title = ""
        
        // Кнопка "+" слева
        navigationItem.leftBarButtonItem = addButton
        // Дата справа
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
    }
    
    // MARK: - Добавление элементов на экран
    private func setupViews() {
        view.addSubview(titleLabel)            // Заголовок "Трекеры"
        view.addSubview(searchTextField)       // Поле поиска
        view.addSubview(collectionView)        // Коллекция трекеров
        view.addSubview(placeholderImageView)  // Звёздочка-заглушка
        view.addSubview(placeholderLabel)      // Текст заглушки
    }
    
    // MARK: - Констрейнты (расположение элементов)
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Заголовок "Трекеры" (top 88, left 16)
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 88),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.widthAnchor.constraint(equalToConstant: 254),
            titleLabel.heightAnchor.constraint(equalToConstant: 41),
            
            // Поле поиска (top 136, left 16, right 16, height 36)
            searchTextField.topAnchor.constraint(equalTo: view.topAnchor, constant: 136),
            searchTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            searchTextField.heightAnchor.constraint(equalToConstant: 36),
            
            // Коллекция трекеров (под поиском, до низа экрана)
            collectionView.topAnchor.constraint(equalTo: searchTextField.bottomAnchor, constant: 16),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            // Звёздочка-заглушка (по центру, чуть ниже середины)
            placeholderImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20),
            placeholderImageView.widthAnchor.constraint(equalToConstant: 80),
            placeholderImageView.heightAnchor.constraint(equalToConstant: 80),
            
            // Текст заглушки (под звёздочкой)
            placeholderLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderLabel.topAnchor.constraint(equalTo: placeholderImageView.bottomAnchor, constant: 8),
            placeholderLabel.widthAnchor.constraint(equalToConstant: 343),
            placeholderLabel.heightAnchor.constraint(equalToConstant: 18)
        ])
    }
    
    // MARK: - Закрытие клавиатуры по тапу
    private func setupKeyboardDismissGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Тестовые данные (для отладки)
    private func addTestData() {
        // Создаём трекер "Утренняя зарядка"
        let tracker1 = Tracker(
            id: UUID(),
            title: "Утренняя зарядка",
            color: .systemBlue,
            emoji: "🏃",
            schedule: [.monday, .wednesday, .friday] // Пн, Ср, Пт
        )
        
        // Создаём трекер "Чтение книг"
        let tracker2 = Tracker(
            id: UUID(),
            title: "Чтение книг",
            color: .systemGreen,
            emoji: "📚",
            schedule: [.tuesday, .thursday] // Вт, Чт
        )
        
        // Объединяем в категорию
        let category = TrackerCategory(
            title: "Спорт и здоровье",
            trackers: [tracker1, tracker2]
        )
        
        categories = [category]
    }
    
    // MARK: - Фильтрация трекеров по дате
    private func updateVisibleCategories() {
        // Определяем день недели для текущей даты
        let weekday = Calendar.current.component(.weekday, from: currentDate)
        let weekdaysMap: [Int: Weekday] = [
            1: .sunday, 2: .monday, 3: .tuesday, 4: .wednesday,
            5: .thursday, 6: .friday, 7: .saturday
        ]
        
        guard let currentWeekday = weekdaysMap[weekday] else { return }
        
        // Фильтруем трекеры: показываем только те, у которых расписание подходит
        visibleCategories = categories.compactMap { category in
            let filteredTrackers = category.trackers.filter { tracker in
                guard let schedule = tracker.schedule else { return true } // nil = каждый день
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
        placeholderImageView.isHidden = !isEmpty  // Показываем звёздочку, если пусто
        placeholderLabel.isHidden = !isEmpty      // Показываем текст, если пусто
        collectionView.isHidden = isEmpty         // Скрываем коллекцию, если пусто
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

// MARK: - UICollectionViewDataSource (источник данных для коллекции)
extension TrackersViewController: UICollectionViewDataSource {
    
    // Количество секций (категорий)
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return visibleCategories.count
    }
    
    // Количество ячеек в секции
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return visibleCategories[section].trackers.count
    }
    
    // Настройка ячейки
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

// MARK: - UICollectionViewDelegateFlowLayout (размеры ячеек)
extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    
    // Размер ячейки (2 колонки)
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - 8) / 2 // 8 — отступ между ячейками
        return CGSize(width: width, height: 148)
    }
}

// MARK: - TrackerCellDelegate (нажатие на кнопку "+" в ячейке)
extension TrackersViewController: TrackerCellDelegate {
    
    func trackerCellDidTapComplete(_ cell: TrackerCell, trackerId: UUID) {
        // Нельзя отмечать будущие даты
        if currentDate > Date() {
            print("Нельзя отметить будущую дату")
            return
        }
        
        // Если трекер уже выполнен — убираем отметку, иначе — добавляем
        if let index = completedTrackers.firstIndex(where: {
            $0.trackerId == trackerId && Calendar.current.isDate($0.date, inSameDayAs: currentDate)
        }) {
            completedTrackers.remove(at: index)
        } else {
            completedTrackers.append(TrackerRecord(trackerId: trackerId, date: currentDate))
        }
        
        collectionView.reloadData()
    }
}

// MARK: - CreateTrackerViewControllerDelegate (создание нового трекера)
extension TrackersViewController: CreateTrackerViewControllerDelegate {
    
    func didCreateTracker(_ tracker: Tracker, categoryTitle: String) {
        // Ищем категорию по названию
        if let index = categories.firstIndex(where: { $0.title == categoryTitle }) {
            var trackers = categories[index].trackers
            trackers.append(tracker)
            categories[index] = TrackerCategory(title: categoryTitle, trackers: trackers)
        } else {
            // Если категории нет — создаём новую
            categories.append(TrackerCategory(title: categoryTitle, trackers: [tracker]))
        }
        updateVisibleCategories()
    }
}
