//
//  Copyright © 2018 Essential Developer. All rights reserved.
//

import Foundation

public final class RemoteFeedLoader: FeedLoader {
	private let url: URL
	private let client: HTTPClient
	static let OK_200: Int = 200
	
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
			case .success((let data, let response)):
				if response.statusCode != RemoteFeedLoader.OK_200 {
					completion(.failure(Error.invalidData))
				} else {
					let decoder = JSONDecoder()
					do {
						let _ = try decoder.decode(Root.self, from: data)
						completion(.success([FeedImage]()))
					} catch  {
						completion(.failure(Error.invalidData))
					}
				}
			}
		})
	}
	
	private struct Root : Decodable {
		let items: [FeedImage]
	}
}
