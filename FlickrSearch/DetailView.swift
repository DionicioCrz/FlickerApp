//
//  DetailView.swift
//  FlickrSearch
//
//  Created by Dionicio Cruz Velázquez on 1/15/25.
//

import SwiftUI

struct DetailView: View {
    let image: FlickrItem
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let link = image.link, let url = URL(string: link) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image.resizable().scaledToFit()
                        default:
                            Color.gray
                        }
                    }
                    .frame(maxWidth: .infinity)
                } else {
                    Text("Image unavailable")
                }
                
                Text("Title: \(image.title ?? "No title")")
                    .font(.headline)
                Text("Author: \(image.author ?? "Unknown author")")
                Text("Description:")
                
                if let description = image.description {
                    HTMLText(htmlContent: description)
                    if let imageURL = extractImageURL(from: description) {
                        HStack {
                            AsyncImage(url: imageURL) { phase in
                                switch phase {
                                case .success(let image):
                                    image.resizable()
                                        .scaledToFit()
                                        .frame(maxWidth: 100)
                                    
                                default:
                                    Color.gray
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                } else {
                    Text("No description available")
                        .foregroundColor(.gray)
                }
                
                Text("Published: \(formattedDate(image.published))")
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack {
                    Text(image.title ?? "Details")
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .minimumScaleFactor(0.5)
                        .frame(maxWidth: .infinity)
                }
            }
        }
    }
    
    private func formattedDate(_ dateString: String?) -> String {
        guard let dateString = dateString else {
            return "Invalid date"
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        if let date = formatter.date(from: dateString) {
            formatter.dateStyle = .medium
            return formatter.string(from: date)
        } else {
            return "Invalid date"
        }
    }
}

struct HTMLText: View {
    let htmlContent: String
    
    var body: some View {
        if let attributedString = attributedString(from: htmlContent) {
            Text(AttributedString(attributedString))
                .multilineTextAlignment(.leading)
        } else {
            Text("Failed to render HTML content")
                .foregroundColor(.red)
        }
    }
    
    private func attributedString(from html: String) -> NSAttributedString? {
        guard let data = html.data(using: .utf8) else { return nil }
        
        return try? NSAttributedString(
            data: data,
            options: [
                .documentType: NSAttributedString.DocumentType.html,
                .characterEncoding: String.Encoding.utf8.rawValue
            ],
            documentAttributes: nil
        )
    }
}

func extractImageURL(from html: String) -> URL? {
    let pattern = "<img src=\"([^\"]+)\""
    let regex = try? NSRegularExpression(pattern: pattern, options: [])
    let nsString = html as NSString
    let results = regex?.firstMatch(in: html, options: [], range: NSRange(location: 0, length: nsString.length))
    
    if let range = results?.range(at: 1) {
        let urlString = nsString.substring(with: range)
        return URL(string: urlString)
    }
    return nil
}

#Preview {
    DetailView(image: FlickrItem(
        title: "Porcupine",
        link: "https://example.com/image.jpg",
        media: MediaImage(m: "https://example.com/thumb.jpg"),
        description: """
        <p><a href="https://www.flickr.com/people/macspud/">Mac Spud</a> posted a photo:</p>
        <p><a href="https://www.flickr.com/photos/macspud/54255022494/" title="IMG_0999">
        <img src="https://live.staticflickr.com/65535/54255022494_0ba648ff48_m.jpg" width="240" height="180" alt="IMG_0999" /></a></p>
        <p>Porcupine</p>
        """,
        author: "Mac Spud",
        published: "2025-01-14T10:00:00Z"
    ))
}
