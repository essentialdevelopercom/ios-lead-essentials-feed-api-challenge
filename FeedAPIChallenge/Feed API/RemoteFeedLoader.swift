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
				if response.statusCode == 200, let root = try? JSONDecoder().decode(Root.self, from: data) {
					completion(.success(root.mapToFeedImages()))
				} else {
					completion(.failure(Error.invalidData))
				}
			default:
				completion(.failure(Error.connectivity))
			}
		}
	}

	private struct Root: Decodable {
		private let items: [ImageItem]

		private struct ImageItem: Decodable {
			let image_id: UUID
			let image_desc: String?
			let image_loc: String?
			let image_url: URL
		}

		func mapToFeedImages() -> [FeedImage] {
			var result = [FeedImage]()
			for item in items {
				let feedImage = FeedImage(id: item.image_id, description: item.image_desc, location: item.image_loc, url: item.image_url)
				result.append(feedImage)
			}
			return result
		}
	}
}
