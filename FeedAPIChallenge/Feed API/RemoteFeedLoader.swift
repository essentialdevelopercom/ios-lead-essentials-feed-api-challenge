//
//  Copyright © 2018 Essential Developer. All rights reserved.
//

import Foundation

public final class RemoteFeedLoader: FeedLoader {
	private struct Root: Decodable {
		let items: [ImageItem]
		var feed: [FeedImage] {
			return items.map { $0.feedImage }
		}
	}

	private struct ImageItem: Decodable {
		let image_id: UUID
		let image_desc: String?
		let image_loc: String?
		let image_url: URL

		var feedImage: FeedImage {
			return FeedImage(id: image_id, description: image_desc, location: image_loc, url: image_url)
		}
	}

	private let kStatusCode_200 = 200

	private func mapDataWith(_ data: Data, and response: HTTPURLResponse) -> FeedLoader.Result {
		guard response.statusCode == kStatusCode_200, let root = try? JSONDecoder().decode(Root.self, from: data) else {
			return .failure(Error.invalidData)
		}
		return .success(root.feed)
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
		client.get(from: url) { [weak self] result in
			guard let weakSelf = self else { return }
			switch result {
			case .failure:
				completion(.failure(Error.connectivity))
			case let .success((data, response)):
				completion(weakSelf.mapDataWith(data, and: response))
			}
		}
	}
}
