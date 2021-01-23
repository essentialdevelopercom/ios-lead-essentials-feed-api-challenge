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
				case let .success((data,response)):
					if response.statusCode == 200, let _ = try? JSONSerialization.jsonObject(with: data) {
						do {
							let root = try JSONDecoder().decode(Root.self, from: data)
							completion(.success(root.feedImages))
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
}

struct Root: Decodable {

	let items: [Image]
	
	var feedImages: [FeedImage] {
		return items.map {
			FeedImage(id: $0.image_id
					  , description: $0.image_desc
					  , location: $0.image_loc
					  , url: $0.image_url)
		}
	}
}

struct Image: Decodable {
	let image_id: UUID
	let image_desc: String?
	let image_loc: String?
	let image_url: URL
}
