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
			switch (result) {
			case let .success((data, response)):
				guard response.statusCode == 200, let root = try? JSONDecoder().decode(Root.self, from: data) else {
					return completion(.failure(Error.invalidData))
				}

				let items = root.items.map { FeedImage(id: $0.image_id, description: $0.image_desc, location: $0.image_loc, url: $0.image_url) }

				completion(.success(items))
			case .failure:
				completion(.failure(Error.connectivity))
			}
		}
	}
}


private struct Root: Decodable {
	var items: [APIFeedImage]
}

private struct APIFeedImage: Decodable {
	var image_id: UUID
	var image_desc: String?
	var image_loc: String?
	var image_url: URL
}
