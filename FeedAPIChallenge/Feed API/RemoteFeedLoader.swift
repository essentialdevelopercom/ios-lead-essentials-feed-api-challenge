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
		client.get(from: url) { (result) in
			switch result {
			case .success((let data, let response)):
				completion(FeedMapper.map(data, response: response))
			case .failure:
				completion(.failure(Error.connectivity))
			}
		}
	}
}

private class FeedMapper {
	
	private struct Root: Decodable {
		let items: [FeedImageItem]
	}

	private struct FeedImageItem: Decodable {
		
		var image: FeedImage {
			return FeedImage(id: id, description: description, location: location, url: url)
		}
		
		let id: UUID
		let description: String?
		let location: String?
		let url: URL
		
		private enum CodingKeys: String, CodingKey {
			case id = "image_id"
			case description = "image_desc"
			case location = "image_loc"
			case url = "image_url"
		}
	}
	
	static func map(_ data: Data, response: HTTPURLResponse) ->  FeedLoader.Result{
		if let root = try? JSONDecoder().decode(Root.self, from: data), response.statusCode == 200 {
			return .success(root.items.map({ $0.image }))
		} else {
			return .failure(RemoteFeedLoader.Error.invalidData)
		}
	}
}
