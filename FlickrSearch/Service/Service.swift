//
//  Service.swift
//  FlickrSearch
//
//  Created by Dionicio Cruz Velázquez on 1/15/25.
//

import Combine
import Foundation

protocol Service {
    func fetchData(searchTerm: String) -> AnyPublisher<FlickrResponse, Error>
}

class ServiceImpl: Service {
    private let session = URLSession.shared
    private let decoder = JSONDecoder()
    
    func fetchData(searchTerm: String) -> AnyPublisher<FlickrResponse, Error> {
        guard let url = URL(string: "\(Constants.baseUrl)\(searchTerm)") else {
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }
        let request = URLRequest(url: url)
        return session.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: FlickrResponse.self, decoder: decoder)
            .eraseToAnyPublisher()
    }
}
