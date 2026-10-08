import UIKit

protocol CreateTrackerViewControllerDelegate: AnyObject {
    func didCreateTracker(_ tracker: Tracker, categoryTitle: String)
}

final class CreateTrackerViewController: UIViewController {
    
    // MARK: - Данные
    weak var delegate: CreateTrackerViewControllerDelegate?
    private var selectedWeekdays: [Weekday] = []
    private var selectedEmoji: String?
    private var selectedColor: UIColor?
    private var selectedCategoryTitle: String?
    private let maxTitleLength = 38
    
    // Эмодзи и цвета из макета
    private let emojis = [
        "😊", "😺", "🌺", "🐶", "❤️", "😂",
        "😇", "😡", "💧", "🤔", "🙌", "🍔",
        "🥦", "🏓", "🏆", "🎸", "🏝️", "😭",
        "😴", "🥳", "🤯", "👻", "🎃", "🤖"
    ]
    
    // MARK: - Цвета для коллекции
    private let colorRed = UIColor(hex: "#FD4C49")
    private let colorOrange = UIColor(hex: "#FF881E")
    private let colorBlue = UIColor(hex: "#007BFF")
    private let colorDeepPurple = UIColor(hex: "#6E32C9")
    private let colorGreen = UIColor(hex: "#00C853")
    private let colorPink = UIColor(hex: "#FF6B8B")
    private let colorLightPink = UIColor(hex: "#FFD6E0")
    private let colorLightBlue = UIColor(hex: "#8ED1FC")
    private let colorMint = UIColor(hex: "#7FE0B0")
    private let colorNavy = UIColor(hex: "#1E2A78")
    private let colorCoral = UIColor(hex: "#FF8A65")
    private let colorLavender = UIColor(hex: "#FBC2EB")
    private let colorCream = UIColor(hex: "#F5E1C0")
    private let colorPeriwinkle = UIColor(hex: "#8FA8FF")
    private let colorViolet = UIColor(hex: "#A855F7")
    private let colorLilac = UIColor(hex: "#C084FC")
    private let colorPurple = UIColor(hex: "#9B51E0")
    private let colorBrightGreen = UIColor(hex: "#34C759")
    private let colorYellow = UIColor(hex: "#FF9F0A")
    private let colorSkyBlue = UIColor(hex: "#5AC8FA")
    private let colorMagenta = UIColor(hex: "#AF52DE")
    private let colorRose = UIColor(hex: "#FF2D55")
    private let colorIndigo = UIColor(hex: "#5856D6")
    private let colorGoldenYellow = UIColor(hex: "#FFCC00")

    private lazy var colors: [UIColor] = [
        colorRed, colorOrange, colorBlue, colorDeepPurple, colorGreen, colorPink,
        colorLightPink, colorLightBlue, colorMint, colorNavy, colorCoral, colorLavender,
        colorCream, colorPeriwinkle, colorViolet, colorLilac, colorPurple, colorBrightGreen,
        colorYellow, colorSkyBlue, colorMagenta, colorRose, colorIndigo, colorGoldenYellow
    ]
    
    // MARK: - UI Элементы
    
