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
            case let .success((data, response)):
                if response.statusCode != 200 {
                    completion(.failure(Error.invalidData))
                } else if let root = try? JSONDecoder().decode(Root.self, from: data) {
                    completion(.success(root.items.map { $0.item }))
                } else {
                    completion(.failure(Error.invalidData))
                }
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }
}

struct Root: Decodable {
    let items: [Item]
}

struct Item: Decodable {
    public let id: UUID
    public let description: String?
    public let location: String?
    public let url: URL

    private enum CodingKeys: String, CodingKey {
        case id = "image_id"
        case description = "image_desc"
        case location = "image_loc"
        case url = "image_url"
    }

    var item: FeedImage {
        return FeedImage(id: id, description: description, location: location, url: url)
    }
}
