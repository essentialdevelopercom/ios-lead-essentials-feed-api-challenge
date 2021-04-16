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

	private static var OK_200 = 200

	public func load(completion: @escaping (FeedLoader.Result) -> Void) {
		client.get(from: url) { result in
			switch result {
			case let .success((data, response)):
				completion(RemoteFeedLoader.map(data: data, from: response))
			case .failure:
				completion(.failure(Error.connectivity))
			}
		}
	}

	struct Root: Codable {
		let items: [FeedImageItem]
	}

	struct FeedImageItem: Codable {
		let image_id: UUID
		let image_desc: String?
		let image_loc: String?
		let image_url: URL
	}

	private static func map(data: Data, from response: HTTPURLResponse) -> FeedLoader.Result {
		guard response.statusCode == RemoteFeedLoader.OK_200,
		      let _ = try? JSONDecoder().decode(Root.self, from: data) else {
			return .failure(Error.invalidData)
		}

		return .success([])
	}
}
