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
				if let images = try? FeedImagesMapper.map(data: data, response: response) {
					completion(.success(images))
				} else {
					completion(.failure(Error.invalidData))
				}
			case .failure:
				completion(.failure(Error.connectivity))
			}
		}
	}
}

private class FeedImagesMapper {
	private struct Root: Decodable {
		let items: [RemoteFeedImage]
	}

	private struct RemoteFeedImage: Decodable {
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

		var image: FeedImage {
			return FeedImage(id: id, description: description, location: location, url: url)
		}
	}

	static func map(data: Data, response: HTTPURLResponse) throws ->  [FeedImage] {
		guard response.statusCode == 200,
			  let root = try? JSONDecoder().decode(FeedImagesMapper.Root.self, from: data) else  {
			throw RemoteFeedLoader.Error.invalidData
		}
		return root.items.map { $0.image }
	}
}

