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
			guard let self = self else { return }
			completion(self.map(result))
		}
	}

	private func map(_ result: HTTPClient.Result) -> FeedLoader.Result {
		switch result {
		case .success(let result):
			if let items = try? FeedItemsMapper.map(result) {
				return .success(items)
			} else {
				return .failure(Error.invalidData)
			}
		case .failure:
			return .failure(Error.connectivity)
		}
	}
}

private final class FeedItemsMapper {
	
	private struct Root: Decodable {
		let items: [FeedItem]
	}

	private struct FeedItem: Decodable {
		let image_id: UUID
		let image_desc: String?
		let image_loc: String?
		let image_url: URL

		var feedImage: FeedImage {
			return FeedImage(id: image_id, description: image_desc, location: image_loc, url: image_url)
		}
	}

	static let successCode = 200

	static func map(_ result: (data: Data, response: HTTPURLResponse)) throws -> [FeedImage] {
		guard result.response.statusCode == successCode else {
			throw RemoteFeedLoader.Error.invalidData
		}
		let root = try JSONDecoder().decode(Root.self, from: result.data)
		return root.items.map { $0.feedImage }
	}
}
