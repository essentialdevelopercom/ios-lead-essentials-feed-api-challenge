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

	private struct Root: Decodable {
		let items: [Item]

		var feedImages: [FeedImage] {
			return items.map { $0.feedImage }
		}
	}

	private struct Item: Decodable {
		let id: UUID
		let description: String?
		let location: String?
		let image: URL

		var feedImage: FeedImage {
			return FeedImage(id: id, description: description, location: location, url: image)
		}
	}

	public func load(completion: @escaping (FeedLoader.Result) -> Void) {
		client.get(from: url) { result in
			switch result {
			case let .success((data, response)):
				guard response.statusCode == 200,
				      let root = try? JSONDecoder().decode(Root.self, from: data)
				else {
					completion(.failure(Error.invalidData))
					return
				}
				completion(.success(root.feedImages))
			case .failure:
				completion(.failure(Error.connectivity))
			}
		}
	}
}
