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
		
		client.get(from: url) { result in
			switch result{
			case let .success((data, response)):
				let decoder = JSONDecoder()
				if  response.statusCode == 200 ,
					let items = try? decoder.decode(Entity.self, from: data){
					completion(.success(items.feed))
				} else {
					completion(.failure(Error.invalidData))
					break
				}
			case .failure:
				completion(.failure(Error.connectivity))
			}
		}
		
	}
}

private struct Entity: Decodable{
	let items:[Item]
	
	var feed: [FeedImage]{
		items.map{
			FeedImage(id: $0.id,
					  description: $0.description,
					  location: $0.location,
					  url: $0.url)
		}
	}
}

private struct Item: Decodable{
	let id: UUID
	let description: String?
	let location: String?
	let url: URL
	
	private enum CodingKeys:String, CodingKey{
		case id = "image_id"
		case description = "image_desc"
		case location = "image_loc"
		case url = "image_url"
	}
	
}
