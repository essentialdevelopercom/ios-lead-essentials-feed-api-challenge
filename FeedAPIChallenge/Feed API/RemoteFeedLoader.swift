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

	private static let successCode = 200

	public func load(completion: @escaping (FeedLoader.Result) -> Void) {
		client.get(from: url) { [weak self] result in
			guard self != nil else { return }
			switch result {
			case let .success((data, response)):
				if response.statusCode == RemoteFeedLoader.successCode, let items = RemoteFeedImageMapper.map(data) {
					completion(.success(items))
				} else {
					completion(.failure(Error.invalidData))
				}
			case .failure:
				completion(.failure(Error.connectivity))
			}
		}
	}
}

private struct RemoteFeedImageMapper {
	private struct Items: Decodable {
		var items: [RemoteFeedImage]
	}

	static func map(_ data: Data) -> [FeedImage]? {
		let remoteItems = try? JSONDecoder().decode(Items.self, from: data)
		return remoteItems?.items.toFeedImages()
	}
}

private struct RemoteFeedImage: Decodable {
	let image_id: UUID
	let image_desc: String?
	let image_loc: String?
	let image_url: URL

	func toFeedImage() -> FeedImage {
		return FeedImage(id: image_id, description: image_desc, location: image_loc, url: image_url)
	}
}

private extension Array where Element == RemoteFeedImage {
	func toFeedImages() -> [FeedImage] {
		return map { $0.toFeedImage() }
	}
}
