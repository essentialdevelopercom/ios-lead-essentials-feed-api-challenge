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

	private var OK_200: Int { return 200 }

	public func load(completion: @escaping (FeedLoader.Result) -> Void) {
		client.get(from: url) { [weak self] result in
			guard let self = self else { return }
			switch result {
			case let .success((data, httpURLResponse)):

				if httpURLResponse.statusCode != self.OK_200 {
					completion(.failure(Error.invalidData))
					return
				}

				do {
					let value = try JSONDecoder().decode(RemoteFeedItem.self, from: data)
					var feedImageList: [FeedImage] = []
					value.items.forEach { item in
						feedImageList.append(FeedImage(id: item.image_id, description: item.image_desc, location: item.image_loc, url: item.image_url))
					}
					completion(.success(feedImageList))

				} catch {
					completion(.failure(Error.invalidData))
					return
				}

			case .failure(_):
				completion(.failure(Error.connectivity))
			}
		}
	}

	private class RemoteFeedItem: Decodable {
		let items: [RemoteFeedImage]
		init(items: [RemoteFeedImage]) {
			self.items = items
		}
	}

	private class RemoteFeedImage: Decodable {
		let image_id: UUID
		let image_desc: String?
		let image_loc: String?
		let image_url: URL
	}
}
