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
		client.get(from: url, completion: { result in
			switch result {
			case let .success((data, response)):
				completion(FeedItemsMapper.map(from: data, with: response))
			case .failure:
				completion(.failure(Error.connectivity))
			}

		})
	}
}

final class FeedItemsMapper {
	private struct Root: Decodable {
		private let items: [Item]

		var feeds: [FeedImage] {
			items.map({ $0.feed })
		}

		private struct Item: Decodable {
			let image_id: UUID
			let image_desc: String?
			let image_loc: String?
			let image_url: URL

			var feed: FeedImage {
				return FeedImage(
					id: image_id,
					description: image_desc,
					location: image_loc,
					url: image_url)
			}
		}
	}

	static func map(from data: Data, with response: HTTPURLResponse) -> FeedLoader.Result {
		guard response.statusCode == 200,
		      let root = try? JSONDecoder().decode(Root.self, from: data)
		else {
			return .failure(RemoteFeedLoader.Error.invalidData)
		}

		return .success(root.feeds)
	}
}
