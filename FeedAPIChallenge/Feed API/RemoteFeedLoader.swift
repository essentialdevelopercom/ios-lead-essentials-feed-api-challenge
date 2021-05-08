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
			guard let _ = self else { return }
			switch result {
			case .failure(_):
				completion(.failure(Error.connectivity))
			case let .success((data, httpResponse)):
				do {
					let images = try RemoteData.map(data, from: httpResponse)
					completion(.success(images))
				} catch {
					completion(.failure(Error.invalidData))
				}
			}
		}
	}

	private final class RemoteData {
		private class Root: Decodable {
			private let items: [RemoteFeedItem]

			struct RemoteFeedItem: Decodable {
				let id: UUID
				let description: String?
				let location: String?
				let url: URL

				enum CodingKeys: String, CodingKey {
					case id = "image_id"
					case description = "image_desc"
					case location = "image_loc"
					case url = "image_url"
				}
			}

			var images: [FeedImage] {
				items.map { FeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }
			}
		}

		public static func map(_ data: Data, from response: HTTPURLResponse) throws -> [FeedImage] {
			guard response.statusCode == 200, let root = try? JSONDecoder().decode(Root.self, from: data) else {
				throw Error.invalidData
			}

			return root.images
		}
	}
}
