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
		client.get(from: url) { [weak self ]result in
			guard self != nil else { return }
			
			switch result {
			case let .success((data, response)):
				completion(FeedImageMapper.map(from: data, with: response))
			case .failure(_):
				completion(.failure(Error.connectivity))
			}
		}
	}
}

private struct FeedImageMapper {
	
	private struct Root: Codable {
		internal var items: [Item]
		internal var images: [FeedImage] {
			return items.compactMap({ $0.item })
		}
	}
	
	private struct Item: Codable {
		private let id: UUID
		private let description: String?
		private let location: String?
		private let url: URL
		
		internal var item: FeedImage {
			FeedImage(id: id, description: description, location: location, url: url)
		}
		
		private enum CodingKeys: String, CodingKey {
			case id = "image_id"
			case description = "image_desc"
			case location = "image_loc"
			case url = "image_url"
		}
	}
	
	internal static func map(from data: Data, with response: HTTPURLResponse) -> FeedLoader.Result {
		guard response.statusCode == 200,
			  let root = try? JSONDecoder().decode(Root.self, from: data) else {
			return .failure(RemoteFeedLoader.Error.invalidData)
		}
		
		return .success(root.images)
	}

}
