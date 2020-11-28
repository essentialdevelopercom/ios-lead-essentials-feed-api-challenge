//
//  Copyright © 2018 Essential Developer. All rights reserved.
//

import Foundation

struct RemoteFeedImages: Codable {
	let items: [RemoteFeedImage]
}

struct RemoteFeedImage: Codable {
	let image_id: UUID
	let image_desc: String?
	let image_loc: String?
	let image_url: String
}

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
		client.get(from: url) { (result) in
			switch result {
			case .failure(_):
				completion(.failure(Error.connectivity))
			case let .success((data, response)):
				switch response.statusCode {
				case 200:
					do {
						let remoteFeedImages = try JSONDecoder().decode(RemoteFeedImages.self, from: data)
						let feedImages: [FeedImage] = remoteFeedImages.items.compactMap(RemoteFeedLoader.convertToLocalFeedImage)
						completion(.success(feedImages))
					} catch {
						completion(.failure(Error.invalidData))
					}
				default:
					completion(.failure(Error.invalidData))
				}
			}
		}
	}
	
	private static func convertToLocalFeedImage(remoteFeedImage: RemoteFeedImage) -> FeedImage? {
		guard let imageUrl = URL(string: remoteFeedImage.image_url) else { return nil }
		return FeedImage(id: remoteFeedImage.image_id, description: remoteFeedImage.image_desc, location: remoteFeedImage.image_loc, url: imageUrl)
	}
}
