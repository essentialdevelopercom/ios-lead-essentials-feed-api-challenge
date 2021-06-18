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
			case .success((let data, let httpURLResponse)):
				if httpURLResponse.statusCode != 200 {
					completion(.failure(RemoteFeedLoader.Error.invalidData))
				} else if let _ = try? JSONDecoder().decode(RemoteFeedImageResponse.self, from: data) {
					completion(.success([]))
				} else {
					completion(.failure(RemoteFeedLoader.Error.invalidData))
				}
			case .failure(_):
				completion(.failure(RemoteFeedLoader.Error.connectivity))
			}
		}
	}

	private static func parse(data: Data) -> [RemoteFeedImage]? {
		guard let parsedResponse = try? JSONDecoder().decode(RemoteFeedImageResponse.self, from: data) else {
			return nil
		}
		return parsedResponse.items
	}
}
