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
			guard let _ = self else { return } // Even if I didn't use `self`, The use of `FeedImageMapper` did a completion handler...
			switch result {
			case .success(let (data, response)):
				do {
					let items = try FeedImageMapper.map(data, response)
					completion(.success(items))
				} catch {
					completion(.failure(Error.invalidData))
				}
				break
			case .failure(_):
				completion(.failure(Error.connectivity))
			}
		}
	}
}

private class FeedImageMapper {
	private struct FeedImageRoot: Decodable {
		var items: [FeedImageDTO]
	}
	
	private struct FeedImageDTO: Decodable {
		var image_id: UUID
		var image_desc: String?
		var image_loc: String?
		var image_url: URL
		
		var item: FeedImage {
			return FeedImage(id: image_id, description: image_desc, location: image_loc, url: image_url)
		}
	}
	
	static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [FeedImage] {
		guard response.statusCode == 200 else {
			throw RemoteFeedLoader.Error.invalidData
		}
		return try JSONDecoder().decode(FeedImageRoot.self, from: data).items.map({ $0.item })
	}
}
