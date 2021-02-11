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
				case .failure:
					completion(.failure(RemoteFeedLoader.Error.connectivity))
				case .success((let data, let response)):
					return completion( FeedImageMapper.map(data, from: response))
			}
		}
	}
}

struct FeedImageMapper {
	private enum Constants {
		static let OK = 200
	}
	
	private struct Root: Decodable {
		let items: [Image]
		var feed: [FeedImage] {
			items.map { $0.image }
		}
	}
	
	private struct Image: Decodable {
		let id: UUID
		let description: String?
		let location: String?
		let imageURL: URL
		
		var image: FeedImage {
			.init(id: id, description: description, location: location, url: imageURL)
		}
		
		enum CodingKeys: String, CodingKey {
			case id = "image_id"
			case description = "image_desc"
			case location = "image_loc"
			case imageURL = "image_url"
		}
	}
	static func map(_ data: Data, from response: HTTPURLResponse) -> RemoteFeedLoader.Result {
		guard response.statusCode == Constants.OK,
			  let root = try? JSONDecoder().decode(Root.self, from: data) else {
			return .failure(RemoteFeedLoader.Error.invalidData)
		}
		
		return .success(root.feed)
	}
}
