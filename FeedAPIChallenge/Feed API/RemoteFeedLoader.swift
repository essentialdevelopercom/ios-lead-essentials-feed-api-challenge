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
		client.get(from: self.url) { (result) in
			switch result {
			case .failure(_):
				completion(.failure(Error.connectivity))
			case .success(let (data, httpResponse)):
				do {
					let feed = try FeedImageMapper.map(data, httpResponse)
					completion(.success(feed))
				} catch {
					completion(.failure(Error.invalidData))
				}
			}
		}
	}
}

private class FeedImageMapper {
	static private var OK_200 = 200
	
	private struct Root: Decodable {
		let items: [Items]
	}

	private struct Items: Decodable {
		let image_id: UUID
		let image_desc: String?
		let image_loc: String?
		let image_url: URL

		var feed: FeedImage {
			return FeedImage(id: image_id, description: image_desc, location: image_loc, url: image_url)
		}
	}

	static func map(_ data: Data, _ reponse: HTTPURLResponse) throws -> [FeedImage] {
		guard reponse.statusCode == OK_200 else {
			throw RemoteFeedLoader.Error.invalidData
		}
		let root = try JSONDecoder().decode(Root.self, from: data)
		return root.items.map { $0.feed }
	}
}
