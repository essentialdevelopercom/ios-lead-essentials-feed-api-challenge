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
		client.get(from: url) {[weak self] response in
			guard self != nil else { return }
			switch response {
			case let .success((data, response)):
				do {
					let items = try FeedImageMapper.map(data: data, response: response)
					completion(.success(items))
				} catch {
					completion(.failure(error))
				}
			case .failure:
				completion(.failure(Error.connectivity))
			}
		}
	}
}

private class FeedImageMapper {
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
	
	private static func imageDecoder() -> JSONDecoder {
		let decoder = JSONDecoder()
		decoder.keyDecodingStrategy = .convertFromSnakeCase
		return decoder
	}
	
	static func map(data: Data, response: HTTPURLResponse) throws -> [FeedImage] {
		if response.statusCode == 200  {
			if let items = try? imageDecoder().decode(Items.self, from: data) {
				return items.items.map(\.feedImage)
			} else {
				throw RemoteFeedLoader.Error.invalidData
			}
		} else {
			throw RemoteFeedLoader.Error.invalidData
		}
	}
}
