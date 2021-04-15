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
		client.get(from: url) { result in
			switch result {
			case let .success((data, response)):
				completion(RemoteFeedItemsMapper.map(data, from: response))
			case .failure:
				completion(.failure(Error.connectivity))
			}
		}
	}
}

private struct RemoteFeedItemsMapper {
	struct Root: Decodable {
		let items: [Item]
	}

	struct Item: Decodable {
		enum CodingKey: String {
			case id = "image_id"
			case desc = "image_desc"
			case loc = "image_loc"
			case url = "image_url"
		}

		let id: UUID
		let desc: String?
		let loc: String?
		let url: URL
	}

	static func map(_ data: Data, from response: HTTPURLResponse) -> FeedLoader.Result {
		guard response.statusCode == 200,
		      (try? JSONDecoder().decode(Root.self, from: data)) != nil
		else {
			return .failure(RemoteFeedLoader.Error.invalidData)
		}
		return .success([])
	}
}
