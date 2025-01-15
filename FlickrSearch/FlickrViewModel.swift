//
//  flickrViewModel.swift
//  FlickrSearch
//
//  Created by Dionicio Cruz Velázquez on 1/15/25.
//

import Combine
import Foundation

class FlickrViewModel: ObservableObject {
    private let service: Service
    
    @Published var searchQuery: String = ""
    @Published private(set) var state: ViewState = .idle
    
    private var hasStartedObserving = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init(service: Service) {
        self.service = service
    }
    
    func startObserving() {
        guard !hasStartedObserving else { return }
        hasStartedObserving = true
        $searchQuery
            .removeDuplicates()
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] query in
                self?.fetchImages(for: query)
            }
            .store(in: &cancellables)
    }
    
    func retrySearch() {
        if !searchQuery.isEmpty {
            self.fetchImages(for: searchQuery)
        }
    }
    
    private func fetchImages(for query: String) {
        guard !query.isEmpty else {
            state = .idle
            return
        }
        
        state = .loading
        service.fetchData(searchTerm: query)
            .receive(on: DispatchQueue.main)
            .map { response in
                self.transformToDisplayableItems(response.items)
            }
            .sink(receiveCompletion: { [weak self] completion in
                guard let self = self else { return }
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self.state = .error(error.localizedDescription.capitalized)
                }
            }, receiveValue: { [weak self] images in
                guard let self = self else { return }
                if images.isEmpty {
                    self.state = .empty
                } else {
                    self.state = .success(images)
                }
            })
            .store(in: &cancellables)
    }
    
    private func transformToDisplayableItems(_ flickrResponse: [FlickrItem]) -> [FlickrItem] {
        flickrResponse.compactMap { item in
            guard
                let title = item.title,
                let media = item.media,
                let description = item.description,
                let author = item.author,
                let published = item.published else { return nil }
            
            return FlickrItem(
                title: title,
                link: media.m,
                media: media,
                description: description,
                author: author,
                published: published
            )
        }
    }
}

enum ViewState {
    case idle
    case loading
    case success([FlickrItem])
    case empty
    case error(String)
}
