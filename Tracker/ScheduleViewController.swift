import UIKit

protocol ScheduleViewControllerDelegate: AnyObject {
    func scheduleViewController(_ vc: ScheduleViewController, didSelect weekdays: [Weekday])
}

final class ScheduleViewController: UIViewController {
    
    // MARK: - Данные
    weak var delegate: ScheduleViewControllerDelegate?
    var selectedWeekdays: Set<Weekday> = []  // Выбранные дни недели
    
    // MARK: - UI Элементы
    
    // Таблица с днями недели
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        table.layer.cornerRadius = 16
        table.layer.masksToBounds = true
        table.isScrollEnabled = false  // Отключаем скролл (все дни видны)
        table.backgroundColor = UIColor(named: "YPBackgroundGrey")
        table.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    // Кнопка "Готово" внизу
    private lazy var doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Готово", for: .normal)
        button.backgroundColor = UIColor(named: "YPBlack") ?? .black
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont(name: "SFProText-Medium", size: 16) ?? .systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(didTapDone), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Жизненный цикл
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        title = "Расписание"
        navigationController?.navigationBar.titleTextAttributes = [
            .font: UIFont(name: "SFProText-Medium", size: 16) ?? .systemFont(ofSize: 16, weight: .medium),
            .foregroundColor: UIColor(named: "YPBlack") ?? .black
        ]
        
        tableView.dataSource = self
        tableView.delegate = self
        
        view.addSubview(tableView)
        view.addSubview(doneButton)
        
        NSLayoutConstraint.activate([
            // Таблица (top 16, left 16, right 16, высота = 7 дней × 75)
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: CGFloat(Weekday.allCases.count * 75)),
            
            // Кнопка "Готово" (внизу)
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            doneButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    // MARK: - Действия
    
    // Нажатие на "Готово"
    @objc private func didTapDone() {
        let weekdays = Weekday.allCases.filter { selectedWeekdays.contains($0) }
        delegate?.scheduleViewController(self, didSelect: weekdays)
        dismiss(animated: true)
    }
    
    // Переключение свитча (день недели)
    @objc private func switchChanged(_ sender: UISwitch) {
        let weekday = Weekday.allCases[sender.tag]
        if sender.isOn {
            selectedWeekdays.insert(weekday)
        } else {
            selectedWeekdays.remove(weekday)
        }
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension ScheduleViewController: UITableViewDataSource, UITableViewDelegate {
    
    // Количество строк (7 дней)
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Weekday.allCases.count
    }
    
    // Настройка ячейки
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let weekday = Weekday.allCases[indexPath.row]
        
        // Название дня недели
        cell.textLabel?.text = weekday.rawValue
        cell.textLabel?.font = UIFont(name: "SFProText-Regular", size: 17) ?? .systemFont(ofSize: 17)
        cell.textLabel?.textColor = UIColor(named: "YPBlack") ?? .black
        cell.backgroundColor = UIColor(named: "YPBackgroundGrey")
        cell.selectionStyle = .none
        
        // Свитч (переключатель)
        let switchView = UISwitch()
        switchView.isOn = selectedWeekdays.contains(weekday)
        switchView.onTintColor = UIColor(named: "YPBlue") ?? .systemBlue // #3772E7
        switchView.tag = indexPath.row
        switchView.addTarget(self, action: #selector(switchChanged(_:)), for: .valueChanged)
        cell.accessoryView = switchView
        
        // Убираем разделитель у последней ячейки
        if indexPath.row == Weekday.allCases.count - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        }
        
        return cell
    }
    
    // Высота строки
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}
