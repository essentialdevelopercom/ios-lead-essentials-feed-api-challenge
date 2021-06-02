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
			completion(Swift.Result { try Self.mapClientResult(result) })
		}
	}

	private static func mapClientResult(_ clientResult: HTTPClient.Result) throws -> [FeedImage] {
		switch clientResult {
		case .failure:
			throw Error.connectivity
		case .success((let data, let httpResponse)):
			guard httpResponse.statusCode == 200 else {
				throw Error.invalidData
			}
			do {
				let remoteItems = try JSONDecoder().decode(Items.self, from: data)
				return remoteItems.items.map { $0.makeEquivalentFeedImage() }
			} catch {
				throw Error.invalidData
			}
		}
	}

	private struct Items: Decodable {
		let items: [RemoteImage]
	}

	private struct RemoteImage: Decodable {
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

		func makeEquivalentFeedImage() -> FeedImage {
			FeedImage(id: id, description: description, location: location, url: url)
		}
	}
}
