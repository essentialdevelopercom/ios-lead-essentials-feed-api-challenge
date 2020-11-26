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
            case .failure:
                completion(.failure(Error.connectivity))
            case let .success((data, response)):
                if response.statusCode == 200, let feedItems = try? JSONDecoder().decode(Root.self, from: data) {
                    let feedImages: [FeedImage] = feedItems.items.map { Self.map(feedItem: $0) }
                    completion(.success(feedImages))
                } else {
                    completion(.failure(Error.invalidData))
                }
            }
        }
    }
    
    private static func map(feedItem: RemoteFeedImage) -> FeedImage {
        return FeedImage(
            id: feedItem.id,
            description: feedItem.description,
            location: feedItem.location,
            url: feedItem.url)
    }
}

struct Root: Decodable {
    let items: [RemoteFeedImage]
}

struct RemoteFeedImage {
    let id: UUID
    let description: String?
    let location: String?
    let url: URL
}

extension RemoteFeedImage: Decodable {
    private enum CodingKeys: String, CodingKey {
        case id = "image_id"
        case description = "image_desc"
        case location = "image_loc"
        case url = "image_url"
    }
}
