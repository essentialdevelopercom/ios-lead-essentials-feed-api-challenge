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
            
            let OK_200 = 200
            
            switch result {
            case let .success((data, response)):
                if response.statusCode == OK_200, let root = try? JSONDecoder().decode(Root.self, from: data) {
                    completion(.success(root.items.map{ $0.feedImage }))
                } else {
                    completion(.failure(Error.invalidData))
                }
            case .failure(_):
                completion(.failure(Error.connectivity))
            }
            
        }
    }
}

private struct Root: Codable {
    let items: [RemoteFeedImage]
}

private struct RemoteFeedImage {
    let id: UUID
    let description: String?
    let location: String?
    let url: URL
    
    var feedImage: FeedImage {
        return FeedImage(id: id, description: description, location: location, url: url)
    }
}

extension RemoteFeedImage: Codable {
    private enum CodingKeys: String, CodingKey {
        case id = "image_id"
        case description = "image_desc"
        case location = "image_loc"
        case url = "image_url"
    }
}
