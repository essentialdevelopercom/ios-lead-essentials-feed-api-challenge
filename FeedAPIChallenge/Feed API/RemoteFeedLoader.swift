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
		self.client.get(from: self.url) { [weak self] result in
			guard self != nil else { return }
			switch result {
			case .failure:
				completion(.failure(Error.connectivity))
			case let .success((data, response)):
				let result = FeedImageMapper.result(from: data, response: response)
				completion(result)
			}
		}
	}
}

private struct FeedImageMapper {
	private static let HTTP_OK = 200

	static func result(from data: Data, response: HTTPURLResponse) -> FeedLoader.Result {
		guard response.statusCode == Self.HTTP_OK
		else { return .failure(RemoteFeedLoader.Error.invalidData) }

		do {
			let jsonRoot = try JSONDecoder.init().decode(JSONRoot.self, from: data)
			let images = jsonRoot.items.map { FeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }
			return .success(images)
		} catch {
			return .failure(RemoteFeedLoader.Error.invalidData)
		}
	}

	private struct JSONRoot: Decodable {
		let items: [FeedImageJSONObject]
	}

	private struct FeedImageJSONObject: Decodable {
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
}
