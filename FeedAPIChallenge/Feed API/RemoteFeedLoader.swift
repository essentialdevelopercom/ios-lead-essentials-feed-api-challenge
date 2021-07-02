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
			case let .success((data, httpURLResponse)):
				if let items = try? RemoteFeedImage.map(data, httpURLResponse) {
					completion(.success(items))
				} else {
					completion(.failure(Error.invalidData))
				}
			case .failure:
				completion(.failure(Error.connectivity))
			}
		}
	}

	private struct RemoteFeedItem: Decodable {
		let items: [RemoteFeedImage]
		init(items: [RemoteFeedImage]) {
			self.items = items
		}
	}

	private struct RemoteFeedImage: Decodable {
		let image_id: UUID
		let image_desc: String?
		let image_loc: String?
		let image_url: URL

		var feedImageItem: FeedImage {
			return FeedImage(id: image_id, description: image_desc, location: image_loc, url: image_url)
		}

		static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [FeedImage] {
			guard response.statusCode == 200 else {
				throw RemoteFeedLoader.Error.invalidData
			}
			let root = try JSONDecoder().decode(RemoteFeedItem.self, from: data)
			return root.items.map({ $0.feedImageItem })
		}
	}
}
