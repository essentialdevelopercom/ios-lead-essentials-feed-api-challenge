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

	enum Status: Int {
		case code_200 = 200
	}

	public init(url: URL, client: HTTPClient) {
		self.url = url
		self.client = client
	}

	public func load(completion: @escaping (FeedLoader.Result) -> Void) {
		client.get(from: url) { [weak self] result in

			guard let self = self else { return }

			switch result {
			case .success((let data, let response)):
				completion(self.mapData(data: data, response: response))
			case .failure(_):
				completion(.failure(Error.connectivity))
			}
		}
	}

	private func mapData(data: Data, response: HTTPURLResponse) -> FeedLoader.Result {
		guard response.statusCode == Status.code_200.rawValue,
		      let feedImageDecoded = try? JSONDecoder().decode(FeedImageMapper.self, from: data)
		else {
			return .failure(Error.invalidData)
		}

		return .success(feedImageDecoded.feedImage)
	}
}
