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
		
		client.get(from: url) { [weak self] (result) in
			
			guard self != nil else {
				return
			}
			
			switch result {
			
			case .success((let data, let httpResponse)):
				
				guard httpResponse.statusCode == 200,
					  let responseData = try? JSONDecoder().decode(FeedImageItemsStruct.self, from: data) else {
					completion(.failure(Error.invalidData))
					return
				}
				
				completion(.success(responseData.items.map{$0.feedImage}))
				
			case .failure(_):
				
				completion(.failure(Error.connectivity))
				
			}
			
		}
	}
}

private struct FeedImageItemsStruct : Decodable {
	let items : [FeedImageStruct]
}

private struct FeedImageStruct : Decodable {
	let image_id : UUID
	let image_desc : String?
	let image_loc : String?
	let image_url : URL
	
	var feedImage : FeedImage {
		return FeedImage(id: image_id, description: image_desc, location: image_loc, url: image_url)
	}
}
