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

	private struct Root: Decodable {
		let items: [RemoteFeedLoader.FeedItem]
	}

	private struct FeedItem: Decodable {
		let image_id: UUID
		let image_desc: String?
		let image_loc: String?
		let image_url: URL
	}

	private static let successCode = 200

	private func map(_ result: HTTPClient.Result) -> FeedLoader.Result {
		switch result {
		case .success(let result):
			if let items = try? map(result) {
				return .success(map(items))
			} else {
				return .failure(Error.invalidData)
			}
		case .failure:
			return .failure(Error.connectivity)
		}
	}

	private func map(_ result: (data: Data, response: HTTPURLResponse)) throws -> [FeedItem] {
		guard result.response.statusCode == RemoteFeedLoader.successCode else {
			throw RemoteFeedLoader.Error.invalidData
		}
		return try JSONDecoder().decode(Root.self, from: result.data).items
	}

	private func map(_ items: [RemoteFeedLoader.FeedItem]) -> [FeedImage] {
		return items.map { item -> FeedImage in
			return FeedImage(id: item.image_id, description: item.image_desc, location: item.image_loc, url: item.image_url)
		}
	}
}
