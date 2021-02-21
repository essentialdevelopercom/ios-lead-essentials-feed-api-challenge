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
			case let .success((data, response)):
				let result = FeedItemsMapper.map(data, response)
				completion(result)
			case .failure:
				completion(.failure(Error.connectivity))
			}
		}
	}
}

struct Root: Decodable {
	var items: [Feed]
	var feedItems: [FeedImage] {
		return items.map { $0.toFeedImage() }
	}
	
	struct Feed: Decodable {
		var imageId: UUID
		var imageDesc: String?
		var imageLoc: String?
		var imageUrl: URL
		
		func toFeedImage() -> FeedImage {
			return FeedImage(id: imageId, description: imageDesc, location: imageLoc, url: imageUrl)
		}
	}
}
