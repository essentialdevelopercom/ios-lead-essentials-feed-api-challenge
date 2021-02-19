//
//  Copyright © 2018 Essential Developer. All rights reserved.
//

import Foundation

public final class RemoteFeedLoader: FeedLoader {
	struct Root: Decodable {
		let items: [Image]

		var feedImages: [FeedImage] {
			items.map { $0.feedImage }
		}
	}

	struct Image: Decodable {
		let imageId: UUID
		let imageDesc: String?
		let imageLoc: String?
		let imageUrl: URL

		var feedImage: FeedImage {
			FeedImage(id: imageId, description: imageDesc, location: imageLoc, url: imageUrl)
		}
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
			case .failure:
				completion(.failure(Error.connectivity))
			case let .success((data, response)):
				guard response.statusCode == 200 else {
					completion(.failure(Error.invalidData))
					return
				}
				let decoder = JSONDecoder()
				decoder.keyDecodingStrategy = .convertFromSnakeCase
				guard let images = try? decoder.decode(Root.self, from: data) else {
					completion(.failure(Error.invalidData))
					return
				}
				completion(.success(images.feedImages))
			}
		}
	}
}
