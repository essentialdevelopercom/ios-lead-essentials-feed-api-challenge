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
				if response.statusCode == 200,
				   let _ = try? JSONDecoder().decode(Root.self, from: data) {
					completion(.success([]))
				}else {
					completion(.failure(Error.invalidData))
				}
			case .failure:
				completion(.failure(Error.connectivity))
			}
		}
	}
}

private struct Root: Decodable {
	let items: [Item]
	
	var feedImages: [FeedImage] {
		 items.map { $0.feedImage }
	}
}

private struct Item: Decodable {
	let image_id: UUID
	let image_desc: String?
	let image_loc: String?
	let image_url: URL
	
	var feedImage: FeedImage {
		 FeedImage(id: image_id,
						 description: image_desc,
						 location: image_loc,
						 url: image_url)
	}
}

