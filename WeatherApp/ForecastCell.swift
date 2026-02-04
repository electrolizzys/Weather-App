//
//  ForecastCell.swift
//  WeatherApp
//

import UIKit

final class ForecastCell: UITableViewCell {

    static let reuseId = "ForecastCell"

    private let weatherImageView: UIImageView = {
        let v = UIImageView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.contentMode = .scaleAspectFit
        v.tintColor = .label
        return v
    }()

    private let timeLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = .preferredFont(forTextStyle: .body)
        l.textColor = .label
        return l
    }()

    private let descriptionLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = .preferredFont(forTextStyle: .subheadline)
        l.textColor = .secondaryLabel
        l.numberOfLines = 1
        return l
    }()

    private let tempLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = .systemFont(ofSize: 22, weight: .semibold)
        l.textColor = .systemBlue
        l.textAlignment = .right
        return l
    }()

    private let leftStack: UIStackView = {
        let s = UIStackView()
        s.translatesAutoresizingMaskIntoConstraints = false
        s.axis = .vertical
        s.spacing = 2
        s.alignment = .leading
        return s
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .systemBackground
        contentView.backgroundColor = .systemBackground
        selectionStyle = .none
        leftStack.addArrangedSubview(timeLabel)
        leftStack.addArrangedSubview(descriptionLabel)
        contentView.addSubview(weatherImageView)
        contentView.addSubview(leftStack)
        contentView.addSubview(tempLabel)
        NSLayoutConstraint.activate([
            weatherImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            weatherImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            weatherImageView.widthAnchor.constraint(equalToConstant: 44),
            weatherImageView.heightAnchor.constraint(equalToConstant: 44),
            leftStack.leadingAnchor.constraint(equalTo: weatherImageView.trailingAnchor, constant: 12),
            leftStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            leftStack.trailingAnchor.constraint(lessThanOrEqualTo: tempLabel.leadingAnchor, constant: -12),
            tempLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            tempLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            tempLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 44)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(time: String, description: String, temp: String, image: UIImage?) {
        timeLabel.text = time
        descriptionLabel.text = description
        tempLabel.text = temp
        weatherImageView.image = image
    }

    func setWeatherImage(_ image: UIImage?) {
        weatherImageView.image = image
    }
}
