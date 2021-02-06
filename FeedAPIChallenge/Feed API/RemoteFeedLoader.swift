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
		client.get(from: url) { clientResult in
			do {
				let feed = try Self.process(clientResult)
				completion(.success(feed))
			} catch {
				completion(.failure(error))
			}
		}
	}
	
	private static func process(_ result: HTTPClient.Result) throws -> [FeedImage] {
		let OK_200 = 200
		
		switch result {
		case .failure:
			throw Error.connectivity
		case let .success((data, response)):
			switch response.statusCode {
			case OK_200:
				return try decodeFeed(from: data)
			default:
				throw Error.invalidData
			}
		}
	}
	
	private static func decodeFeed(from data: Data) throws -> [FeedImage] {
		do {
			_ = try JSONSerialization.jsonObject(with: data)
			return []
		} catch {
			throw Error.invalidData
		}
	}
}
