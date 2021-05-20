//
//  Copyright © 2018 Essential Developer. All rights reserved.
//

import Foundation

public final class RemoteFeedLoader: FeedLoader {
	private let url: URL
	private let client: HTTPClient
	private let code_200 = 200

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

			guard let self = self else { return }

			switch result {
			case .success((let data, let response)):

				guard response.statusCode == self.code_200,
				      let feedImageDecoded = try? JSONDecoder().decode(FeedImageMapper.self, from: data)
				else {
					completion(.failure(Error.invalidData))
					return
				}

				completion(.success(feedImageDecoded.feedImage))

			case .failure(_):
				completion(.failure(Error.connectivity))
			}
		}
	}

	private struct FeedImageMapper: Decodable {
		let items: [Item]

		var feedImage: [FeedImage] {
			return items.map {
				FeedImage(id: $0.id,
				          description: $0.description,
				          location: $0.location,
				          url: $0.imageURL)
			}
		}
	}

	private struct Item: Decodable {
		let id: UUID
		let description: String?
		let location: String?
		let imageURL: URL

		enum CodingKeys: String, CodingKey {
			case id = "image_id"
			case description = "image_desc"
			case location = "image_loc"
			case imageURL = "image_url"
		}
	}
}
