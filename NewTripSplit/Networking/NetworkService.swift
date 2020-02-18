//
//  NetworkService.swift
//  NewTripSplit
//
//  Created by Aidan Pendlebury on 13/02/2020.
//  Copyright © 2020 Aidan Pendlebury. All rights reserved.
//

import Foundation

class NetworkService {
    
    static let shared = NetworkService() // Singleton
    
    private init() {
    }
    
    func fetchData(from urlString: String, completion: @escaping (Result<Data, NetworkError>) -> Void) {
        // check the URL is OK, otherwise return with a failure
        guard let url = URL(string: urlString) else {
            completion(.failure(.badURL))
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            // the task has completed – push our work back to the main thread
            DispatchQueue.main.async {
                if let data = data {
                    // success: convert the data to a string and send it back
                    completion(.success(data))
                } else if error != nil {
                    // any sort of network failure
                    completion(.failure(.requestFailed))
                    print(error!.localizedDescription)
                } else {
                    // this ought not to be possible, yet here we are
                    completion(.failure(.unknown))
                }
            }
        }.resume()
    }
    
}


enum NetworkError: Error {
    case badURL, requestFailed, unknown
}
