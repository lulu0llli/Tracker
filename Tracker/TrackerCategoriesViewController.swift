import UIKit

final class TrackerCategoriesViewController: UIViewController {
    
    // MARK: - ViewModel
    private let viewModel = TrackerCategoryViewModel()
    
    var onCategorySelected: ((String) -> Void)?
    
    // Констрейнт высоты таблицы
    private var tableViewHeightConstraint: NSLayoutConstraint?
    
    // MARK: - UI
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.register(TrackerCategoryCell.self, forCellReuseIdentifier: TrackerCategoryCell.identifier)
        table.dataSource = self
        table.delegate = self
        table.layer.cornerRadius = 16
        table.layer.masksToBounds = true
        table.separatorStyle = .none
        table.backgroundColor = .clear
        table.isScrollEnabled = true
        table.showsVerticalScrollIndicator = false
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
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
        label.text = "Привычки и события можно\nобъединить по смыслу"
        label.font = UIFont(name: "SFProText-Medium", size: 12) ?? .systemFont(ofSize: 12, weight: .medium)
        label.textColor = UIColor(named: "YPBlack") ?? .black
        label.textAlignment = .center
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Добавить категорию", for: .normal)
        button.titleLabel?.font = UIFont(name: "SFProText-Medium", size: 16) ?? .systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(named: "YPBlack") ?? .black
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(didTapAdd), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupNavigationBar()
        setupViews()
        setupConstraints()
        bindViewModel()
        viewModel.fetchCategories()
    }
    
    private func setupNavigationBar() {
        title = "Категория"
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        appearance.shadowColor = .clear
        appearance.titleTextAttributes = [
            .font: UIFont(name: "SFProText-Medium", size: 16) ?? .systemFont(ofSize: 16, weight: .medium),
            .foregroundColor: UIColor(named: "YPBlack") ?? .black
        ]
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
    }
    
    private func setupViews() {
      
        view.addSubview(tableView)
        view.addSubview(placeholderImageView)
        view.addSubview(placeholderLabel)
        view.addSubview(addButton)
    }
    
    private func setupConstraints() {
  
        let heightConstraint = tableView.heightAnchor.constraint(equalToConstant: 0)
        tableViewHeightConstraint = heightConstraint
        
        NSLayoutConstraint.activate([
            // Таблица
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            heightConstraint,
            
            // Заглушка
            placeholderImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 346),
            placeholderImageView.widthAnchor.constraint(equalToConstant: 80),
            placeholderImageView.heightAnchor.constraint(equalToConstant: 80),
            
            placeholderLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 434),
            placeholderLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            placeholderLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            // Кнопка
            addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func bindViewModel() {
        viewModel.onCategoriesChange = { [weak self] in
            self?.updateUI()
        }
        
        viewModel.onError = { [weak self] message in
            let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ок", style: .default))
            self?.present(alert, animated: true)
        }
    }
    
    private func updateUI() {
        let count = viewModel.numberOfCategories
        let isEmpty = count == 0
       
        placeholderImageView.isHidden = !isEmpty
        placeholderLabel.isHidden = !isEmpty
        
        tableView.isHidden = isEmpty

        tableViewHeightConstraint?.constant = CGFloat(count * 75)
        
        tableView.reloadData()
        
        view.bringSubviewToFront(placeholderImageView)
        view.bringSubviewToFront(placeholderLabel)
        view.bringSubviewToFront(addButton)
    }
    
    @objc private func didTapAdd() {
        let createVC = CreateCategoryViewController()
        createVC.delegate = self
        let navController = UINavigationController(rootViewController: createVC)
        present(navController, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension TrackerCategoriesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfCategories
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: TrackerCategoryCell.identifier,
            for: indexPath
        ) as? TrackerCategoryCell else {
            return UITableViewCell()
        }
        
        let category = viewModel.category(at: indexPath.row)
        let isSelected = viewModel.isSelected(at: indexPath.row)
        cell.configure(with: category?.title ?? "", isSelected: isSelected)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension TrackerCategoriesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let category = viewModel.category(at: indexPath.row)
        onCategorySelected?(category?.title ?? "")
        dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
}

// MARK: - CreateCategoryViewControllerDelegate
extension TrackerCategoriesViewController: CreateCategoryViewControllerDelegate {
    func didCreateCategory(title: String) {
        viewModel.addCategory(title: title)
    }
}