    private let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        return scroll
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var titleTextField: UITextField = {
        let field = UITextField()
        field.backgroundColor = UIColor(named: "YPBackgroundGrey")
        field.layer.cornerRadius = 16
        field.font = UIFont(name: "SFProText-Regular", size: 17) ?? .systemFont(ofSize: 17)
        field.textColor = UIColor(named: "YPBlack") ?? .black
        field.attributedPlaceholder = NSAttributedString(
            string: "Введите название трекера",
            attributes: [.foregroundColor: UIColor(named: "YPGrey") ?? .systemGray]
        )
        let leftPadding = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        field.leftView = leftPadding
        field.leftViewMode = .always
        let rightPadding = UIView(frame: CGRect(x: 0, y: 0, width: 41, height: 0))
        field.rightView = rightPadding
        field.rightViewMode = .always
        field.addTarget(self, action: #selector(titleChanged), for: .editingChanged)
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private lazy var limitLabel: UILabel = {
        let label = UILabel()
        label.text = "Ограничение 38 символов"
        label.font = UIFont(name: "SFProText-Regular", size: 17) ?? .systemFont(ofSize: 17)
        label.textColor = UIColor(named: "YPRed") ?? .systemRed
        label.textAlignment = .center
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var optionsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 0
        stack.backgroundColor = UIColor(named: "YPBackgroundGrey")
        stack.layer.cornerRadius = 16
        stack.layer.masksToBounds = true
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var categoryButton: UIButton = makeOptionButton(title: "Категория")
    private lazy var scheduleButton: UIButton = makeOptionButton(title: "Расписание")
    
    // Заголовок "Emoji"
    private let emojiTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Emoji"
        label.font = UIFont.systemFont(ofSize: 19, weight: .bold)
        label.textColor = UIColor(named: "YPBlack") ?? .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Коллекция эмодзи
    private lazy var emojiCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 6
        layout.minimumLineSpacing = 6
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.backgroundColor = .clear
        collection.register(EmojiCollectionViewCell.self, forCellWithReuseIdentifier: EmojiCollectionViewCell.identifier)
        collection.dataSource = self
        collection.delegate = self
        collection.translatesAutoresizingMaskIntoConstraints = false
        return collection
    }()
    
    // Заголовок "Цвет"
    private let colorTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Цвет"
        label.font = UIFont.systemFont(ofSize: 19, weight: .bold)
        label.textColor = UIColor(named: "YPBlack") ?? .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Коллекция цветов
    private lazy var colorCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 6
        layout.minimumLineSpacing = 6
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.backgroundColor = .clear
        collection.register(ColorCollectionViewCell.self, forCellWithReuseIdentifier: ColorCollectionViewCell.identifier)
        collection.dataSource = self
        collection.delegate = self
        collection.translatesAutoresizingMaskIntoConstraints = false
        return collection
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Отменить", for: .normal)
        button.setTitleColor(UIColor(named: "YPRed") ?? .systemRed, for: .normal)
        button.titleLabel?.font = UIFont(name: "SFProText-Medium", size: 16) ?? .systemFont(ofSize: 16, weight: .medium)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor(named: "YPRed")?.cgColor ?? UIColor.systemRed.cgColor
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(didTapCancel), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var createButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Создать", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont(name: "SFProText-Medium", size: 16) ?? .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = UIColor(named: "YPGrey") ?? .systemGray
        button.layer.cornerRadius = 16
        button.isEnabled = false
        button.addTarget(self, action: #selector(didTapCreate), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Жизненный цикл
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupNavigationBar()
        setupViews()
        setupConstraints()
        setupKeyboardDismissGesture()
    }
    
    private func setupNavigationBar() {
        title = "Новая привычка"
        let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .white
            appearance.titleTextAttributes = [
                .font: UIFont(name: "SFProText-Medium", size: 16) ?? .systemFont(ofSize: 16, weight: .medium),
                .foregroundColor: UIColor(named: "YPBlack") ?? .black
            ]
            
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
            navigationController?.navigationBar.compactAppearance = appearance
    }
    
    private func setupViews() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        optionsStackView.addArrangedSubview(categoryButton)
        optionsStackView.addArrangedSubview(scheduleButton)
        scheduleButton.addTarget(self, action: #selector(didTapSchedule), for: .touchUpInside)
        categoryButton.addTarget(self, action: #selector(didTapCategory), for: .touchUpInside)
        
        contentView.addSubview(titleTextField)
        contentView.addSubview(limitLabel)
        contentView.addSubview(optionsStackView)
        contentView.addSubview(emojiTitleLabel)
        contentView.addSubview(emojiCollectionView)
        contentView.addSubview(colorTitleLabel)
        contentView.addSubview(colorCollectionView)
        
        view.addSubview(cancelButton)
        view.addSubview(createButton)
    }
    
    private func makeOptionButton(title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(UIColor(named: "YPBlack") ?? .black, for: .normal)
        button.titleLabel?.font = UIFont(name: "SFProText-Regular", size: 17) ?? .systemFont(ofSize: 17)
        button.contentHorizontalAlignment = .leading
        
        // Отступы через Configuration
        var config = UIButton.Configuration.plain()
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 40)
        button.configuration = config
        
        button.heightAnchor.constraint(equalToConstant: 75).isActive = true
        
        // Шеврон
        let chevron = UIImageView(image: UIImage(named: "Chevron"))
        chevron.tintColor = UIColor(named: "YPGrey") ?? .systemGray
        chevron.contentMode = .scaleAspectFit
        chevron.translatesAutoresizingMaskIntoConstraints = false
        chevron.isUserInteractionEnabled = false
        button.addSubview(chevron)
        
        NSLayoutConstraint.activate([
            chevron.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            chevron.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -16),
            chevron.widthAnchor.constraint(equalToConstant: 7),
            chevron.heightAnchor.constraint(equalToConstant: 12)
        ])
        
        return button
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: cancelButton.topAnchor, constant: -16),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            titleTextField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            titleTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            titleTextField.heightAnchor.constraint(equalToConstant: 75),
            
            limitLabel.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 8),
            limitLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            limitLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            optionsStackView.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 24),
            optionsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            optionsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            optionsStackView.heightAnchor.constraint(equalToConstant: 150),
            
            emojiTitleLabel.topAnchor.constraint(equalTo: optionsStackView.bottomAnchor, constant: 32),
            emojiTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            emojiCollectionView.topAnchor.constraint(equalTo: emojiTitleLabel.bottomAnchor, constant: 8),
            emojiCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            emojiCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            emojiCollectionView.heightAnchor.constraint(equalToConstant: 226), // 4 ряда * 52 + 3*6
            
            colorTitleLabel.topAnchor.constraint(equalTo: emojiCollectionView.bottomAnchor, constant: 16),
            colorTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            colorCollectionView.topAnchor.constraint(equalTo: colorTitleLabel.bottomAnchor, constant: 8),
            colorCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            colorCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            colorCollectionView.heightAnchor.constraint(equalToConstant: 226),
            colorCollectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cancelButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            cancelButton.widthAnchor.constraint(equalToConstant: 166),
            
            createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            createButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            createButton.heightAnchor.constraint(equalToConstant: 60),
            createButton.widthAnchor.constraint(equalToConstant: 161)
        ])
    }
    
    private func setupKeyboardDismissGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func titleChanged() {
        guard let text = titleTextField.text else { return }
        if text.count > maxTitleLength {
            limitLabel.isHidden = false
            titleTextField.text = String(text.prefix(maxTitleLength))
        } else {
            limitLabel.isHidden = true
        }
        updateCreateButtonState()
    }
    
    private func updateCreateButtonState() {
        let isValid = !(titleTextField.text?.isEmpty ?? true) &&
                      !selectedWeekdays.isEmpty &&
                      selectedEmoji != nil &&
                      selectedColor != nil
        createButton.isEnabled = isValid
        createButton.backgroundColor = isValid
            ? (UIColor(named: "YPBlack") ?? .black)
            : (UIColor(named: "YPGrey") ?? .systemGray)
    }
    
    @objc private func didTapSchedule() {
        let scheduleVC = ScheduleViewController()
        scheduleVC.selectedWeekdays = Set(selectedWeekdays)
        scheduleVC.delegate = self
        let navController = UINavigationController(rootViewController: scheduleVC)
        present(navController, animated: true)
    }
    
    @objc private func didTapCategory() {
        let categoriesVC = TrackerCategoriesViewController()
        categoriesVC.onCategorySelected = { [weak self] title in
            self?.selectedCategoryTitle = title
            self?.updateCategoryButton(title: title)
        }
        
        let navController = UINavigationController(rootViewController: categoriesVC)
        present(navController, animated: true)
    }
    
    @objc private func didTapCancel() {
        dismiss(animated: true)
    }
    
    @objc private func didTapCreate() {
        guard let title = titleTextField.text, !title.isEmpty,
              let emoji = selectedEmoji,
              let color = selectedColor else { return }
        let tracker = Tracker(
            id: UUID(),
            title: title,
            color: color,
            emoji: emoji,
            schedule: selectedWeekdays
        )
        delegate?.didCreateTracker(tracker, categoryTitle: "Важное")
        dismiss(animated: true)
    }
    
    private func updateScheduleButton(days: [Weekday]) {
        let titleFont = UIFont(name: "SFProText-Regular", size: 17) ?? .systemFont(ofSize: 17)
        let result = NSMutableAttributedString(
            string: "Расписание",
            attributes: [
                .font: titleFont,
                .foregroundColor: UIColor(named: "YPBlack") ?? .black
            ]
        )
        if !days.isEmpty {
            let daysText: String
            if days.count == Weekday.allCases.count {
                daysText = "Каждый день"
            } else {
                daysText = days.map { $0.shortName }.joined(separator: ", ")
            }
            result.append(NSAttributedString(
                string: "\n\(daysText)",
                attributes: [
                    .font: titleFont,
                    .foregroundColor: UIColor(named: "YPGrey") ?? .systemGray
                ]
            ))
        }
        scheduleButton.setAttributedTitle(result, for: .normal)
        scheduleButton.titleLabel?.numberOfLines = 2
        scheduleButton.titleLabel?.lineBreakMode = .byWordWrapping
    }
    private func updateCategoryButton(title: String) {
        let titleFont = UIFont(name: "SFProText-Regular", size: 17) ?? .systemFont(ofSize: 17)
        
        // Первая строка — "Категория" чёрным
        let result = NSMutableAttributedString(
            string: "Категория",
            attributes: [
                .font: titleFont,
                .foregroundColor: UIColor(named: "YPBlack") ?? .black
            ]
        )
        
        // Вторая строка — выбранная категория серым
        result.append(NSAttributedString(
            string: "\n\(title)",
            attributes: [
                .font: titleFont,
                .foregroundColor: UIColor(named: "YPGrey") ?? .systemGray
            ]
        ))
        
        categoryButton.setAttributedTitle(result, for: .normal)
        categoryButton.titleLabel?.numberOfLines = 2
        categoryButton.titleLabel?.lineBreakMode = .byWordWrapping
    }
}

