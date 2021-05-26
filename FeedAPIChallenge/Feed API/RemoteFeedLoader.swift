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
			completion(FeedItemsMapper.map(result: result))
		}
	}
}

struct FeedItemsMapper {
	static func map(result: Result<(Data, HTTPURLResponse), Error>) -> FeedLoader.Result {
		if case let .success((data, response)) = result, response.statusCode == 200 {
			return map(data: data, response: response)
		} else if case .success = result {
			return .failure(RemoteFeedLoader.Error.invalidData)
		} else {
			return .failure(RemoteFeedLoader.Error.connectivity)
		}
	}

	private static func map(data: Data, response: HTTPURLResponse) -> FeedLoader.Result {
		do {
			let remoteFeeditems = try JSONDecoder().decode(GetRemoteFeedImageResponseBody.self, from: data)
			let items = remoteFeeditems.items.map {
				FeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.imageUrl )
			}
			return .success(items)
		} catch {
			return .failure(RemoteFeedLoader.Error.invalidData)
		}
	}
}
