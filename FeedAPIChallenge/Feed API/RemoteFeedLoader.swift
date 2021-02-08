//
//  Copyright © 2018 Essential Developer. All rights reserved.
//

import Foundation

public final class RemoteFeedLoader: FeedLoader {
	private struct RemoteFeedImage: Decodable {
		let image_id: UUID
	}
	
	private struct Root: Decodable {
		let items: [RemoteFeedImage]
	}
	
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
			case let .success((_, response)) where !response.isOK:
				completion(.failure(Error.invalidData))
				
			case let .success((data, response)):
				completion(Self.map(data: data, response: response))
				
			case .failure:
				completion(.failure(Error.connectivity))
			}
		}
	}
}

// MARK: - Private
private extension RemoteFeedLoader {
	static func map(data: Data, response: HTTPURLResponse) -> FeedLoader.Result {
		do {
			_ = try JSONDecoder().decode(Root.self, from: data)
			return .success([])
		} catch {
			return .failure(Error.invalidData)
		}
	}
}

private extension HTTPURLResponse {
	var isOK: Bool { statusCode == 200 }
}
