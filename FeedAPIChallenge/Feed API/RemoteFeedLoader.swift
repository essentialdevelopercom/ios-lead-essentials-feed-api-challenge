//
//  Copyright © 2018 Essential Developer. All rights reserved.
//

import Foundation

private struct Root: Decodable {
	let items: [FeedItem]
}

private struct FeedItem: Decodable {
	private let id: UUID
	private let description: String?
	private let location: String?
	private let url: URL
}

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
				guard let _ = try? JSONDecoder().decode(Root.self, from: data), response.statusCode == 200 else { completion(.failure(Error.invalidData)); return }
			case .failure: completion(.failure(Error.connectivity))
			}
		}
	}
}
