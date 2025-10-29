//
//  AppDependencyContainer.swift
//  ANF Code Test
//
//  Created by Sriman on 10/29/25.
//

import UIKit

final class AppDependencyContainer {
    private let productService: ProductCardServiceProtocol

    init() {
        self.productService = RemoteProductCardService()
    }

    func makeExploreController() -> UIViewController {
        let viewModel = ProductCardViewModel(service: productService)
        let controller = ANFExploreCardTableViewController(viewModel: viewModel)
        return UINavigationController(rootViewController: controller)
    }
}
