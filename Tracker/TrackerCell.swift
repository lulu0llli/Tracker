import UIKit

protocol TrackerCellDelegate: AnyObject {
    func trackerCellDidTapComplete(_ cell: TrackerCell, trackerId: UUID)
}

final class TrackerCell: UICollectionViewCell {
    
    static let identifier = "TrackerCell"
    weak var delegate: TrackerCellDelegate?
    private var trackerId: UUID?
    
    // MARK: - UI Elements
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .center
        label.backgroundColor = .white.withAlphaComponent(0.3)
        label.layer.cornerRadius = 12
        label.layer.masksToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .white
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let daysLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = UIColor(red: 26/255, green: 27/255, blue: 34/255, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let completeButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .white
        button.layer.cornerRadius = 17
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didTapCompleteButton), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = true
        
        contentView.addSubview(emojiLabel)
        contentView.addSubview(titleLabel)
        contentView.addSubview(daysLabel)
        contentView.addSubview(completeButton)
        
        NSLayoutConstraint.activate([
            emojiLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            emojiLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            emojiLabel.widthAnchor.constraint(equalToConstant: 24),
            emojiLabel.heightAnchor.constraint(equalToConstant: 24),
            
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -44),
            
            daysLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            daysLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            
            completeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            completeButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            completeButton.widthAnchor.constraint(equalToConstant: 34),
            completeButton.heightAnchor.constraint(equalToConstant: 34)
        ])
    }
    
    // MARK: - Configure
    func configure(with tracker: Tracker, isCompleted: Bool, daysCount: Int) {
        trackerId = tracker.id
        emojiLabel.text = tracker.emoji
        titleLabel.text = tracker.title
        contentView.backgroundColor = tracker.color
        daysLabel.text = "\(daysCount) дней"
        
        let imageName = isCompleted ? "checkmark" : "plus"
        completeButton.setImage(UIImage(systemName: imageName), for: .normal)
        completeButton.backgroundColor = isCompleted ? tracker.color.withAlphaComponent(0.5) : tracker.color
    }
    
    // MARK: - Actions
    @objc private func didTapCompleteButton() {
        guard let trackerId = trackerId else { return }
        delegate?.trackerCellDidTapComplete(self, trackerId: trackerId)
    }
}
