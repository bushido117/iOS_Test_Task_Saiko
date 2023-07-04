//
//  MainTableViewCell.swift
//  SaikoTestTask
//
//  Created by Вадим Сайко on 30.06.23.
//

import UIKit

final class MainTableViewCell: UITableViewCell {
    
    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var namesLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = UIColor(red: 0.30, green: 0.36, blue: 0.39, alpha: 1.00)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var idLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = UIColor(red: 0.47, green: 0.52, blue: 0.53, alpha: 1.00)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubviews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addSubviews() {
        addSubview(iconImageView)
        addSubview(namesLabel)
        addSubview(idLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            iconImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            iconImageView.heightAnchor.constraint(equalToConstant: 100),
            iconImageView.widthAnchor.constraint(equalToConstant: 100),
            
            namesLabel.centerYAnchor.constraint(equalTo: iconImageView.centerYAnchor),
            namesLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 10),
      
            idLabel.topAnchor.constraint(equalTo: namesLabel.bottomAnchor),
            idLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 10)
        ])
    }
    
    func fill(with data: Content) {
        namesLabel.text = data.name
        idLabel.text = String(data.id)
        if let url = data.image {
            iconImageView.downloaded(from: url)
        } else {
            iconImageView.image = UIImage(systemName: "person.crop.circle")
        }
    }
}
