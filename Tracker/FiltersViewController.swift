import UIKit

final class FiltersViewController: UIViewController {
    
    // MARK: - Свойства
    var selectedFilter: TrackerFilter
    var onFilterSelected: ((TrackerFilter) -> Void)?
    
    private let filters: [TrackerFilter] = [.all, .today, .completed, .uncompleted]
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("filters_title", comment: "Заголовок экрана фильтров")
        label.font = UIFont(name: "SFProText-Medium", size: 16) ?? .systemFont(ofSize: 16, weight: .medium)
        label.textColor = UIColor(named: "YPBlack") ?? .black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "FilterCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.layer.cornerRadius = 16
        tableView.clipsToBounds = true
        tableView.isScrollEnabled = false
        tableView.backgroundColor = UIColor(named: "YPBackgroundGrey")
        tableView.separatorColor = UIColor(named: "YPGrey")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    // MARK: - Init
    init(selectedFilter: TrackerFilter) {
        self.selectedFilter = selectedFilter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Жизненный цикл
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "YPWhite")
        
        setupViews()
        setupConstraints()
    }
    
    // MARK: - UI
    private func setupViews() {
        view.addSubview(titleLabel)
        view.addSubview(tableView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            titleLabel.heightAnchor.constraint(equalToConstant: 22),
            
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: CGFloat(filters.count * 75))
        ])
    }
}

// MARK: - UITableViewDataSource
extension FiltersViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FilterCell", for: indexPath)
        let filter = filters[indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        content.text = filter.localizedTitle
        content.textProperties.font = UIFont(name: "SFProText-Regular", size: 17) ?? .systemFont(ofSize: 17)
        content.textProperties.color = UIColor(named: "YPBlack") ?? .black
        cell.contentConfiguration = content
        
        cell.backgroundColor = UIColor(named: "YPBackgroundGrey")
        cell.selectionStyle = .none
        
        // Галочка для активного фильтра
        if filter == selectedFilter && filter.shouldShowCheckmark {
            cell.accessoryType = .checkmark
            cell.tintColor = UIColor(named: "YPBlue") ?? .systemBlue
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension FiltersViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let filter = filters[indexPath.row]
        onFilterSelected?(filter)
        dismiss(animated: true)
    }
}
