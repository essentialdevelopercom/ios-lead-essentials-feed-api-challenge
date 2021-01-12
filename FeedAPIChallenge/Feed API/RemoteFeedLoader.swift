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
				if response.statusCode == RemoteFeedLoader.OK_200 {
					completion(strongSelf.mapFeedImage(data))
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
				items.forEach({dictionary in
					if let imageId = dictionary["image_id"] as? String,
					   let imageUrlString = dictionary["image_url"] as? String,
					   let uid = UUID(uuidString: imageId),
					   let imageUrl = URL(string: imageUrlString) {
						
						let imageDescription = dictionary["image_desc"] as? String
						let imageLocation = dictionary["image_loc"] as? String
						feedItems.append(FeedImage(id: uid,
										 description: imageDescription,
										 location: imageLocation,
										 url: imageUrl))
					}
				})
				return .success(feedItems)
			}
		} catch {
			return .failure(Error.invalidData)
		}
		return .failure(Error.invalidData)
	}
}
