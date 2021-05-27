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
			case let .success((data, response)) where response.statusCode == 200:
				let decoder = JSONDecoder()
				if (try? decoder.decode(Items.self, from: data)) != nil {
					completion(.success([]))
				} else {
					completion(.failure(RemoteFeedLoader.Error.invalidData))
				}
			case .failure:
				completion(.failure(RemoteFeedLoader.Error.connectivity))
			case .success((_, _)):
				completion(.failure(RemoteFeedLoader.Error.invalidData))
			}
		}
	}

	private class Items: Codable {
		var items: [FeedItem]
	}

	private class FeedItem: Codable {
		var image_id: String
		var image_desc: String?
		var image_loc: String?
		var image_url: URL
	}
}
