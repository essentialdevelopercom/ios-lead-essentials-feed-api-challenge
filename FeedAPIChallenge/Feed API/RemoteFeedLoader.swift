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
    
    // MARK: - Structs
    private struct StatusCodeConstants {
        static var code200 = 200
    }
    
    private struct Root: Decodable {
        let items: [Item]
        
        var feed: [FeedImage] {
            return items.map { $0.item }
        }
    }

    private struct Item: Decodable {
        let image_id: UUID
        let image_desc: String?
        let image_loc: String?
        let image_url: URL
        
        var item: FeedImage {
            return FeedImage(id: image_id, description: image_desc, location: image_loc, url: image_url)
        }
    }
	
	public func load(completion: @escaping (FeedLoader.Result) -> Void) {
        client.get(from: url) { (result) in
            switch result {
            case let .success((data, response)):
                if response.statusCode != StatusCodeConstants.code200 {
                    completion(.failure(Error.invalidData))
                } else {
                    guard let _ = try? JSONDecoder().decode(Root.self, from: data) else {
                        completion(.failure(Error.invalidData))
                        return
                    }
                    completion(.success([]))
                }
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }
}
