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
		client.get(from: url) { [weak self] result in
			guard self != nil else { return }
			switch result {
			case .success((let data, let response)):
				completion(DataMapper.map(data: data, response: response))
			case .failure:
				completion(.failure(Error.connectivity))
			}
		}
	}
}

private struct Root: Decodable {
	
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
			FeedImage(
				id: self.image_id,
				description: self.image_desc,
				location: self.image_loc,
				url: self.image_url
			)
		}
	}
	
}

struct DataMapper {
	static func map(data: Data, response: HTTPURLResponse) -> FeedLoader.Result {
		guard response.statusCode == 200, let root = try? JSONDecoder().decode(Root.self, from: data) else {
			return .failure(RemoteFeedLoader.Error.invalidData)
		}
		return .success(root.images)
	}
}
