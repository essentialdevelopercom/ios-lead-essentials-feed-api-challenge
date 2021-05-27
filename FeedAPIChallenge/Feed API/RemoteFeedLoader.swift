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

			guard let (data, response) = try? result.get() else {
				completion(.failure(RemoteFeedLoader.Error.connectivity))
				return
			}

			let decoder = JSONDecoder()

			if response.statusCode == 200, let images = try? decoder.decode(Items.self, from: data) {
				completion(.success(images.feedImages))
			} else {
				completion(.failure(RemoteFeedLoader.Error.invalidData))
			}
		}
	}

	private class Items: Codable {
		private var items: [FeedItem]

		var feedImages: [FeedImage] {
			return items.map { $0.feedImage }
		}
	}

	private class FeedItem: Codable {
		private var image_id: UUID
		private var image_desc: String?
		private var image_loc: String?
		private var image_url: URL

		var feedImage: FeedImage {
			return FeedImage(id: image_id, description: image_desc, location: image_loc, url: image_url)
		}
	}
}
