//
//  Copyright © 2018 Essential Developer. All rights reserved.
//

import Foundation

public final class RemoteFeedLoader: FeedLoader {
	private let url: URL
	private let client: HTTPClient
	private let mapper: FeedImageMapper

	public enum Error: Swift.Error {
		case connectivity
		case invalidData
	}

	public init(url: URL,
	            client: HTTPClient) {
		self.url = url
		self.client = client
		self.mapper = FeedImageJSONMapper()
	}

	public func load(completion: @escaping (FeedLoader.Result) -> Void) {
		client.get(from: url) { [weak self] result in
			guard let self = self else { return }
			switch result {
			case .success((let data, let response)):
				if response.statusCode == 200,
				   let _ = try? self.mapper.map(data: data) {
					return
				}
				completion(.failure(Error.invalidData))
			case .failure:
				completion(.failure(Error.connectivity))
			}
		}
	}
}
