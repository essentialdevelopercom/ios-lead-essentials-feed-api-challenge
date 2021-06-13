//
//  Copyright © 2018 Essential Developer. All rights reserved.
//

import Foundation

private struct RemoteImage: Decodable {
	let image_id: UUID
	let image_desc: String?
	let image_loc: String?
	let image_url: URL
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
		client.get(from: url) { result in
			switch result {
			case let .success((data, response)):
				guard response.statusCode == 200 else {
					completion(.failure(Error.invalidData))
					return
				}

				do {
					let _ = try JSONDecoder().decode([RemoteImage].self, from: data)
				} catch {
					completion(.failure(Error.invalidData))
				}

			case .failure(_):
				completion(.failure(Error.connectivity))
			}
		}
	}
}
