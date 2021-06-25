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
			guard self != nil else { return }
			switch result {
			case .failure:
				completion(.failure(Error.connectivity))
			case .success((let data, let httpResponse)):
				completion(FeedLoaderDecoder.decode(with: data, httpResponse: httpResponse))
			}
		}
	}
}

private extension RemoteFeedLoader {
	private struct FeedLoaderDecoder {
		private static let OK_200 = 200
		private struct RootRemoteResponse: Decodable {
			let items: [FeedImageItem]
		}

		private struct FeedImageItem: Decodable {
			private let image_id: UUID
			private let image_desc: String?
			private let image_loc: String?
			private let image_url: URL

			var item: FeedImage {
				FeedImage(id: image_id, description: image_desc, location: image_loc, url: image_url)
			}
		}

		static func decode(with data: Data, httpResponse: HTTPURLResponse) -> FeedLoader.Result {
			if httpResponse.statusCode != FeedLoaderDecoder.OK_200 {
				return FeedLoader.Result.failure(Error.invalidData)
			}
			let decoder = JSONDecoder()
			if let feedLoader = try? decoder.decode(RootRemoteResponse.self, from: data) {
				return FeedLoader.Result.success(feedLoader.items.map {
					$0.item
				})
			}
			return FeedLoader.Result.failure(RemoteFeedLoader.Error.invalidData)
		}
	}
}
