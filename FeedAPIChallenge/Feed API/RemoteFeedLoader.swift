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
		let image_id: UUID
		let image_desc: String
		let image_loc: String
		let image_url: URL
	}
	
	private struct Items: Codable {
		let items: [Item]
	}
	
	private func imageDecoder() -> JSONDecoder {
		JSONDecoder()
	}
	
	public func load(completion: @escaping (FeedLoader.Result) -> Void) {
		client.get(from: url) {[weak self] response in
			switch response {
			case let .success((data, response)):
				if response.statusCode == 200, let _ = try? self?.imageDecoder().decode(Items.self, from: data) {
					completion(.success([]))
				} else {
					completion(.failure(Error.invalidData))
				}
			case .failure:
				completion(.failure(Error.connectivity))
			}
		}
	}
}
