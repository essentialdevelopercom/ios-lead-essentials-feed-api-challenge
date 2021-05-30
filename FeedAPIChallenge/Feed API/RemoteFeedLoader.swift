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
		let items: [ImageItem]
		var images: [FeedImage] {
			return items.map { $0.feedImage }
		}
	}

	private struct ImageItem: Decodable {
		let image_id: UUID
		let image_description: String?
		let image_location: String?
		let image_URL: URL

		var feedImage: FeedImage {
			return FeedImage(id: image_id, description: image_description, location: image_location, url: image_URL)
		}
	}

	public func load(completion: @escaping (FeedLoader.Result) -> Void) {
		client.get(from: url, completion: { result in
			switch result {
			case .failure:
				completion(.failure(Error.connectivity))
			case let .success((data, response)):
				if response.statusCode != 200 {
					completion(.failure(Error.invalidData))
				} else {
					guard let root = try? JSONDecoder().decode(Root.self, from: data) else {
						return completion(.failure(Error.invalidData))
					}
					completion(.success(root.images))
				}
			}
		})
	}
}
