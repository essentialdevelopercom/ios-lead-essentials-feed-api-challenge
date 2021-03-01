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
			guard let _ = self else { return }
			
			switch result {
			case let .success((data, response)):
				completion(RemoteFeedMapper.map(data, response))
			case .failure:
				completion(.failure(Error.connectivity))
			}
		}
	}
}

private struct RemoteFeedMapper {
	private struct Root: Decodable {
		private let items: [Image]
		
		var feedImages: [FeedImage] {
			items.map(\.feedImage)
		}
	}
	
	private struct Image: Decodable {
		private let id: UUID
		private let description: String?
		private let location: String?
		private let url: URL
		
		enum CodingKeys: String, CodingKey {
			case id = "image_id"
			case description = "image_desc"
			case location = "image_loc"
			case url = "image_url"
		}
		
		var feedImage: FeedImage {
			FeedImage(id: id, description: description, location: location, url: url)
		}
	}
	
	static func map(_ data: Data, _ response: HTTPURLResponse) -> FeedLoader.Result {
		guard response.statusCode == 200,
			  let root = try? JSONDecoder().decode(Root.self, from: data) else {
			return .failure(RemoteFeedLoader.Error.invalidData)
		}
		return .success(root.feedImages)
	}
}
