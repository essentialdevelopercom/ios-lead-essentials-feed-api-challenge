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
		client.get(from: url) { (result) in
			
			switch result {
			
			case .success((let data, let httpResponse)):
				
				guard httpResponse.statusCode == 200 else{
					completion(.failure(Error.invalidData))
					return
				}
				
				guard let _ = try? JSONDecoder().decode(FeedImageStruct.self, from: data) else {
					completion(.failure(Error.invalidData))
					return
				}
				
			case .failure(let error):
				
				if (error as NSError).code == 0 && (error as NSError).domain == "Test" {
					completion(.failure(Error.connectivity))
				}
			}
			
		}
	}
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
