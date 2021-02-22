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
			switch result {
			case let .success((data, response)):
				if response.statusCode == 200, let _ = try? self?.map(data) {
				} else {
					completion(.failure(Error.invalidData))
				}
			default:
				completion(.failure(Error.connectivity))
			}
		}
	}
	
	private func map(_ data: Data) throws -> FeedLoader.Result {
		guard let _ = try? JSONDecoder().decode(Root.self, from: data) else {
			throw Error.invalidData
		}
		
		return .success([])
	}
	
	private struct Root: Decodable {
		var items: [Item]
		
		struct Item: Decodable {
			var id: UUID
			var description: String?
			var location: String?
			var image: URL
			
			enum CodingKeys: String, CodingKey {
				case id = "image_id"
				case description = "image_desc"
				case location = "image_loc"
				case image = "image_url"
			}
		}
	}
	
}
