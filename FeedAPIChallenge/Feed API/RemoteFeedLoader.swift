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
			switch result {
			case .failure:
				completion(.failure(Error.connectivity))
			case .success(let response):
				if response.1.statusCode != 200 {
					completion(.failure(Error.invalidData))
				} else {
					completion(FeedLoaderDecoder.feedLoaderItemsDecoder(with: response.0))
				}
			}
		}
	}
}

fileprivate struct FeedLoaderDecoder {
	private struct FeedLoaderResult: Decodable {
		let items: [FeedImageItem]
	}
	
	private struct FeedImageItem: Decodable {
		let image_id: String
		let image_desc: String?
		let image_loc: String?
		let image_url: String
		
		var item: FeedImage? {
			guard let url = URL(string: image_url), let uuid = UUID(uuidString: image_id) else {
				return nil
			}
			return FeedImage(id: uuid, description: image_desc, location: image_loc, url: url)
		}
	}
	
	static func feedLoaderItemsDecoder( with data: Data) -> Swift.Result<[FeedImage], Error> {
		do {
			let decoder = JSONDecoder()
			let feedLoader = try decoder.decode(FeedLoaderResult.self, from: data)
			return Swift.Result.success(feedLoader.items.compactMap {
				$0.item
			}
			)
		} catch {
			return Swift.Result.failure(RemoteFeedLoader.Error.invalidData)
		}
	}
}
