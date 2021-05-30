//
//  Copyright © 2018 Essential Developer. All rights reserved.
//

import Foundation

public final class RemoteFeedLoader: FeedLoader {
	private let url: URL
	private let client: HTTPClient
	static let OK_200: Int = 200
	
	public enum Error: Swift.Error {
		case connectivity
		case invalidData
	}
	
	public init(url: URL, client: HTTPClient) {
		self.url = url
		self.client = client
	}
	
	public func load(completion: @escaping (FeedLoader.Result) -> Void) {
		client.get(from: url, completion: { [ weak self ] result in
			guard self != nil else { return }
			switch result {
			case .failure:
				completion(.failure(Error.connectivity))
			case .success((let data, let response)):
				if response.statusCode != RemoteFeedLoader.OK_200 {
					completion(.failure(Error.invalidData))
				} else {
					let decoder = JSONDecoder()
					do {
						let root = try decoder.decode(Root.self, from: data)
						completion(.success(root.items.map { $0.feedImage }))
					} catch  {
						completion(.failure(Error.invalidData))
					}
				}
			}
		})
	}
	
	private struct Root : Decodable {
		let items: [ImageItem]
	}
	
	private struct ImageItem: Decodable {
		private let image_id: UUID
		private let image_desc: String?
		private let image_loc: String?
		private let image_url: URL
		
		var feedImage: FeedImage {
			return FeedImage(id: image_id, description: image_desc, location: image_loc, url: image_url)
		}
	}
}
