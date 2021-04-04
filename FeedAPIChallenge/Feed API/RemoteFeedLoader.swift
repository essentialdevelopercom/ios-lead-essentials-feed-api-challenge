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
			case let .success((data, response)):
				completion(FeedMapper.map(data, from: response))
			case .failure(_):
				completion(.failure(Error.connectivity))
			}
		}
	}
	
	// MARK: -
	
	private class FeedMapper {
		internal static func map(_ data: Data, from response: HTTPURLResponse) -> FeedLoader.Result {
			guard response.statusCode == 200, let feed = FeedDecoder.decode(data) else {
				return .failure(Error.invalidData)
			}
			return .success(feed)
		}
	}
	
	private class FeedDecoder {
		private struct Root: Decodable {
			let items: [Item]
			
			var feed: [FeedImage]  {
				return items.map { $0.image }
			}
		}
		
		private struct Item: Decodable {
			enum CodingKeys: String, CodingKey {
				case id = "image_id"
				case description = "image_desc"
				case location = "image_loc"
				case url = "image_url"
			}
			
			let id: UUID
			let description: String?
			let location: String?
			let url: URL
			
			var image: FeedImage {
				return FeedImage(
					id: id,
					description: description,
					location: location,
					url: url
				)
			}
		}
		
		internal static func decode(_ data: Data) -> [FeedImage]? {
			guard let root = try? JSONDecoder().decode(Root.self, from: data) else { return nil }
			return root.feed
		}
	}
	
}
