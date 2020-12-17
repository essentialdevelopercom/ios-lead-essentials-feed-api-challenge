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
		client.get(
			from: url,
			completion: { result in
				switch result {
				case .success((let data, let response)):
					guard response.statusCode == 200 else {
						completion(.failure(Error.invalidData))
						return
					}

					guard let remoteFeedImageResponse = try? JSONDecoder().decode(RemoteFeedImageResponse.self, from: data) else {
						completion(.failure(Error.invalidData))
						return
					}

					completion(.success(remoteFeedImageResponse.feedImages))
				case .failure:
					completion(.failure(Error.connectivity))
				}
			}
		)
	}
}

private struct RemoteFeedImageResponse: Decodable {
	let items: [RemoteFeedImage]

	var feedImages: [FeedImage] {
		items.map { .init(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }
	}
}

private struct RemoteFeedImage: Decodable {
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
