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
				guard response.statusCode == 200,
				      let data = try? JSONDecoder().decode(Root.self, from: data) else {
					completion(.failure(Error.invalidData))
					return
				}
				completion(.success(data.feed))
			case .failure:
				completion(.failure(Error.connectivity))
			}
		}
	}

	private struct Root: Decodable {
		private let items: [FeedItem]

		var feed: [FeedImage] {
			return items.map { $0.item }
		}
	}

	private struct FeedItem: Decodable {
		private let id: UUID
		private let description: String?
		private let location: String?
		private let url: URL

		var item: FeedImage {
			FeedImage(id: id, description: description, location: location, url: url)
		}

		enum CodingKeys: String, CodingKey {
			case id = "image_id"
			case description = "image_desc"
			case location = "image_loc"
			case url = "image_url"
		}
	}
}
