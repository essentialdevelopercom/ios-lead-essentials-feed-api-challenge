//
//  Copyright © 2018 Essential Developer. All rights reserved.
//

import Foundation

public final class RemoteFeedLoader: FeedLoader {
	private let url: URL
	private let client: HTTPClient

	static var httpStatusCode200: Int {
		return 200
	}

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
			switch (result) {
			case let .success((data, response)):
				if let items = try? FeedImageMapper.map(data, response) {
					completion(.success(items))
				} else {
					completion(.failure(Error.invalidData))
				}
			case .failure:
				completion(.failure(Error.connectivity))
			}
		}
	}
}

private class FeedImageMapper {
	private struct Root: Decodable {
		let items: [Item]
	}

	private struct Item: Decodable {
		let id: UUID
		let description: String?
		let location: String?
		let image: URL

		var item: FeedImage {
			return FeedImage(id: id, description: description, location: location, url: image)
		}
	}

	static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [FeedImage] {
		guard response.statusCode == RemoteFeedLoader.httpStatusCode200 else {
			throw RemoteFeedLoader.Error.invalidData
		}
		let root = try JSONDecoder().decode(Root.self, from: data)
		return root.items.map { $0.item }
	}
}
