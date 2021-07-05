//
//  Copyright © 2018 Essential Developer. All rights reserved.
//

import Foundation

public final class RemoteFeedLoader: FeedLoader {

	private struct ResponseRootEntity: Decodable {
		let items: [RemoteFeedImage]
	}

	private struct RemoteFeedImage: Decodable {
		let id: UUID
		let description: String?
		let location: String?
		let url: URL
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
		client.get(from: url) { httpClientResult in
			switch httpClientResult
			{
			case .success((let responseData, let httpResponse)):

				guard httpResponse.statusCode == 200 else {
					return completion(.failure(Error.invalidData))
				}

				do {
					let _ = try JSONDecoder().decode(ResponseRootEntity.self, from: responseData)
					completion(.success([]))
				} catch {
					completion(.failure(Error.invalidData))
				}
			case .failure:
				completion(.failure(Error.connectivity))
			}
		}
	}
}
