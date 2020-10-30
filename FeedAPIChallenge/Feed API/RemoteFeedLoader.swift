//
//  Copyright © 2018 Essential Developer. All rights reserved.
//

import Foundation

public final class RemoteFeedLoader: FeedLoader {
	private let url: URL
	private let client: HTTPClient
	
	public enum Error: Swift.Error {
		case connectivity
		case invalidData
	}
		
	public init(url: URL, client: HTTPClient) {
		self.url = url
		self.client = client
	}
	
	public func load(completion: @escaping (FeedLoader.Result) -> Void) {
//        client.get(from: url) { _ in
//            completion(.failure(Error.connectivity))
            
//        client.get(from: url) { result in
//            switch result {
//            case let .success(_, response):
//                if response.statusCode != 200 {
//                    completion(.failure(RemoteFeedLoader.Error.invalidData))
//                }
//            case .failure:
//                completion(.failure(RemoteFeedLoader.Error.connectivity))
//            }
//        }
        client.get(from: url) { [weak self] result in
            guard let self = self else { return }
            self.mapCompleteResult(result, completion: completion)
        }
    }
    
    private func mapCompleteResult(_ result: Result<(Data, HTTPURLResponse), Swift.Error>, completion: @escaping (FeedLoader.Result) -> Void) {
        switch result {
        case let .success(data, response):
//            if response.statusCode != 200 {
//                completion(.failure(RemoteFeedLoader.Error.invalidData))
//            } else if !JSONSerialization.isValidJSONObject(data) {
//                completion(.failure(RemoteFeedLoader.Error.invalidData))
//            }
            completion(FeedImageMapper.map(data, from: response))
        case .failure:
            completion(.failure(RemoteFeedLoader.Error.connectivity))
        }
    }
    
    class FeedImageMapper {
        private static var ACK200: Int { 200 }
        private struct Root: Decodable {
            let items: [Item]
            
            var feedImages: [FeedImage] {
                items.map(\.feedImage)
            }
        }
        
        private struct Item: Decodable {
            let id: UUID
            let description: String?
            let location: String?
            let image: URL
            
            var feedImage: FeedImage {
                FeedImage(id: id, description: description, location: location, url: image)
            }
        }
        
        static func map(_ data: Data, from response: HTTPURLResponse) -> FeedLoader.Result {
            guard response.statusCode == ACK200,
                  let root = try? JSONDecoder().decode(Root.self, from: data) else {
                return .failure(RemoteFeedLoader.Error.invalidData)
            }
            
            return .success(root.feedImages)
        }
    }
}
