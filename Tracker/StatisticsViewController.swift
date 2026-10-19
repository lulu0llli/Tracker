import UIKit

final class StatisticsViewController: UIViewController {
    
    // MARK: - ViewModel
    private let viewModel = StatisticsViewModel()
    
    // MARK: - UI Элементы
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("statistics_title", comment: "Заголовок экрана статистики")
        label.font = UIFont(name: "SFProText-Bold", size: 34) ?? .systemFont(ofSize: 34, weight: .bold)
        label.textColor = UIColor(named: "YPBlack") ?? .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var statsCard: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "YPWhite")
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    /// Градиентная рамка вокруг карточки
    private lazy var gradientBorderLayer: CAGradientLayer = {
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor(red: 0/255, green: 123/255, blue: 250/255, alpha: 1).cgColor, // #007BFA
            UIColor(red: 70/255, green: 230/255, blue: 157/255, alpha: 1).cgColor, // #46E69D
            UIColor(red: 253/255, green: 76/255, blue: 73/255, alpha: 1).cgColor  // #FD4C49
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)  // слева
        gradient.endPoint = CGPoint(x: 1, y: 0.5)    // справа
        return gradient
    }()
    
    private lazy var countLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "SFProText-Bold", size: 34) ?? .systemFont(ofSize: 34, weight: .bold)
        label.textColor = UIColor(named: "YPBlack") ?? .black
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("statistics_completed", comment: "Подпись Трекеров завершено")
        label.font = UIFont(name: "SFProText-Medium", size: 12) ?? .systemFont(ofSize: 12, weight: .medium)
        label.textColor = UIColor(named: "YPBlack") ?? .black
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var placeholderImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "ErrorStatistics")
        imageView.tintColor = UIColor(named: "YPBlack") ?? .black
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("statistics_empty", comment: "Пустая статистика")
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
        
        setupViews()
        setupConstraints()
        setupBindings()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupGradientBorder()
    }
    
    // MARK: - UI
    private func setupViews() {
        view.addSubview(titleLabel)
        view.addSubview(statsCard)
        statsCard.addSubview(countLabel)
        statsCard.addSubview(descriptionLabel)
        
        view.addSubview(placeholderImageView)
        view.addSubview(placeholderLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 88),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.widthAnchor.constraint(equalToConstant: 254),
            titleLabel.heightAnchor.constraint(equalToConstant: 41),
            
            statsCard.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 77),
            statsCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            statsCard.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            statsCard.heightAnchor.constraint(equalToConstant: 90),
            
            countLabel.topAnchor.constraint(equalTo: statsCard.topAnchor, constant: 12),
            countLabel.leadingAnchor.constraint(equalTo: statsCard.leadingAnchor, constant: 12),
            countLabel.trailingAnchor.constraint(equalTo: statsCard.trailingAnchor, constant: -12),
            countLabel.heightAnchor.constraint(equalToConstant: 41),
            
            descriptionLabel.topAnchor.constraint(equalTo: countLabel.bottomAnchor, constant: 7),
            descriptionLabel.leadingAnchor.constraint(equalTo: statsCard.leadingAnchor, constant: 12),
            descriptionLabel.trailingAnchor.constraint(equalTo: statsCard.trailingAnchor, constant: -12),
            descriptionLabel.heightAnchor.constraint(equalToConstant: 18),
            
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
    
    // MARK: - Градиентная рамка
    private func setupGradientBorder() {
        // Удаляем старую, если есть (при повторном вызове)
        gradientBorderLayer.removeFromSuperlayer()
        
        gradientBorderLayer.frame = statsCard.bounds
        
        let outerPath = UIBezierPath(
            roundedRect: statsCard.bounds,
            cornerRadius: 16
        )
        let innerPath = UIBezierPath(
            roundedRect: statsCard.bounds.insetBy(dx: 1, dy: 1),
            cornerRadius: 15
        )
        outerPath.append(innerPath)
        outerPath.usesEvenOddFillRule = true
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = outerPath.cgPath
        maskLayer.fillRule = .evenOdd
        
        gradientBorderLayer.mask = maskLayer
        
        statsCard.layer.addSublayer(gradientBorderLayer)
    }
    
    // MARK: - Байдинги
    private func setupBindings() {
        viewModel.onStatisticsChange = { [weak self] count in
            self?.updateUI(count: count)
        }
        updateUI(count: viewModel.completedCount)
    }
    
    // MARK: - Обновление UI
    private func updateUI(count: Int) {
        let isEmpty = count == 0
        
        statsCard.isHidden = isEmpty
        placeholderImageView.isHidden = !isEmpty
        placeholderLabel.isHidden = !isEmpty
        
        countLabel.text = "\(count)"
    }
}
