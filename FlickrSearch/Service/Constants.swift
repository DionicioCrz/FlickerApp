//
//  Constants.swift
//  FlickrSearch
//
//  Created by Dionicio Cruz Velázquez on 1/15/25.
//

import Foundation

enum Constants {
    static let baseUrl = "https://api.flickr.com/services/feeds/photos_public.gne?format=json&nojsoncallback=1&tags="
}

enum NetworkError: Error {
    case invalidURL
}
