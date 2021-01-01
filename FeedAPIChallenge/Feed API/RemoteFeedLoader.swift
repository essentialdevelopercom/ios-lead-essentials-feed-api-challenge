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
			case .success((let data, let response)):
				guard response.statusCode == 200, let _ = try? JSONDecoder().decode(Item.self, from: data) else {
					return completion(.failure(Error.invalidData))
				}
				
				break
			case .failure(_):
				completion(.failure(Error.connectivity))
				break
			}
		}
	}
	
	private struct Item: Decodable {
		var image_id: String
		var image_desc: String?
		var image_loc: String?
		var image_url: String
	}
}
