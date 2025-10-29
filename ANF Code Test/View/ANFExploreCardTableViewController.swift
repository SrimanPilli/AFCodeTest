//
//  ANFExploreCardTableViewController.swift
//  ANF Code Test
//

import UIKit

class ANFExploreCardTableViewController: UITableViewController {
    
    private let viewModel: ProductCardViewModel
    
    init(viewModel: ProductCardViewModel) {
            self.viewModel = viewModel
            super.init(nibName: nil, bundle: nil)
        //super.init(style: .plain)
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    
    
    //Life Cycle
    override func viewDidLoad() {

        
        super.viewDidLoad()
                title = "Abercrombie & Fitch"
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.black ]
        
                setupTableView()
                bindViewModel()
                viewModel.fetchProductCards()
    }
    
    // Binding
    private func setupTableView() {
            tableView.register(ExploreContentCell.self, forCellReuseIdentifier: "ExploreContentCell")
            tableView.rowHeight = UITableView.automaticDimension
            tableView.estimatedRowHeight = 400
        }
    
    //  Binding
        private func bindViewModel() {
            viewModel.onUpdate = { [weak self] in
                self?.tableView.reloadData()
            }

            viewModel.onError = { [weak self] message in
                guard let message = message else { return }
                self?.showError(message)
            }

            viewModel.onLoadingStateChange = { [weak self] isLoading in
                if isLoading {
                    self?.showLoadingIndicator()
                } else {
                    self?.hideLoadingIndicator()
                }
            }
        }
    private func showLoadingIndicator() {
            let spinner = UIActivityIndicatorView(style: .large)
            spinner.center = view.center
            spinner.startAnimating()
            spinner.tag = 100
            view.addSubview(spinner)
        }
    
    private func hideLoadingIndicator() {
            view.viewWithTag(100)?.removeFromSuperview()
        }
    
    private func showError(_ message: String) {
            let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    
    // TableView Data Source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.productCards.count
    }
    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ExploreContentCell", for: indexPath) as? ExploreContentCell else {
            fatalError("can not dequeue ExploreContentCell")
        }
        
        let card = viewModel.productCards[indexPath.row]
        cell.configure(with: card)
        cell.selectionStyle = .none
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
}
    
    extension ANFExploreCardTableViewController: ExploreContentCellDelegate {
        func exploreContentCell(_ cell: ExploreContentCell, didTapLink urlString: String){
            guard let url = URL(string: urlString),
                         UIApplication.shared.canOpenURL(url)
                   else {
                       print("Invalid URL: \(urlString)")
                       return
                   }
                   UIApplication.shared.open(url)
        }
    }


