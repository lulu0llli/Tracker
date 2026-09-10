import UIKit

final class TrackersViewController: UIViewController {
    
    // MARK: - Properties
    private var categories: [TrackerCategory] = []
    private var completedTrackers: [TrackerRecord] = []
    private var visibleCategories: [TrackerCategory] = []
    private var currentDate: Date = Date()
    
    // MARK: - UI Elements
    // Кнопка "+"
    private lazy var addButton: UIBarButtonItem = {
        let button = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(didTapAddButton)
        )
        button.tintColor = UIColor(red: 26/255, green: 27/255, blue: 34/255, alpha: 1)
        return button
    }()
    
    // Дата
    private lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .compact
        picker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        return picker
    }()
    
    // Заголовок "Трекеры"
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Трекеры"
        label.font = UIFont(name: "SFProText-Bold", size: 34) ?? .systemFont(ofSize: 34, weight: .bold)
        label.textColor = UIColor(red: 26/255, green: 27/255, blue: 34/255, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Поле поиска
    private lazy var searchTextField: UISearchTextField = {
        let searchField = UISearchTextField()
        searchField.placeholder = "Поиск"
        searchField.backgroundColor = UIColor(red: 118/255, green: 118/255, blue: 128/255, alpha: 0.12)
        searchField.layer.cornerRadius = 10
        searchField.font = UIFont(name: "SFProText-Regular", size: 17) ?? .systemFont(ofSize: 17)
        
        let magnifyingGlass = UIImage(systemName: "magnifyingglass")
        let leftView = UIImageView(image: magnifyingGlass)
        leftView.tintColor = UIColor(red: 174/255, green: 175/255, blue: 180/255, alpha: 1)
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
    
    // Заглушка (звёздочка)
    private lazy var placeholderImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Plug")
        imageView.tintColor = UIColor(red: 26/255, green: 27/255, blue: 34/255, alpha: 1)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    // Текст заглушки
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Что будем отслеживать?"
        label.font = UIFont(name: "SFProText-Medium", size: 12) ?? .systemFont(ofSize: 12, weight: .medium)
        label.textColor = UIColor(red: 26/255, green: 27/255, blue: 34/255, alpha: 1)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupNavBar()
        setupViews()
        setupConstraints()
        addTestData()
        updateVisibleCategories()
    }
    
    // MARK: - Navigation Bar
    private func setupNavBar() {
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.title = ""
        
        navigationItem.leftBarButtonItem = addButton
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
    }
    
    // MARK: - Setup Views
    private func setupViews() {
        view.addSubview(titleLabel)
        view.addSubview(searchTextField)
        view.addSubview(collectionView)
        view.addSubview(placeholderImageView)
        view.addSubview(placeholderLabel)
    }
    
    // MARK: - Constraints
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Заголовок "Трекеры"
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 88),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.widthAnchor.constraint(equalToConstant: 254),
            titleLabel.heightAnchor.constraint(equalToConstant: 41),
            
            // Search Field
            searchTextField.topAnchor.constraint(equalTo: view.topAnchor, constant: 136),
            searchTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            searchTextField.heightAnchor.constraint(equalToConstant: 36),
            
            collectionView.topAnchor.constraint(equalTo: searchTextField.bottomAnchor, constant: 16),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            // Placeholder Image (звёздочка)
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
    
    // MARK: - Test Data
    private func addTestData() {
        let tracker1 = Tracker(
            id: UUID(),
            title: "Утренняя зарядка",
            color: .systemBlue,
            emoji: "🏃",
            schedule: [.monday, .wednesday, .friday]
        )
        
        let tracker2 = Tracker(
            id: UUID(),
            title: "Чтение книг",
            color: .systemGreen,
            emoji: "📚",
            schedule: [.tuesday, .thursday]
        )
        
        let category = TrackerCategory(
            title: "Спорт и здоровье",
            trackers: [tracker1, tracker2]
        )
        
        categories = [category]
    }
    
    // MARK: - Filtering
    private func updateVisibleCategories() {
        let weekday = Calendar.current.component(.weekday, from: currentDate)
        // weekday: 1 - воскресенье, 2 - понедельник, ...
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
    
    private func updatePlaceholderVisibility() {
        let isEmpty = visibleCategories.isEmpty
        placeholderImageView.isHidden = !isEmpty
        placeholderLabel.isHidden = !isEmpty
        collectionView.isHidden = isEmpty
    }
    
    // MARK: - Actions
    @objc private func didTapAddButton() {
        print("Добавить трекер")
    }
    
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
        // Нельзя отмечать будущие даты
        if currentDate > Date() {
            print("Нельзя отметить будущую дату")
            return
        }
        
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
