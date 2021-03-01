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
			case let .success((data, response)):
				completion(ResultMapper.map(data, response))
			case .failure:
				completion(.failure(Error.connectivity))
			}
		}
	}
}

private final class ResultMapper {
	
	static let CodeOK = 200
	
	private struct Root: Decodable {
		let items: [Item]
	}

	private struct Item: Decodable {
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
		
		var feedImage: FeedImage {
			return FeedImage(
				id: UUID(),
				description: nil,
				location: nil,
				url: URL(string: "http://another-url.com")!
			)
		}
	}
	
	static func map(_ data: Data, _ response: HTTPURLResponse) -> FeedLoader.Result {
		let statusCodeIsOK = response.statusCode == ResultMapper.CodeOK
		let root = try? JSONDecoder().decode(Root.self, from: data)
		if statusCodeIsOK, let root = root {
			return .success(root.items.map { $0.feedImage })
		} else {
			return .failure(RemoteFeedLoader.Error.invalidData)
		}
	}
}

