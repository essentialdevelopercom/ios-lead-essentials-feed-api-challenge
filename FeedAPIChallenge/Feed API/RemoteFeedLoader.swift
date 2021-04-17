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
		client.get(from: url, completion: { [weak self] result in
			guard self != nil else { return }
			switch result {
			case .success((let data, let response)):
				guard response.statusCode == 200 else {
					completion(.failure(Error.invalidData))
					return
				}
				guard let root = try? JSONDecoder().decode(FeedImageMapper.Root.self, from: data) else {
					completion(.failure(Error.invalidData))
					return
				}
				completion(.success(root.feedImages))
			case .failure:
				completion(.failure(Error.connectivity))
			}
		})
	}
}

internal class FeedImageMapper {
	struct Root: Decodable {
		private let items: [FeedImageItem]

		var feedImages: [FeedImage] {
			items.map { $0.feedImage }
		}
	}

	private struct FeedImageItem: Decodable {
		let imageId: UUID
		let imageDesc: String?
		let imageLocation: String?
		let imageURL: URL

		var feedImage: FeedImage {
			return FeedImage(id: imageId, description: imageDesc, location: imageLocation, url: imageURL)
		}

		enum CodingKeys: String, CodingKey {
			case imageId = "image_id"
			case imageDesc = "image_desc"
			case imageLocation = "image_loc"
			case imageURL = "image_url"
		}
	}
}
