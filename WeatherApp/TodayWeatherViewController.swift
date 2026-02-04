//
//  TodayWeatherViewController.swift
//  WeatherApp
//
//  Created by Lizzy on 03.02.26.
//

import UIKit

final class TodayWeatherViewController: UIViewController {

    private let gradientBarView = UIView()
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let iconImageView = UIImageView()
    private let locationLabel = UILabel()
    private let tempAndDescLabel = UILabel()
    private let separatorLine = UIView()
    private let upperSpacer = UIView()
    private let cloudsValueLabel = UILabel()
    private let humidityValueLabel = UILabel()
    private let pressureValueLabel = UILabel()
    private let windSpeedValueLabel = UILabel()
    private let windDirectionValueLabel = UILabel()
    private let metricsStackView = UIStackView()

    private let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .systemChromeMaterial))
    private let activityIndicator = UIActivityIndicatorView(style: .large)

    private let errorIconView = UIImageView()
    private let errorLabel = UILabel()
    private let retryButton = UIButton(type: .system)

    private var shareBarButton: UIBarButtonItem!

    private var currentWeather: CurrentWeatherResponse?
    private var hasLoadedOnce = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Today"

        configureNavigationItems()
        configureGradientBar()
        configureViews()
        configureLayout()
        configureErrorViews()

        contentView.isHidden = false
        blurView.isHidden = true
        locationLabel.text = "Loading location..."
        tempAndDescLabel.text = "--°C | --"
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !hasLoadedOnce {
            hasLoadedOnce = true
            loadWeather()
        }
    }

    private func configureGradientBar() {
        gradientBarView.translatesAutoresizingMaskIntoConstraints = false
        gradientBarView.backgroundColor = .clear
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor.systemRed.cgColor,
            UIColor.systemOrange.cgColor,
            UIColor.systemYellow.cgColor,
            UIColor.systemGreen.cgColor,
            UIColor.systemBlue.cgColor,
            UIColor.systemPurple.cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        gradient.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 4)
        gradientBarView.layer.addSublayer(gradient)
        view.addSubview(gradientBarView)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let gradient = gradientBarView.layer.sublayers?.first as? CAGradientLayer {
            gradient.frame = CGRect(x: 0, y: 0, width: gradientBarView.bounds.width, height: gradientBarView.bounds.height)
        }
    }

    private func configureNavigationItems() {
        let refreshItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(didTapRefresh))
        shareBarButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(didTapShare))
        navigationItem.leftBarButtonItem = refreshItem
        navigationItem.rightBarButtonItem = shareBarButton
    }

    private func metricCell(assetName: String, valueLabel: UILabel) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        let image = UIImage(named: assetName)?.withRenderingMode(.alwaysTemplate)
        let iv = UIImageView(image: image)
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        iv.tintColor = UIColor(red: 1.0, green: 0.72, blue: 0.2, alpha: 1)
        valueLabel.font = .preferredFont(forTextStyle: .subheadline)
        valueLabel.textColor = .label
        valueLabel.textAlignment = .center
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(iv)
        container.addSubview(valueLabel)
        NSLayoutConstraint.activate([
            iv.topAnchor.constraint(equalTo: container.topAnchor),
            iv.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            iv.widthAnchor.constraint(equalToConstant: 38),
            iv.heightAnchor.constraint(equalToConstant: 38),
            valueLabel.topAnchor.constraint(equalTo: iv.bottomAnchor, constant: 2),
            valueLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            valueLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            valueLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        return container
    }

    private func configureViews() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        locationLabel.translatesAutoresizingMaskIntoConstraints = false
        tempAndDescLabel.translatesAutoresizingMaskIntoConstraints = false
        separatorLine.translatesAutoresizingMaskIntoConstraints = false
        upperSpacer.translatesAutoresizingMaskIntoConstraints = false
        metricsStackView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.backgroundColor = .clear
        iconImageView.clipsToBounds = true
        iconImageView.image = UIImage(named: "sun")
        iconImageView.tintColor = nil
        locationLabel.font = .systemFont(ofSize: 28, weight: .medium)
        locationLabel.textAlignment = .center
        locationLabel.textColor = .secondaryLabel
        locationLabel.numberOfLines = 1

        tempAndDescLabel.font = .systemFont(ofSize: 26, weight: .semibold)
        tempAndDescLabel.textAlignment = .center
        tempAndDescLabel.textColor = .systemBlue
        tempAndDescLabel.numberOfLines = 1

        separatorLine.backgroundColor = .separator
        upperSpacer.translatesAutoresizingMaskIntoConstraints = false

        cloudsValueLabel.text = "--%"
        humidityValueLabel.text = "--%"
        pressureValueLabel.text = "-- hPa"
        windSpeedValueLabel.text = "-- km/h"
        windDirectionValueLabel.text = "--"

        metricsStackView.axis = .vertical
        metricsStackView.spacing = 20
        metricsStackView.distribution = .fillEqually
        metricsStackView.alignment = .fill

        let row1 = UIStackView()
        row1.axis = .horizontal
        row1.distribution = .fillEqually
        row1.spacing = 8
        row1.addArrangedSubview(metricCell(assetName: "raining", valueLabel: cloudsValueLabel))
        row1.addArrangedSubview(metricCell(assetName: "drop", valueLabel: humidityValueLabel))
        row1.addArrangedSubview(metricCell(assetName: "celsius", valueLabel: pressureValueLabel))
        let row2 = UIStackView()
        row2.axis = .horizontal
        row2.distribution = .fillEqually
        row2.spacing = 8
        row2.addArrangedSubview(metricCell(assetName: "wind", valueLabel: windSpeedValueLabel))
        row2.addArrangedSubview(metricCell(assetName: "compass", valueLabel: windDirectionValueLabel))
        metricsStackView.addArrangedSubview(row1)
        metricsStackView.addArrangedSubview(row2)
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(iconImageView)
        contentView.addSubview(locationLabel)
        contentView.addSubview(tempAndDescLabel)
        contentView.addSubview(upperSpacer)
        contentView.addSubview(separatorLine)
        contentView.addSubview(metricsStackView)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        blurView.isHidden = true
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        view.addSubview(blurView)
        blurView.contentView.addSubview(activityIndicator)
    }

    private func configureLayout() {
        NSLayoutConstraint.activate([
            gradientBarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            gradientBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            gradientBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            gradientBarView.heightAnchor.constraint(equalToConstant: 4),

            scrollView.topAnchor.constraint(equalTo: gradientBarView.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            upperSpacer.topAnchor.constraint(equalTo: contentView.topAnchor),
            upperSpacer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            upperSpacer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            upperSpacer.bottomAnchor.constraint(equalTo: separatorLine.topAnchor),

            iconImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: upperSpacer.centerYAnchor, constant: -40),
            iconImageView.heightAnchor.constraint(equalToConstant: 120),
            iconImageView.widthAnchor.constraint(equalToConstant: 120),

            locationLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 6),
            locationLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            locationLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            tempAndDescLabel.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: 4),
            tempAndDescLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            tempAndDescLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            tempAndDescLabel.bottomAnchor.constraint(lessThanOrEqualTo: separatorLine.topAnchor, constant: -6),

            separatorLine.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 72),
            separatorLine.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -72),
            separatorLine.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            separatorLine.heightAnchor.constraint(equalToConstant: 0.5),
            metricsStackView.topAnchor.constraint(equalTo: separatorLine.bottomAnchor, constant: 28),
            metricsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            metricsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            metricsStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),
            contentView.heightAnchor.constraint(greaterThanOrEqualTo: scrollView.frameLayoutGuide.heightAnchor),

            blurView.topAnchor.constraint(equalTo: view.topAnchor),
            blurView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            blurView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: blurView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: blurView.centerYAnchor)
        ])
    }

    private func configureErrorViews() {
        errorIconView.translatesAutoresizingMaskIntoConstraints = false
        errorIconView.contentMode = .scaleAspectFit
        errorIconView.image = UIImage(named: "ErrorCloud")

        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        retryButton.translatesAutoresizingMaskIntoConstraints = false

        errorLabel.textColor = .label
        errorLabel.font = .preferredFont(forTextStyle: .body)
        errorLabel.textAlignment = .center
        errorLabel.numberOfLines = 0

        retryButton.setTitle("Try Again", for: .normal)
        retryButton.addTarget(self, action: #selector(didTapRetry), for: .touchUpInside)

        view.addSubview(errorIconView)
        view.addSubview(errorLabel)
        view.addSubview(retryButton)

        NSLayoutConstraint.activate([
            errorIconView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            errorIconView.widthAnchor.constraint(equalToConstant: 80),
            errorIconView.heightAnchor.constraint(equalToConstant: 80),
            errorIconView.bottomAnchor.constraint(equalTo: errorLabel.topAnchor, constant: -16),

            errorLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            errorLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20),
            errorLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            errorLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            retryButton.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 12),
            retryButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])

        errorIconView.isHidden = true
        errorLabel.isHidden = true
        retryButton.isHidden = true
    }

    // MARK: - Actions

    @objc private func didTapRefresh() {
        loadWeather()
    }

    @objc private func didTapRetry() {
        loadWeather()
    }

    @objc private func didTapShare() {
        guard let currentWeather = currentWeather else { return }
        let desc = currentWeather.weather.first?.description.capitalized ?? ""
        let text = """
        Weather in \(currentWeather.name):
        \(Int(currentWeather.main.temp))°C | \(desc)
        Clouds: \(currentWeather.clouds.all)%
        Humidity: \(currentWeather.main.humidity)%
        Wind: \(String(format: "%.1f", currentWeather.wind.speed * 3.6)) km/h
        """
        let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        present(activityVC, animated: true)
    }

    // MARK: - Loading & State

    private func setLoading(_ isLoading: Bool) {
        if isLoading {
            blurView.isHidden = false
            blurView.alpha = 1.0
            activityIndicator.startAnimating()
            errorLabel.isHidden = true
            retryButton.isHidden = true
            contentView.isHidden = false
        } else {
            blurView.isHidden = true
            blurView.alpha = 0.0
            activityIndicator.stopAnimating()
        }
    }

    private func showError(message: String) {
        setLoading(false)
        contentView.isHidden = true
        errorIconView.isHidden = false
        errorLabel.text = message
        errorLabel.isHidden = false
        retryButton.isHidden = false
        shareBarButton.isEnabled = false
    }

    private func showContent() {
        errorIconView.isHidden = true
        errorLabel.isHidden = true
        retryButton.isHidden = true
        contentView.isHidden = false
        blurView.isHidden = true
        blurView.alpha = 0.0
        shareBarButton.isEnabled = true
    }

    private func loadWeather() {
        setLoading(true)

        LocationService.shared.requestLocation { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .failure(let error):
                let message: String
                switch error {
                case .denied:
                    message = "Location access was denied. Please enable it in Settings to see the weather for your area."
                case .restricted:
                    message = "Location access is restricted on this device."
                case .unableToDetermine:
                    message = "Unable to determine your location. Please try again."
                }
                self.showError(message: message)

            case .success(let coordinate):
                WeatherAPIClient.shared.fetchCurrentWeather(lat: coordinate.latitude, lon: coordinate.longitude) { [weak self] result in
                    guard let self = self else { return }
                    switch result {
                    case .failure(let error):
                        let errorMessage: String
                        if case .invalidResponse = error {
                            errorMessage = "Invalid API key or server error. Please check your OpenWeatherMap API key."
                        } else if case .requestFailed(let underlyingError) = error {
                            errorMessage = "Network error: \(underlyingError.localizedDescription)"
                        } else {
                            errorMessage = "Failed to load weather data. Please try again."
                        }
                        self.showError(message: errorMessage)
                    case .success(let weather):
                        self.currentWeather = weather
                        self.updateUI(with: weather)
                        self.setLoading(false)
                        self.showContent()
                    }
                }
            }
        }
    }

    private func windDirection(from degrees: Double) -> String {
        let cards = ["N", "NE", "E", "SE", "S", "SW", "W", "NW"]
        let idx = Int((degrees + 22.5) / 45) % 8
        return cards[idx]
    }

    private func updateUI(with weather: CurrentWeatherResponse) {
        if let country = weather.sys?.country, !country.isEmpty {
            locationLabel.text = "\(weather.name), \(country)"
        } else {
            locationLabel.text = weather.name
        }
        let desc = weather.weather.first?.description.capitalized ?? ""
        tempAndDescLabel.text = "\(Int(weather.main.temp))°C | \(desc)"

        cloudsValueLabel.text = "\(weather.clouds.all) %"
        humidityValueLabel.text = "\(weather.main.humidity) %"
        pressureValueLabel.text = String(format: "%.1f hPa", Double(weather.main.pressure))
        let kmh = weather.wind.speed * 3.6
        windSpeedValueLabel.text = String(format: "%.1f km/h", kmh)
        windDirectionValueLabel.text = windDirection(from: weather.wind.deg)

        contentView.isHidden = false
        scrollView.isHidden = false
        view.setNeedsLayout()
        view.layoutIfNeeded()

        if let icon = weather.weather.first?.icon {
            loadIcon(named: icon)
        } else {
            iconImageView.image = nil
        }
    }

    private func loadIcon(named icon: String) {
        let urlString = "https://openweathermap.org/img/wn/\(icon)@2x.png"
        guard let url = URL(string: urlString) else {
            iconImageView.image = nil
            return
        }
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let self = self, let data = data, let image = UIImage(data: data) else { return }
            let displayImage = image.withRenderingMode(.alwaysOriginal)
            DispatchQueue.main.async {
                self.iconImageView.tintColor = nil
                self.iconImageView.image = displayImage
            }
        }.resume()
    }
}

