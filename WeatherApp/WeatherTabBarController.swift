//
//  WeatherTabBarController.swift
//  WeatherApp
//

import UIKit

final class WeatherTabBarController: UITabBarController {

    private static let tabBarGray = UIColor(red: 0.94, green: 0.94, blue: 0.96, alpha: 1)

    private let extensionHeight: CGFloat = 12

    private lazy var topExtensionView: UIView = {
        let v = UIView()
        v.backgroundColor = Self.tabBarGray
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private lazy var topBorderView: UIView = {
        let v = UIView()
        v.backgroundColor = .separator
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.isTranslucent = false
        tabBar.backgroundColor = Self.tabBarGray
        view.addSubview(topExtensionView)
        view.addSubview(topBorderView)
        NSLayoutConstraint.activate([
            topExtensionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topExtensionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topExtensionView.bottomAnchor.constraint(equalTo: tabBar.topAnchor),
            topExtensionView.heightAnchor.constraint(equalToConstant: extensionHeight),

            topBorderView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topBorderView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topBorderView.bottomAnchor.constraint(equalTo: topExtensionView.topAnchor),
            topBorderView.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
}
