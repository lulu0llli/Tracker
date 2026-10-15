import UIKit

final class TrackersViewController: UIViewController {
    
    // MARK: - Данные
    private var categories: [TrackerCategory] = []
    private var completedTrackers: [TrackerRecord] = []
    private var visibleCategories: [TrackerCategory] = []
    private var currentDate: Date = Date()
    private var searchText: String = ""
    
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
        return collectionView
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
    
    // MARK: - Фильтрация трекеров по дате и тексту
    private func updateVisibleCategories() {
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
        
        if searchText.isEmpty {
            visibleCategories = categoriesByDay
        } else {
            let lowercasedText = searchText.lowercased()
            visibleCategories = categoriesByDay.compactMap { category -> TrackerCategory? in
                let filteredTrackers = category.trackers.filter { tracker in
                    tracker.title.lowercased().contains(lowercasedText)
                }
                return filteredTrackers.isEmpty ? nil : TrackerCategory(title: category.title, trackers: filteredTrackers)
            }
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
        
        let isCompleted = completedTrackers.contains {
            $0.trackerId == tracker.id && Calendar.current.isDate($0.date, inSameDayAs: currentDate)
        }
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
