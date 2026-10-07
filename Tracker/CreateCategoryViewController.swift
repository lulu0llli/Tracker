import UIKit

protocol CreateCategoryViewControllerDelegate: AnyObject {
    func didCreateCategory(title: String)
}

final class CreateCategoryViewController: UIViewController {
    
    weak var delegate: CreateCategoryViewControllerDelegate?
    
    // MARK: - UI
    private lazy var textField: UITextField = {
        let field = UITextField()
        field.backgroundColor = UIColor(named: "YPBackgroundGrey")
        field.layer.cornerRadius = 16
        field.font = UIFont(name: "SFProText-Regular", size: 17) ?? .systemFont(ofSize: 17)
        field.textColor = UIColor(named: "YPBlack") ?? .black
        field.attributedPlaceholder = NSAttributedString(
            string: "Введите название категории",
            attributes: [.foregroundColor: UIColor(named: "YPGrey") ?? .systemGray]
        )
        
        let leftPadding = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        field.leftView = leftPadding
        field.leftViewMode = .always
        
        let rightPadding = UIView(frame: CGRect(x: 0, y: 0, width: 41, height: 0))
        field.rightView = rightPadding
        field.rightViewMode = .always
        
        field.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private lazy var doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Готово", for: .normal)
        button.titleLabel?.font = UIFont(name: "SFProText-Medium", size: 16) ?? .systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(named: "YPGrey") ?? .systemGray
        button.layer.cornerRadius = 16
        button.isEnabled = false
        button.addTarget(self, action: #selector(didTapDone), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        title = "Новая категория"
        navigationController?.navigationBar.titleTextAttributes = [
            .font: UIFont(name: "SFProText-Medium", size: 16) ?? .systemFont(ofSize: 16, weight: .medium),
            .foregroundColor: UIColor(named: "YPBlack") ?? .black
        ]
        
        setupViews()
        setupConstraints()
        setupKeyboardDismissGesture()
    }
    
    private func setupViews() {
        view.addSubview(textField)
        view.addSubview(doneButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textField.heightAnchor.constraint(equalToConstant: 75),
            
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            doneButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func setupKeyboardDismissGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Actions
    @objc private func textFieldDidChange() {
        let hasText = !(textField.text?.isEmpty ?? true)
        doneButton.isEnabled = hasText
        doneButton.backgroundColor = hasText
            ? (UIColor(named: "YPBlack") ?? .black)
            : (UIColor(named: "YPGrey") ?? .systemGray)
    }
    
    @objc private func didTapDone() {
        guard let title = textField.text, !title.isEmpty else { return }
        delegate?.didCreateCategory(title: title)
        dismiss(animated: true)
    }
}
