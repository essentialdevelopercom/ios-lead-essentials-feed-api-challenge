//
//  Copyright © 2018 Essential Developer. All rights reserved.
//

import Foundation

public final class RemoteFeedLoader: FeedLoader {
	private let url: URL
	private let client: HTTPClient
	private let OK_200 = 200

	public enum Error: Swift.Error {
		case connectivity
		case invalidData
	}

	public init(url: URL, client: HTTPClient) {
		self.url = url
		self.client = client
	}

	public func load(completion: @escaping (FeedLoader.Result) -> Void) {
		client.get(from: url) { [unowned self] result in
			switch result {
			case .success((let data, let response)):
				guard response.statusCode == self.OK_200,
					  let _ = try? JSONDecoder().decode(Root.self, from: data) else {
					completion(.failure(RemoteFeedLoader.Error.invalidData))
					return
				}
			case .failure(_):
				completion(.failure(RemoteFeedLoader.Error.connectivity))
			}
		}
	}
}

struct Root: Decodable {
	let items: [FeedImageResponseItem]
}

struct FeedImageResponseItem: Decodable {
	public let image_id: UUID
	public let image_desc: String?
	public let image_loc: String?
	public let image_url: URL
}
