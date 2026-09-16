import UIKit

protocol CreateTrackerViewControllerDelegate: AnyObject {
    func didCreateTracker(_ tracker: Tracker, categoryTitle: String)
}

final class CreateTrackerViewController: UIViewController {
    
    // MARK: - Данные
    weak var delegate: CreateTrackerViewControllerDelegate?
    private var selectedWeekdays: [Weekday] = []
    private let maxTitleLength = 38
    
    // MARK: - UI Элементы
    
    // Поле ввода названия трекера
    private lazy var titleTextField: UITextField = {
        let field = UITextField()
        field.backgroundColor = UIColor(named: "YPBackgroundGrey")
        field.layer.cornerRadius = 16
        field.font = UIFont(name: "SFProText-Regular", size: 17) ?? .systemFont(ofSize: 17)
        field.textColor = UIColor(named: "YPBlack") ?? .black
        
        // Placeholder серого цвета
        field.attributedPlaceholder = NSAttributedString(
            string: "Введите название трекера",
            attributes: [.foregroundColor: UIColor(named: "YPGrey") ?? .systemGray]
        )
        
        // Отступы: слева 16, справа 41
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
    
    // Текст "Ограничение 38 символов"
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
    
    // Контейнер для "Категория" и "Расписание"
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
    
    // Кнопка "Категория"
    private lazy var categoryButton: UIButton = makeOptionButton(title: "Категория")
    // Кнопка "Расписание"
    private lazy var scheduleButton: UIButton = makeOptionButton(title: "Расписание")
    
    // Кнопка "Отменить"
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
    
    // Кнопка "Создать"
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
    
    // MARK: - Настройка навигационной панели
    private func setupNavigationBar() {
        title = "Новая привычка"
        navigationController?.navigationBar.titleTextAttributes = [
            .font: UIFont(name: "SFProText-Medium", size: 16) ?? .systemFont(ofSize: 16, weight: .medium),
            .foregroundColor: UIColor(named: "YPBlack") ?? .black
        ]
    }
    
    // MARK: - Добавление элементов
    private func setupViews() {
        optionsStackView.addArrangedSubview(categoryButton)
        optionsStackView.addArrangedSubview(scheduleButton)
        
        // 🔥 Обработчики нажатия
        scheduleButton.addTarget(self, action: #selector(didTapSchedule), for: .touchUpInside)
        categoryButton.addTarget(self, action: #selector(didTapCategory), for: .touchUpInside)
        
        view.addSubview(titleTextField)
        view.addSubview(limitLabel)
        view.addSubview(optionsStackView)
        view.addSubview(cancelButton)
        view.addSubview(createButton)
    }
    
    // MARK: - Создание кнопки опции (с шевроном)
    private func makeOptionButton(title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(UIColor(named: "YPBlack") ?? .black, for: .normal)
        button.titleLabel?.font = UIFont(name: "SFProText-Regular", size: 17) ?? .systemFont(ofSize: 17)
        button.contentHorizontalAlignment = .leading
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 40)
        button.heightAnchor.constraint(equalToConstant: 75).isActive = true
        
        // Шеврон
        let chevron = UIImageView(image: UIImage(named: "Chevron"))
        chevron.tintColor = UIColor(named: "YPGrey") ?? .systemGray
        chevron.contentMode = .scaleAspectFit
        chevron.translatesAutoresizingMaskIntoConstraints = false
        button.addSubview(chevron)
               NSLayoutConstraint.activate([
        chevron.centerYAnchor.constraint(equalTo: button.centerYAnchor),
        chevron.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -16),
        chevron.widthAnchor.constraint(equalToConstant: 7),
        chevron.heightAnchor.constraint(equalToConstant: 12)
               ])
        
        return button
    }
    
    // MARK: - Констрейнты
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            titleTextField.heightAnchor.constraint(equalToConstant: 75),
            
            limitLabel.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 8),
            limitLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            limitLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            optionsStackView.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 24),
            optionsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            optionsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            optionsStackView.heightAnchor.constraint(equalToConstant: 150),
            
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
    
    // MARK: - Закрытие клавиатуры
    private func setupKeyboardDismissGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Действия
    
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
    
    // Активация кнопки "Создать"
    private func updateCreateButtonState() {
        let hasTitle = !(titleTextField.text?.isEmpty ?? true)
        let hasSchedule = !selectedWeekdays.isEmpty
        let isValid = hasTitle && hasSchedule
        
        createButton.isEnabled = isValid
        createButton.backgroundColor = isValid
            ? (UIColor(named: "YPBlack") ?? .black)
            : (UIColor(named: "YPGrey") ?? .systemGray)
    }
    
    // Нажатие на "Расписание"
    @objc private func didTapSchedule() {
        let scheduleVC = ScheduleViewController()
        scheduleVC.selectedWeekdays = Set(selectedWeekdays)
        scheduleVC.delegate = self
        let navController = UINavigationController(rootViewController: scheduleVC)
        present(navController, animated: true)
    }
    
    @objc private func didTapCategory() {
        print("Категория — будет реализовано позже")
    }
    
    @objc private func didTapCancel() {
        dismiss(animated: true)
    }
    
    @objc private func didTapCreate() {
        guard let title = titleTextField.text, !title.isEmpty else { return }
        
        let tracker = Tracker(
            id: UUID(),
            title: title,
            color: .systemBlue,
            emoji: "😊",
            schedule: selectedWeekdays
        )
        
        delegate?.didCreateTracker(tracker, categoryTitle: "Важное")
        dismiss(animated: true)
    }
    
    // Обновление подписи кнопки "Расписание"
    private func updateScheduleButton(days: [Weekday]) {
        let titleFont = UIFont(name: "SFProText-Regular", size: 17) ?? .systemFont(ofSize: 17)
        
        // "Расписание" — чёрный
        let result = NSMutableAttributedString(
            string: "Расписание",
            attributes: [
                .font: titleFont,
                .foregroundColor: UIColor(named: "YPBlack") ?? .black
            ]
        )
        
        // Подпись с днями — серый
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
}

// MARK: - ScheduleViewControllerDelegate
extension CreateTrackerViewController: ScheduleViewControllerDelegate {
    
    func scheduleViewController(_ vc: ScheduleViewController, didSelect weekdays: [Weekday]) {
        selectedWeekdays = weekdays
        updateScheduleButton(days: weekdays)
        updateCreateButtonState()
    }
}
