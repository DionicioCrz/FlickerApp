//
//  FlickrSearchTests.swift
//  FlickrSearchTests
//
//  Created by Dionicio Cruz Velázquez on 1/15/25.
//

import Combine
import XCTest
@testable import FlickrSearch

final class FlickrSearchTests: XCTestCase {
    private var viewModel: FlickrViewModel!
    private var service: MockService!
    private var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        service = MockService()
        viewModel = FlickrViewModel(service: service)
        cancellables = []
    }
    
    override func tearDown() {
        viewModel = nil
        service = nil
        cancellables = nil
        super.tearDown()
    }

    func testLoadingStateWhenFetchingData() {
        let expectation = XCTestExpectation(description: "State should be loading")
        
        service.result = .success(FlickrResponse(items: []))
        viewModel.startObserving()
        viewModel.$state
            .dropFirst()
            .sink { state in
                if case .loading = state {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        viewModel.searchQuery = "Test"
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testSuccessStateWithData() {
        let rawItems = [
            FlickrItem(
                title: "Item 1",
                link: "https://example.com/image1.jpg",
                media: MediaImage(m: "https://example.com/thumb1.jpg"),
                description: "Description 1",
                author: "Author 1",
                published: "2025-01-14T10:00:00Z"
            )
        ]

        let transformedItems = [
            FlickrItem(
                title: "Item 1",
                link: "https://example.com/thumb1.jpg",
                media: MediaImage(m: "https://example.com/thumb1.jpg"),
                description: "Description 1",
                author: "Author 1",
                published: "2025-01-14T10:00:00Z"
            )
        ]
        
        let expectation = XCTestExpectation(description: "State should be success with items")
        
        service.result = .success(FlickrResponse(items: rawItems))
        viewModel.startObserving()
        viewModel.$state
            .dropFirst()
            .sink { state in
                if case let .success(images) = state, images == transformedItems {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        viewModel.searchQuery = "Test"
        
        wait(for: [expectation], timeout: 1.0)
    }

    
    func testEmptyStateWhenNoResults() {
        let expectation = XCTestExpectation(description: "State should be empty")
        
        service.result = .success(FlickrResponse(items: []))
        viewModel.startObserving()
        viewModel.$state
            .dropFirst()
            .sink { state in
                if case .empty = state {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        viewModel.searchQuery = "Test"
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testErrorStateWhenServiceFails() {
        let expectation = XCTestExpectation(description: "State should be error")
        
        service.result = .failure(URLError(.notConnectedToInternet))
        viewModel.startObserving()
        viewModel.$state
            .dropFirst()
            .sink { state in
                if case let .error(message) = state, message == URLError(.notConnectedToInternet).localizedDescription {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        viewModel.searchQuery = "Test"
        
        wait(for: [expectation], timeout: 1.0)
    }
}
