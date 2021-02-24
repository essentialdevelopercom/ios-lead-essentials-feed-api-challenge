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
	
	private static let OK_200 = 200
	private typealias DataAndResponse = (data: Data, response: HTTPURLResponse)
	
	public func load(completion: @escaping (FeedLoader.Result) -> Void) {
		client.get(from: url) { result in
			switch result {
			case .failure:
				completion(.failure(Error.connectivity))
			case .success(let success as DataAndResponse):
				if success.response.statusCode == RemoteFeedLoader.OK_200,
					(try? JSONDecoder().decode(Root.self, from: success.data)) != nil {
					completion(.success([]))
				} else {
					completion(.failure(Error.invalidData))
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
}
