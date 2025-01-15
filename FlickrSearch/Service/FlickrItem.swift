//
//  ImageModel.swift
//  FlickrSearch
//
//  Created by Dionicio Cruz Velázquez on 1/15/25.
//

import Foundation

struct FlickrResponse: Codable {
    let items: [FlickrItem]
}

struct FlickrItem: Codable, Equatable {
    
    let title: String?
    let link: String?
    let media: MediaImage?
    let description: String?
    let author: String?
    let published: String?
}

struct MediaImage: Codable, Equatable {
    let m: String
}
