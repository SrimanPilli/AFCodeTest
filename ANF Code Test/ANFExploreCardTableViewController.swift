//
//  ANFExploreCardTableViewController.swift
//  ANF Code Test
//

import UIKit

class ANFExploreCardTableViewController: UITableViewController {
    
    // Dependency Injection for service
    // Using protocol allows easy for mocking testing DIP
    
    var productCardService: ProductCardServiceProtocol = RemoteProductCardService()

    var productCards: [ProductCard] = []
    
    //Life Cycle
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        //registering customUITableViewCell
        
        tableView.register(ExploreContentCell.self, forCellReuseIdentifier: "ExploreContentCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 400
        
        self.title = "Explore"
        fetchProductCards()
    }
    
    
    // TableView Data Source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return productCards.count
    }
    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ExploreContentCell", for: indexPath) as? ExploreContentCell else {
            fatalError("can not dequeue ExploreContentCell")
        }
        
        let card = productCards[indexPath.row]
        cell.configure(with: card)
        
        return cell
    }
    
    // Button Action
    
    func openURL(_ urlString: String){
        guard let url = URL(string: urlString), UIApplication.shared.canOpenURL(url)
        else{
            print("invalid URL : \(urlString)")
            return
        }
        UIApplication.shared.open(url)
    }
    
    private func fetchProductCards() {
        productCardService.fetchProductCards { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                switch result {
                case .success(let receivedCards):
                    // Store cards
                        var mutableCards = receivedCards
                        self.productCards = mutableCards
                    
                    // Reload table immediately so UI is usable
                    self.tableView.reloadData()

                    
                    // Prefetch images in background
                    let group = DispatchGroup()
                    for index in 0..<mutableCards.count {
                        if let urlString = mutableCards[index].backgroundImage,
                           let url = URL(string: urlString) {
                            group.enter()
                            URLSession.shared.dataTask(with: url) { data, _, _ in
                                if let data = data {
                                    mutableCards[index].imageData = data
                                }
                                group.leave()
                            }.resume()
                        }
                    }
                    
                    group.notify(queue: .main) {
                        // Update table again with images after prefetch
                        self.productCards = mutableCards
                        self.tableView.reloadData()
                        print("All images preloaded for cards: \(mutableCards.count)")
                    }
                    
                case .failure(let error):
                    print("error fetching product cards: \(error)")
                }
            }
        }
    }
}
    
    extension ANFExploreCardTableViewController: ExploreContentCellDelegate {
        func exploreContentCell(_ cell: ExploreContentCell, didTapLink urlString: String){
            openURL(urlString)
        }
    }


