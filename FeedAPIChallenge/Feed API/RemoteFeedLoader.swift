//
//  Copyright © 2018 Essential Developer. All rights reserved.
//

import Foundation

public final class RemoteFeedLoader: FeedLoader {
	private let url: URL
	private let client: HTTPClient
	private static let OK_200 = 200
	
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
			case .failure:
				completion(.failure(RemoteFeedLoader.Error.connectivity))
			case let .success((data , response)):
				guard response.statusCode == RemoteFeedLoader.OK_200, let root = try? JSONDecoder().decode(Root.self, from: data) else {
					return completion(.failure(RemoteFeedLoader.Error.invalidData))
				}
				completion(.success(root.feed))
			}
		}
    }
}

private struct Root: Decodable {
	private let items: [Image]
	var feed: [FeedImage] { items.map{ $0.feedImage } }
}

private struct Image: Decodable {
	private let id: UUID
	private let description: String?
	private let location: String?
	private let url: URL
	
	var feedImage: FeedImage {
		FeedImage(id: id, description: description, location: location, url: url)
	}
	
	private enum CodingKeys: String, CodingKey {
		case id = "image_id"
		case description = "image_desc"
		case location = "image_loc"
		case url = "image_url"
	}
}
