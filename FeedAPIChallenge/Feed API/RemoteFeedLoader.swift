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
	
	private struct Items: Decodable {
		let items: [Item]
	}
	
	private struct Item: Decodable {
		public let image_id: UUID
		public let image_desc: String?
		public let image_loc: String?
		public let image_url: URL
	}
	
	public init(url: URL, client: HTTPClient) {
		self.url = url
		self.client = client
	}
	
	public func load(completion: @escaping (FeedLoader.Result) -> Void) {
		client.get(from: url, completion: { result in
			switch result {
			case let .success((data, response)):
				if response.statusCode == 200, let _ = try? JSONDecoder().decode(Items.self, from: data) {
					completion(.success([]))
				} else {
					completion(.failure(Error.invalidData))
				}
			case .failure:
				completion(.failure(Error.connectivity))
			}
		})
	}
}
