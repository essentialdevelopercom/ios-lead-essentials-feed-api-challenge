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
	
	private struct Item: Codable {
		let imageId: UUID
		let imageDesc: String?
		let imageLoc: String?
		let imageUrl: URL
		
		var feedImage: FeedImage {
			FeedImage(
				id: imageId,
				description: imageDesc,
				location: imageLoc,
				url: imageUrl
			)
		}
	}
	
	private struct Items: Codable {
		let items: [Item]
	}
	
	private func imageDecoder() -> JSONDecoder {
		let decoder = JSONDecoder()
		decoder.keyDecodingStrategy = .convertFromSnakeCase
		return decoder
	}
	
	public func load(completion: @escaping (FeedLoader.Result) -> Void) {
		client.get(from: url) {[weak self] response in
			switch response {
			case let .success((data, response)):
				if response.statusCode == 200  {
					if let items = try? self?.imageDecoder().decode(Items.self, from: data) {
						let feedImages = items.items.map(\.feedImage)
						completion(.success(feedImages))
					} else {
						completion(.failure(Error.invalidData))
					}
				} else {
					completion(.failure(Error.invalidData))
				}
			case .failure:
				completion(.failure(Error.connectivity))
			}
		}
	}
}
