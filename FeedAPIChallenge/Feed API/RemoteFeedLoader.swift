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
				if response.statusCode == 200 {
					if let _ = try? JSONDecoder().decode(Root.self, from: data) {
						completion(FeedLoader.Result.success([]))
					} else {
						completion(FeedLoader.Result.failure(Error.invalidData))
					}
				} else {
					completion(FeedLoader.Result.failure(Error.invalidData))
				}
			case .failure(_):
				completion(FeedLoader.Result.failure(Error.connectivity))
			}
		}
	}
}

struct Root: Decodable {
	let items: [Item]
}

struct Item: Decodable {
	let image_id: String
	let image_desc: String?
	let image_loc: String?
	let image_url: String
}
