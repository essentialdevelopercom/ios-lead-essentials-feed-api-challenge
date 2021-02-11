//
//  Copyright © 2018 Essential Developer. All rights reserved.
//

import Foundation

public final class RemoteFeedLoader: FeedLoader {
	private let url: URL
	private let client: HTTPClient
	
	private static var OK_200: Int { return 200 }
	
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
				guard response.statusCode == RemoteFeedLoader.OK_200 else {
					completion(.failure(Error.invalidData))
					return
				}
				do {
					let items = try JSONDecoder().decode(FeedImageMapper.self, from: data).imageItems
					completion(.success(items))
				} catch {
					completion(.failure(Error.invalidData))
				}
				
			case .failure:
				completion(.failure(Error.connectivity))
			}
		}
	}
}

internal final class FeedImageMapper: Decodable {
	private let items: [ImageItem]
	
	var imageItems: [FeedImage] {
		items.map { FeedImage(id: $0.id,
							  description: $0.description,
							  location: $0.location,
							  url: $0.url)}
	}
	
	private struct ImageItem: Decodable {
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
}
