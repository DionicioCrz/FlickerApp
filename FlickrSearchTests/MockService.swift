//
//  MockService.swift
//  FlickrSearchTests
//
//  Created by Dionicio Cruz Velázquez on 1/15/25.
//

import Combine
import Foundation
@testable import FlickrSearch

class MockService: Service {
    
    var result: Result<FlickrResponse, Error>?
    
    func fetchData(searchTerm: String) -> AnyPublisher<FlickrResponse, Error> {
        guard let result = result else {
            return Fail(error: URLError(.unknown)).eraseToAnyPublisher()
        }
        
        return result.publisher.eraseToAnyPublisher()
    }
}
