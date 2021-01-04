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
			case .success(let data, let response):
				if response.statusCode == 200 {
					do {
						let root = try JSONDecoder().decode(Root.self, from: data)
						let feedImages = root.items.map { $0.toFeedImage() }
						completion(.success(feedImages))
					} catch {
						completion(.failure(Error.invalidData))
					}
				} else {
					completion(.failure(Error.invalidData))
				}
				
			case .failure:
				completion(.failure(Error.connectivity))
			}
		}
	}
	
	private struct Root: Decodable {
		var items: [Item]
	}
	
	private struct Item: Decodable {
		private let image_id: UUID
		private let image_desc: String?
		private let image_loc: String?
		private let image_url: URL
		
		func toFeedImage() -> FeedImage {
			return FeedImage(id: image_id, description: image_desc, location: image_loc, url: image_url)
		}
	
	}
}
