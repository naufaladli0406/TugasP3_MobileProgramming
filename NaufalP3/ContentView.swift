//
//  ContentView.swift
//  NaufalP3
//
//  Created by Naufal Adli on 10/03/25.
//

import Foundation
import Combine
import WebKit
import SwiftUI

struct NewsResponse: Codable {
    let data_news: [News]

    enum CodingKeys: String, CodingKey {
        case data_news = "DATA_NEWS"
    }
}

struct News: Codable, Identifiable {
    let id = UUID()
    let title_news: String
    let link_news: String
    let image_link: String
}

class NewsViewModel: ObservableObject {
    @Published var news: [News] = []

    func loadJSON() {
        if let url = Bundle.main.url(forResource: "news", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoded = try JSONDecoder().decode(NewsResponse.self, from: data)
                DispatchQueue.main.async {
                    self.news = decoded.data_news
                }
            } catch {
                print("Error decoding JSON: \(error)")
            }
        }
    }
}


struct WebView: UIViewRepresentable {
    let urlString: String

    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        guard let url = URL(string: urlString) else { return }
        let request = URLRequest(url: url)
        uiView.load(request)
    }
}


struct ContentView: View {
    @StateObject var viewModel = NewsViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {

                    Image("banner")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 180)
                        .cornerRadius(12)
                        .padding(.horizontal)

                    Text("Breaking News")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 15) {
                        ForEach(viewModel.news) { item in
                            NavigationLink(destination: NewsDetailView(news: item)) {
                                HStack(alignment: .top) {
                                    Text("•")
                                        .multilineTextAlignment(.leading)
                                    Text(item.title_news)
                                        .multilineTextAlignment(.leading)
                                }
                             
                                .foregroundColor(.primary)
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.top)
            }
            .navigationTitle("")
            .navigationBarHidden(true)
        }
        .onAppear {
            viewModel.loadJSON()
        }
    }
}

struct NewsItemView: View {
    let news: News

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            AsyncImage(url: URL(string: news.image_link)) { image in
                image.resizable()
            } placeholder: {
                Color.gray.opacity(0.3)
            }
            .aspectRatio(contentMode: .fill)
            .frame(height: 180)
            .clipped()
            .cornerRadius(10)

            Text(news.title_news)
                .font(.headline)
                .foregroundColor(.primary)
        }
    }
}

struct NewsDetailView: View {
    let news: News

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // 🖼️ Gambar atas
                AsyncImage(url: URL(string: news.image_link)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color.gray.opacity(0.3)
                }
                .frame(height: 220)
                .clipped()
                .cornerRadius(12)
                .padding(.horizontal)

                // 📰 Judul
                Text(news.title_news)
                    .font(.title3)
                    .bold()
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal)

                // 🌐 WebView
                WebView(urlString: news.link_news)
                    .frame(height: 500) // kamu bisa sesuaikan tinggi
                    .cornerRadius(8)
                    .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}