// MARK: - UICollectionViewDataSource
extension CreateTrackerViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        collectionView == emojiCollectionView ? emojis.count : colors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == emojiCollectionView {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: EmojiCollectionViewCell.identifier,
                for: indexPath
            ) as? EmojiCollectionViewCell else { return UICollectionViewCell() }
            let emoji = emojis[indexPath.item]
            cell.configure(with: emoji, isSelected: emoji == selectedEmoji)
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ColorCollectionViewCell.identifier,
                for: indexPath
            ) as? ColorCollectionViewCell else { return UICollectionViewCell() }
            let color = colors[indexPath.item]
            cell.configure(with: color, isSelected: color == selectedColor)
            return cell
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension CreateTrackerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: 52, height: 52)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        6
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        6
    }
}

// MARK: - UICollectionViewDelegate
extension CreateTrackerViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == emojiCollectionView {
            selectedEmoji = emojis[indexPath.item]
            emojiCollectionView.reloadData()
        } else {
            selectedColor = colors[indexPath.item]
            colorCollectionView.reloadData()
        }
        updateCreateButtonState()
    }
}

// MARK: - ScheduleViewControllerDelegate
extension CreateTrackerViewController: ScheduleViewControllerDelegate {
    func scheduleViewController(_ vc: ScheduleViewController, didSelect weekdays: [Weekday]) {
        selectedWeekdays = weekdays
        updateScheduleButton(days: weekdays)
        updateCreateButtonState()
    }
}
