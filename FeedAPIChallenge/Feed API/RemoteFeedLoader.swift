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
				switch response.statusCode {
				case 200:
					if let images = FeedImageMapper.feedImages(from: data) {
						completion(.success(images))
					} else {
						completion(.failure(Error.invalidData))
					}
				default:
					completion(.failure(Error.invalidData))
				}
			}
		}
	}
}

private struct FeedImageMapper {
	static func feedImages(from data: Data) -> [FeedImage]? {
		guard let root = try? JSONSerialization.jsonObject(with: data) as? [String: [[String: String]]],
			  let items = root["items"]
		else { return nil }

		return items.compactMap {
			guard let uuIdString = $0["image_id"],
				  let uuId = UUID(uuidString: uuIdString),
				  let urlString = $0["image_url"],
				  let url = URL(string: urlString)
			else { return nil }

			return FeedImage(id: uuId, description: $0["image_desc"], location: $0["image_loc"], url: url)
		}
	}
}
