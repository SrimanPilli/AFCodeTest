//
//  ProductCardViewModel.swift
//  ANF Code Test
//
//  Created by Sriman on 10/29/25.
//

import Foundation

class ProductCardViewModel {
    
    private let service: ProductCardServiceProtocol
    
    // MARK: - Outputs
    var productCards: [ProductCard] = [] {
        didSet { onUpdate?() }
    }
    
    var errorMessage: String? {
        didSet { onError?(errorMessage) }
    }
    
    var isLoading: Bool = false {
        didSet { onLoadingStateChange?(isLoading) }
    }
    
    // MARK: - Callbacks
    var onUpdate: (() -> Void)?
    var onError: ((String?) -> Void)?
    var onLoadingStateChange: ((Bool) -> Void)?
    
    // MARK: - Init
    init(service: ProductCardServiceProtocol) {
        self.service = service
    }
    
    // MARK: - Fetch Logic
    func fetchProductCards() {
        isLoading = true
        
        service.fetchProductCards { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false
                
                switch result {
                case .success(let cards):
                    self.productCards = cards
                    self.onUpdate?()
                    // Prefetch images
                    self.prefetchImages(for: cards)
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    // Image Prefetch
    private func prefetchImages(for cards: [ProductCard]) {
        var updatedCards = cards
        let group = DispatchGroup()
        
        for index in updatedCards.indices {
            if let urlString = updatedCards[index].backgroundImage,
               let url = URL(string: urlString) {
                group.enter()
                URLSession.shared.dataTask(with: url) { data, _, _ in
                    if let data = data {
                        // Mutate safely inside the closure
                        updatedCards[index].imageData = data
                    }
                    group.leave()
                }.resume()
            }
        }
        
        group.notify(queue: .main) {
            self.productCards = updatedCards
            self.onUpdate?()
        }
    }
}
