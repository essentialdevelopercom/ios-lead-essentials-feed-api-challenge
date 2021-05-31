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
			case .failure:
				completion(.failure(Error.connectivity))
			case let .success((data, response)):
				completion(FeedImageMapper.map(data: data, response: response))
			}
		})
	}
}

struct FeedImageMapper {
	struct Root: Decodable {
		var items: [FeedImageResult] = []

		struct FeedImageResult: Decodable {
			public let image_id: UUID
			public let image_desc: String?
			public let image_loc: String?
			public let image_url: URL
		}
	}

	static func map(data: Data, response: HTTPURLResponse) -> FeedLoader.Result {
		guard response.statusCode == 200, let _ = try? JSONDecoder().decode(Root.self, from: data) else {
			return .failure(RemoteFeedLoader.Error.invalidData)
		}
		return .success([])
	}
}
