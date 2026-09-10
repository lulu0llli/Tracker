import UIKit

final class TrackersViewController: UIViewController {
    
    // MARK: - UI Elements
    // Кнопка "+"
    private lazy var addButton: UIBarButtonItem = {
        let button = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(didTapAddButton)
        )
        button.tintColor = UIColor(red: 26/255, green: 27/255, blue: 34/255, alpha: 1) // #1A1B22
        return button
    }()
    
    // Кнопка с датой
    private lazy var dateButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(getCurrentDateString(), for: .normal)
        button.titleLabel?.font = UIFont(name: "SFProText-Regular", size: 17) ?? .systemFont(ofSize: 17)
        button.setTitleColor(UIColor(red: 26/255, green: 27/255, blue: 34/255, alpha: 1), for: .normal)
        button.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1) // #F0F0F0
        button.layer.cornerRadius = 8
        button.contentEdgeInsets = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12)
        button.addTarget(self, action: #selector(didTapDateButton), for: .touchUpInside)
        return button
    }()
    
    // Заголовок "Трекеры"
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Трекеры"
        label.font = UIFont(name: "SFProText-Bold", size: 34) ?? .systemFont(ofSize: 34, weight: .bold)
        label.textColor = UIColor(red: 26/255, green: 27/255, blue: 34/255, alpha: 1) // #1A1B22
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Поле поиска
    private lazy var searchTextField: UISearchTextField = {
        let searchField = UISearchTextField()
        searchField.placeholder = "Поиск"
        searchField.backgroundColor = UIColor(red: 118/255, green: 118/255, blue: 128/255, alpha: 0.12) // #7676801F
        searchField.layer.cornerRadius = 10
        searchField.font = UIFont(name: "SFProText-Regular", size: 17) ?? .systemFont(ofSize: 17)
        
        let magnifyingGlass = UIImage(systemName: "magnifyingglass")
        let leftView = UIImageView(image: magnifyingGlass)
        leftView.tintColor = UIColor(red: 174/255, green: 175/255, blue: 180/255, alpha: 1) // #AEAFB4
        searchField.leftView = leftView
        searchField.leftViewMode = .always
        
        searchField.translatesAutoresizingMaskIntoConstraints = false
        return searchField
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
    }
    
    // MARK: - Navigation Bar
    private func setupNavBar() {
        // Отключаем стандартный заголовок навбара
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.title = "" // убираем текст
        
        navigationItem.leftBarButtonItem = addButton
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: dateButton)
    }
    
    // MARK: - Setup Views
    private func setupViews() {
        view.addSubview(titleLabel)
        view.addSubview(searchTextField)
        view.addSubview(placeholderImageView)
        view.addSubview(placeholderLabel)
    }
    
    // MARK: - Constraints
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Заголовок "Трекеры" (по макету: top 88, left 16, width 254, height 41)
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 88),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.widthAnchor.constraint(equalToConstant: 254),
            titleLabel.heightAnchor.constraint(equalToConstant: 41),
            
            // Search Field (по макету: top 136, left 16, width 343, height 36)
            searchTextField.topAnchor.constraint(equalTo: view.topAnchor, constant: 136),
            searchTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            searchTextField.heightAnchor.constraint(equalToConstant: 36),
            
            // Placeholder Image (звёздочка) — по макету: top 402, left 147, right 148, bottom 330
            placeholderImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 402),
            placeholderImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 147),
            placeholderImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -148),
            placeholderImageView.widthAnchor.constraint(equalToConstant: 80),
            placeholderImageView.heightAnchor.constraint(equalToConstant: 80),
            
            // Placeholder Label (текст под звёздочкой) — отступ сверху 8
            placeholderLabel.centerXAnchor.constraint(equalTo: placeholderImageView.centerXAnchor),
            placeholderLabel.topAnchor.constraint(equalTo: placeholderImageView.bottomAnchor, constant: 8),
            placeholderLabel.widthAnchor.constraint(equalToConstant: 343),
            placeholderLabel.heightAnchor.constraint(equalToConstant: 18)
        ])
    }
    
    // MARK: - Helpers
    private func getCurrentDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yy"
        return formatter.string(from: Date())
    }
    
    // MARK: - Actions
    @objc private func didTapAddButton() {
        print("Добавить трекер")
    }
    
    @objc private func didTapDateButton() {
        print("Дата нажата")
    }
}
