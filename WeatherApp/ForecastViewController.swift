//
//  ForecastViewController.swift
//  WeatherApp
//
//  Created by Lizzy on 03.02.26.
//

import UIKit

private struct ForecastSection {
    let date: Date
    let items: [ForecastResponse.Item]
}

final class ForecastViewController: UIViewController {

    private let gradientBarView = UIView()
    private let tableView = UITableView(frame: .zero, style: .plain)

    private let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .systemChromeMaterial))
    private let activityIndicator = UIActivityIndicatorView(style: .large)

    private let errorIconView = UIImageView()
    private let errorLabel = UILabel()
    private let retryButton = UIButton(type: .system)

    private var sections: [ForecastSection] = []
    private var cityName: String?
    private var hasLoadedOnce = false

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()

    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        formatter.timeZone = .current
        return formatter
    }()

    private let weekdayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "EEEE"
        return f
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Forecast"

        configureNavigationItems()
        configureGradientBar()
        configureTableView()
        configureLoadingViews()
        configureErrorViews()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let gradient = gradientBarView.layer.sublayers?.first as? CAGradientLayer {
            gradient.frame = CGRect(x: 0, y: 0, width: gradientBarView.bounds.width, height: gradientBarView.bounds.height)
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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !hasLoadedOnce {
            hasLoadedOnce = true
            loadForecast()
        }
    }

    private func configureNavigationItems() {
        let refreshItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(didTapRefresh))
        navigationItem.leftBarButtonItem = refreshItem
    }

    private func configureTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .systemBackground
        tableView.rowHeight = 88
        tableView.estimatedRowHeight = 88
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 1))
        tableView.register(ForecastCell.self, forCellReuseIdentifier: ForecastCell.reuseId)
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }

        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            gradientBarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            gradientBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            gradientBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            gradientBarView.heightAnchor.constraint(equalToConstant: 4),
            tableView.topAnchor.constraint(equalTo: gradientBarView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func configureLoadingViews() {
        blurView.translatesAutoresizingMaskIntoConstraints = false
        blurView.isHidden = true
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true

        view.addSubview(blurView)
        blurView.contentView.addSubview(activityIndicator)

        NSLayoutConstraint.activate([
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
        errorLabel.numberOfLines = 0
        errorLabel.textAlignment = .center

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
        loadForecast()
    }

    @objc private func didTapRetry() {
        loadForecast()
    }

    // MARK: - Loading & State

    private func setLoading(_ isLoading: Bool) {
        if isLoading {
            blurView.isHidden = false
            activityIndicator.startAnimating()
            errorIconView.isHidden = true
            errorLabel.isHidden = true
            retryButton.isHidden = true
        } else {
            blurView.isHidden = true
            activityIndicator.stopAnimating()
        }
    }

    private func showError(message: String) {
        setLoading(false)
        tableView.isHidden = true
        errorIconView.isHidden = false
        errorLabel.text = message
        errorLabel.isHidden = false
        retryButton.isHidden = false
    }

    private func showContent() {
        tableView.isHidden = false
        errorIconView.isHidden = true
        errorLabel.isHidden = true
        retryButton.isHidden = true
    }

    private func loadForecast() {
        setLoading(true)

        LocationService.shared.requestLocation { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .failure(let error):
                let message: String
                switch error {
                case .denied:
                    message = "Location access was denied. Please enable it in Settings to see the forecast for your area."
                case .restricted:
                    message = "Location access is restricted on this device."
                case .unableToDetermine:
                    message = "Unable to determine your location. Please try again."
                }
                self.showError(message: message)

            case .success(let coordinate):
                WeatherAPIClient.shared.fetchFiveDayForecast(lat: coordinate.latitude, lon: coordinate.longitude) { [weak self] result in
                    guard let self = self else { return }
                    switch result {
                    case .failure(let error):
                        let errorMessage: String
                        if case .invalidResponse = error {
                            errorMessage = "Invalid API key or server error. Please check your OpenWeatherMap API key."
                        } else if case .requestFailed(let underlyingError) = error {
                            errorMessage = "Network error: \(underlyingError.localizedDescription)"
                        } else {
                            errorMessage = "Failed to load forecast data. Please try again."
                        }
                        self.showError(message: errorMessage)
                    case .success(let response):
                        self.cityName = response.city.name
                        self.sections = self.groupForecastItems(response.list)
                        self.setLoading(false)
                        self.showContent()
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }

    private func groupForecastItems(_ items: [ForecastResponse.Item]) -> [ForecastSection] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: items) { item -> Date in
            let date = Date(timeIntervalSince1970: item.dt)
            return calendar.startOfDay(for: date)
        }

        let sortedKeys = grouped.keys.sorted()
        return sortedKeys.map { key in
            let itemsForDay = grouped[key]?.sorted(by: { $0.dt < $1.dt }) ?? []
            return ForecastSection(date: key, items: itemsForDay)
        }
    }
}

extension ForecastViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sections[section].items.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        weekdayFormatter.string(from: sections[section].date).uppercased()
    }

    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        (view as? UITableViewHeaderFooterView)?.textLabel?.textColor = .secondaryLabel
        (view as? UITableViewHeaderFooterView)?.textLabel?.font = .preferredFont(forTextStyle: .subheadline)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ForecastCell.reuseId, for: indexPath) as! ForecastCell
        let item = sections[indexPath.section].items[indexPath.row]
        let date = Date(timeIntervalSince1970: item.dt)
        let timeStr = timeFormatter.string(from: date)
        let desc = item.weather.first?.description.capitalized ?? ""
        let tempStr = "\(Int(item.main.temp))°C"

        cell.configure(time: timeStr, description: desc, temp: tempStr, image: nil)

        if let icon = item.weather.first?.icon {
            let urlString = "https://openweathermap.org/img/wn/\(icon)@2x.png"
            if let url = URL(string: urlString) {
                URLSession.shared.dataTask(with: url) { data, _, _ in
                    guard let data = data, let image = UIImage(data: data)?.withRenderingMode(.alwaysOriginal) else { return }
                    DispatchQueue.main.async {
                        if let visibleCell = tableView.cellForRow(at: indexPath) as? ForecastCell {
                            visibleCell.setWeatherImage(image)
                        }
                    }
                }.resume()
            }
        }
        return cell
    }
}

