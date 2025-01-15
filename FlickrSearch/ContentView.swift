//
//  ContentView.swift
//  FlickrSearch
//
//  Created by Dionicio Cruz Velázquez on 1/15/25.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.horizontalSizeClass) private var sizeClass
    @StateObject private var viewModel = FlickrViewModel(service: ServiceImpl())
    
    var body: some View {
        NavigationView {
            VStack {
                SearchBar(text: $viewModel.searchQuery)
                Spacer(minLength: 16)
                
                switch viewModel.state {
                case .idle:
                    Text("Start typing to search...")
                        .foregroundColor(.gray)
                        .padding()
                    
                case .loading:
                    ProgressView("Loading...")
                        .padding()
                    
                case .success(let images):
                    ImageGrid(images: images)
                    
                case .empty:
                    Text("No results found")
                        .foregroundColor(.gray)
                        .padding()
                    
                case .error(let message):
                    ErrorView(retryAction: {
                        viewModel.retrySearch()
                    }, message: message)
                }
                
                Spacer()
            }
            .onAppear {
                viewModel.startObserving()
            }
            .navigationTitle("Flickr Search")
        }
    }
}

struct ImageGrid: View {
    let images: [FlickrItem]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))]) {
                ForEach(images.indices, id: \.self) { index in
                    let image = images[index]
                    NavigationLink(destination: DetailView(image: image)) {
                        ThumbnailView(imageURL: URL(string: image.media!.m))
                    }
                }
            }
            .padding()
        }
    }
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        TextField("Search", text: $text)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .autocorrectionDisabled(true)
            .padding()
    }
}

struct ErrorView: View {
    let retryAction: () -> Void
    let message: String
    
    var body: some View {
        VStack {
            Text(message)
                .multilineTextAlignment(.center)
                .foregroundColor(.primary)
                .padding()
            Button("Try Again") {
                retryAction()
            }
        }
        .padding()
    }
}

struct ThumbnailView: View {
    let imageURL: URL?
    
    var body: some View {
        AsyncImage(url: imageURL) { phase in
            switch phase {
            case .success(let image):
                image.resizable().scaledToFill()
            default:
                Color.gray
            }
        }
        .frame(width: 100, height: 100)
        .clipped()
    }
}
