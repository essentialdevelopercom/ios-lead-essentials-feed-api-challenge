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
		client.get(from: url) { result in
			switch result {
			case let .success((data, response)):
				if response.statusCode == 200, let decodedResponse = try? JSONDecoder().decode(FeedResponse.self, from: data) {
					completion(.success(decodedResponse.items.map{ $0.feedImage() }))
				} else {
					completion(.failure(Error.invalidData))
				}
			case .failure:
				completion(.failure(Error.connectivity))
			}
		}
	}
	
	private struct FeedResponse: Decodable {
		let items: [FeedItem]
	}
	
	private struct FeedItem: Decodable {
		let id: UUID
		let description: String?
		let location: String?
		let url: URL
		
		enum CodingKeys: String, CodingKey {
			case id = "image_id"
			case url = "image_url"
			case description = "image_desc"
			case location = "image_loc"
		}
		
		func feedImage() -> FeedImage {
			FeedImage(id: id, description: description, location: location, url: url)
		}
	}
}
