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
        client.get(from: url) { [weak self] result in
            guard self != nil else { return }
            
            switch result {
            case let .success((_, response)) where response.statusCode != 200 :
                completion(.failure(Error.invalidData))
            case let .success((data, _)):
                completion(RemoteFeedMapper.map(data))
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }
}

class RemoteFeedMapper {
    static func map(_ data: Data) -> FeedLoader.Result {
        do {
            let root = try JSONDecoder().decode(Root.self, from: data)
            return .success(root.feed)
        } catch {
            return .failure(RemoteFeedLoader.Error.invalidData)
        }
    }
    
    private struct Item: Decodable {
        let id: UUID
        let description: String?
        let location: String?
        let url: URL
        
        private enum CodingKeys: String, CodingKey {
            case id = "image_id"
            case description = "image_desc"
            case location = "image_loc"
            case url = "image_url"
        }
    }
    
    private struct Root: Decodable {
        private let items: [Item]
        
        var feed: [FeedImage] {
            return items.map {
                FeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url)
            }
        }
    }
}
