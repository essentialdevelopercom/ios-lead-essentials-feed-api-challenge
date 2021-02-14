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
		client.get(from: url, completion: { [weak self] (result) in
			guard self != nil else { return }
			switch result {
			case .failure(_):
				completion(.failure(Error.connectivity))
			case .success((let data, let response)):
				if response.statusCode == 200 {
					do {
						try self?.feedFromData(data)
					} catch  {
						completion(.failure(Error.invalidData))
					}
				} else {
					completion(.failure(Error.invalidData))
				}
			}
		})
	}
	
	private func feedFromData(_ data: Data) throws{
		let decoder = JSONDecoder()
		guard let _ = try? decoder.decode(RemoteFeed.self, from: data) else {
			throw Error.invalidData
		}
	}
}

private struct RemoteFeed: Decodable {
	
}
