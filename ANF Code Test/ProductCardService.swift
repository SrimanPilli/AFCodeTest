//
//  ProductCardService.swift
//  ANF Code Test
//
//  Created by SaiSriman on 10/27/25.
//

import Foundation

protocol ProductCardServiceProtocol {
    func fetchProductCards(completion: @escaping(Result<[ProductCard], Error>) -> Void)
}

enum DataError: Error {
    case fileNotFound
    case decodingFailed(Error)
    case unknown
    case invalidURL
    case networkError(Error)

}

class RemoteProductCardService: ProductCardServiceProtocol {
    
    private let apiURLString = "https://www.abercrombie.com/anf/nativeapp/qa/codetest/codeTest_exploreData.css"
    
    func fetchProductCards(completion: @escaping (Result<[ProductCard], Error>) -> Void) {
        
        // 2. Safely create the URL object
        guard let url = URL(string: apiURLString) else {
            completion(.failure(DataError.invalidURL))
            return
        }
        
        // 3. Start the asynchronous network request
        URLSession.shared.dataTask(with: url) { data, response, error in
            
            // 4. Check for network errors
            if let error = error {
                completion(.failure(DataError.networkError(error)))
                return
            }
            
            // 5. Check for data presence
            guard let data = data else {
                completion(.failure(DataError.unknown))
                return
            }
            
            // 6. Decode the JSON data
            do {
                let decoder = JSONDecoder()
                
                // IMPORTANT: We still assume the API returns a root-level array of ProductCards
                let productCards = try decoder.decode([ProductCard].self, from: data)
                
                // Success!
                completion(.success(productCards))
                
            } catch let decodingError as DecodingError {
                completion(.failure(DataError.decodingFailed(decodingError)))
            } catch {
                completion(.failure(error))
            }
            
        }.resume()
    }
}
