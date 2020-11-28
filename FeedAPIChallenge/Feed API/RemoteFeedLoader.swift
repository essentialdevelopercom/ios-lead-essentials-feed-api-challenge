//
//  Copyright © 2018 Essential Developer. All rights reserved.
//

import Foundation

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
						let _ = try JSONDecoder().decode(RemoteFeedImage.self, from: data)
					} catch {
						completion(.failure(Error.invalidData))
					}
				default:
					completion(.failure(Error.invalidData))
				}
			}
		}
	}
}
