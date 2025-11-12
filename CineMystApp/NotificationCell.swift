//
//  NotificationCell.swift
//  CineMystApp
//
//  Created by user@50 on 12/11/25.
//


import UIKit

final class NotificationCell: UITableViewCell {
    
    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    private let messageLabel = UILabel()
    private let timeLabel = UILabel()
    private let connectButton = UIButton(type: .system)
    
    private let containerStack = UIStackView()
    private let textStack = UIStackView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func setupUI() {
        selectionStyle = .none
        
        iconView.contentMode = .scaleAspectFill
        iconView.clipsToBounds = true
        iconView.layer.cornerRadius = 20
        iconView.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        messageLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        messageLabel.textColor = .secondaryLabel
        messageLabel.numberOfLines = 2
        
        timeLabel.font = UIFont.systemFont(ofSize: 13)
        timeLabel.textColor = .secondaryLabel
        
        connectButton.setTitle("Connect", for: .normal)
        connectButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        connectButton.tintColor = .white
        connectButton.backgroundColor = UIColor(named: "AppPrimary") ?? .systemPurple
        connectButton.layer.cornerRadius = 12
        connectButton.contentEdgeInsets = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12)
        
        textStack.axis = .vertical
        textStack.spacing = 4
        textStack.addArrangedSubview(titleLabel)
        textStack.addArrangedSubview(messageLabel)
        
        containerStack.axis = .horizontal
        containerStack.spacing = 12
        containerStack.alignment = .center
        containerStack.translatesAutoresizingMaskIntoConstraints = false
        containerStack.addArrangedSubview(iconView)
        containerStack.addArrangedSubview(textStack)
        containerStack.addArrangedSubview(connectButton)
        
        contentView.addSubview(containerStack)
        contentView.addSubview(timeLabel)
        
        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: 40),
            iconView.heightAnchor.constraint(equalToConstant: 40),
            
            containerStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            containerStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            timeLabel.topAnchor.constraint(equalTo: containerStack.bottomAnchor, constant: 4),
            timeLabel.leadingAnchor.constraint(equalTo: containerStack.leadingAnchor, constant: 52),
            timeLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }
    
    func configure(with item: NotificationItem) {
        titleLabel.text = item.title
        messageLabel.text = item.message
        timeLabel.text = item.timeAgo
        connectButton.isHidden = !item.showConnectButton
        
        if item.isSystemIcon {
            iconView.image = UIImage(systemName: item.imageName ?? "bell.fill")
            iconView.tintColor = .systemOrange
            iconView.backgroundColor = .clear
        } else {
            iconView.image = UIImage(named: item.imageName ?? "")
        }
    }
}

