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
	
	private static let OK_200 = 200
	private typealias DataAndResponse = (data: Data, response: HTTPURLResponse)
	
	public func load(completion: @escaping (FeedLoader.Result) -> Void) {
		client.get(from: url) { [weak self] result in
			guard self != nil else { return }
			switch result {
			case .failure:
				completion(.failure(Error.connectivity))
			case .success(let successInfo as DataAndResponse):
				completion(RemoteFeedLoader.map(successInfo: successInfo))
			}
		}
	}
	
	private static func map(successInfo: DataAndResponse) -> FeedLoader.Result {
		guard successInfo.response.statusCode == RemoteFeedLoader.OK_200,
			let root = try? JSONDecoder().decode(Root.self, from: successInfo.data) else {
			return .failure(Error.invalidData)
		}
		return .success(root.feedImages)
	}
	
	struct Root: Decodable {
		let items: [Item]
		
		var feedImages: [FeedImage] {
			return items.map{$0.feedImage}
		}
	}
	
	struct Item: Decodable {
		let image_id: UUID
		let image_desc: String?
		let image_loc: String?
		let image_url: URL
		
		var feedImage: FeedImage {
			return FeedImage(
				id: image_id,
				description: image_desc,
				location: image_loc,
				url: image_url
			)
		}
	}
}
