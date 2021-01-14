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
	
	static let OK_200 = 200
	
	public func load(completion: @escaping (FeedLoader.Result) -> Void) {
		client.get(from: url) {[weak self] result in
			guard let strongSelf = self else { return }
			switch result {
			case .success(let feedData):
				let (data,response) = feedData
				if response.statusCode == RemoteFeedLoader.OK_200,
				   let data = try? strongSelf.mapFeedImage(data) {
					completion(.success(data))
					return
				}
				
				completion(.failure(Error.invalidData))
				
			case .failure(_):
				completion(.failure(Error.connectivity))
			}
		}
	}
}
	
extension RemoteFeedLoader {
	private struct FeedItemImage: Decodable {
		let image_id: UUID
		let image_desc: String?
		let image_loc: String?
		let image_url: URL
	}

	private struct Root : Decodable {
		let items: [FeedItemImage]
	}
	
	func mapFeedImage(_ feedData: Data) throws -> [FeedImage] {
		let decoder = JSONDecoder()
		let root = try decoder.decode(Root.self, from: feedData)
		return root.items.map({
				FeedImage(id: $0.image_id, description: $0.image_desc, location: $0.image_loc, url: $0.image_url)
		})
	}
}
