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
		client.get(from: url) { [weak self] result in
			completion(self?.map(result) ?? .failure(Error.invalidData))
		}
	}

	private func map(_ result: HTTPClient.Result) -> FeedLoader.Result {
		if let _ = try? result.get() {
			return .failure(Error.invalidData)
		} else {
			return .failure(Error.connectivity)
		}
	}
}
