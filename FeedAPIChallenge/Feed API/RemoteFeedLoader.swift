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

	public enum Error: Swift.Error {
		case connectivity
		case invalidData
	}

	private let url: URL
	private let client: HTTPClient

	private var snakeCaseDecoder: JSONDecoder {
		let decoder = JSONDecoder()
		decoder.keyDecodingStrategy = .convertFromSnakeCase
		return decoder
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
			case let .success((data, response)):
				guard response.statusCode == 200,
					  let images = try? self?.snakeCaseDecoder.decode(Root.self, from: data) else {
					completion(.failure(Error.invalidData))
					return
				}
				completion(.success(images.feedImages))
			}
		}
	}
}
