//
//  Copyright © 2018 Essential Developer. All rights reserved.
//

import Foundation

private struct Root: Decodable {
	let items: [FeedItem]
}

private struct FeedItem: Decodable {
	private let id: UUID
	private let description: String?
	private let location: String?
	private let url: URL

	var feedImage: FeedImage {
		FeedImage(id: id, description: description, location: location, url: url)
	}

	enum CodingKeys: String, CodingKey {
		case id = "image_id"
		case description = "image_desc"
		case location = "image_loc"
		case url = "image_url"
	}
}

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
				guard let root = try? JSONDecoder().decode(Root.self, from: data), response.statusCode == 200 else { completion(.failure(Error.invalidData)); return }
				completion(.success(root.items.map { $0.feedImage }))
			case .failure: completion(.failure(Error.connectivity))
			}
		}
	}
}
