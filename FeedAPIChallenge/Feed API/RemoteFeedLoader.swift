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
			guard let self = self else { return }
			
			switch result {
			case let .success((data, response)):
				completion(self.result(for: data, response: response))
			case .failure(_):
				completion(.failure(Error.connectivity))
			}
		}
	}
	
	private func result(for data: Data, response: HTTPURLResponse) -> FeedLoader.Result {
		guard response.statusCode == 200, let root = decode(data) else {
			return .failure(Error.invalidData)
		}
		return .success(root.feed)
	}
	
	private func decode(_ data: Data) -> Root? {
		return try? JSONDecoder().decode(Root.self, from: data)
	}
	
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
	
}
