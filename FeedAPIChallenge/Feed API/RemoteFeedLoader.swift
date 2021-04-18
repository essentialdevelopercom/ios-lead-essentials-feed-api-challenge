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
		client.get(from: self.url) { (result) in
			switch result {
			case .failure(_):
				completion(.failure(Error.connectivity))
			case .success(let (_, httpResponse)):
				if httpResponse.statusCode == 200 {
					completion(.success([]))
				} else {
					completion(.failure(Error.invalidData))
				}
			}
		}
	}
}
