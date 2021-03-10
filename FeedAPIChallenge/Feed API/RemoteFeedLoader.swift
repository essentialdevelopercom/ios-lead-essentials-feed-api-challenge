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
			case .success((let data, let response)):
				if response.statusCode != 200 {
					completion(.failure(Error.invalidData))
				} else {
					if let _ = try? JSONDecoder().decode(Root.self, from: data) {
						return
					} else {
						completion(.failure(Error.invalidData))
					}
				}
			case .failure:
				completion(.failure(Error.connectivity))
			}
		}
	}
}

struct Root: Decodable {
	
	var images: [FeedImage] {
		items.map { $0.feedImage }
	}
	
	var items: [Image]
	
	struct Image: Decodable {
		var image_id: UUID
		var image_desc: String?
		var image_loc: String?
		var image_url: URL
		var feedImage: FeedImage {
			return FeedImage(
				id: self.image_id,
				description: self.image_desc,
				location: self.image_loc,
				url: self.image_url)
		}
	}
	
}
