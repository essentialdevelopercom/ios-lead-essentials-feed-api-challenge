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
				if feedData.1.statusCode == RemoteFeedLoader.OK_200 {
					completion(strongSelf.mapFeedImage(feedData.0))
				}
				else {
					completion(.failure(Error.invalidData))
				}
				
			case .failure(_):
				completion(.failure(Error.connectivity))
			}
		}
	}
}

extension RemoteFeedLoader {
	func mapFeedImage(_ feedData: Data) -> FeedLoader.Result {
		do {
			if let json = try JSONSerialization.jsonObject(with: feedData, options: []) as? [String: Any],
			   let items = json["items"] as? [[String: Any]] {
				
				var feedItems: [FeedImage] = []
				items.forEach({
					if let image_id = $0["image_id"] as? String,
					   let image_url = $0["image_url"] as? String {
						let image_desc = $0["image_desc"] as? String
						let image_loc = $0["image_loc"] as? String
							
						
						feedItems.append(FeedImage(id: UUID(uuidString: image_id)!,
										 description: image_desc,
										 location: image_loc,
										 url: URL(string: image_url)!))
					}
				})
				return .success(feedItems)
			}
		} catch {
		}
		return .failure(Error.invalidData)
	}
}
