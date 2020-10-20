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
        client.get(from: url) { result in
            switch result {
            case .failure:
                completion(.failure(RemoteFeedLoader.Error.connectivity))
            case let .success((data, response)):
                if response.statusCode == 200, let itemsRoot = try? JSONDecoder().decode(Root.self, from: data) {
                    completion(.success(itemsRoot.items.map { $0.feedImage }))
                } else {
                    completion(.failure(RemoteFeedLoader.Error.invalidData))
                }
            }
        }
    }
}

private struct Root: Decodable {
    
    struct ImageItem: Decodable {
        let id: UUID
        let description: String?
        let location: String?
        let imageURL: URL
        
        enum CodingKeys: String, CodingKey {
            case id = "image_id"
            case description = "image_desc"
            case location = "image_loc"
            case imageURL = "image_url"
        }
        
        var feedImage: FeedImage {
            return FeedImage(id: id, description: description, location: location, url: imageURL)
        }
    }
    
    var items: [ImageItem]
    
}


