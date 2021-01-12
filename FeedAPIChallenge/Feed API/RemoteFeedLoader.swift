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
		let decoder = JSONDecoder()
		guard let feedImages = try? decoder.decode(FeedItems.self, from: feedData).images else {
			return .failure(Error.invalidData)
		}
		return .success(feedImages)
	}
}
