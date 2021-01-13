//
//  Copyright © 2018 Essential Developer. All rights reserved.
//

import Foundation

public final class RemoteFeedLoader: FeedLoader {
	private let url: URL
	private let client: HTTPClient
	
	private struct root: Decodable{
		let items: [Image]
		
		var feedItems: [FeedImage]{
			items.map {$0.feedImage}
		}
	}
	
	private struct Image: Decodable {
		let image_id: UUID
		let image_desc: String?
		let image_loc: String?
		let image_url: URL
		
		var feedImage: FeedImage {
			return FeedImage(id: image_id, description: image_desc, location: image_loc, url: image_url)
		}
	}
	
	public enum Error: Swift.Error {
		case connectivity
		case invalidData
	}
	
	public init(url: URL, client: HTTPClient) {
		self.url = url
		self.client = client
	}
	
	public func load(completion: @escaping (FeedLoader.Result) -> Void) {
		client.get(from: self.url){[weak self] result in
			guard let self = self else {return}
			switch result{
			case .failure:
				completion(.failure(Error.connectivity))
			case let .success((data, response)):
				completion(self.map(data, response))
			}
		}
	}
	
	private func map( _ data: Data, _ response: HTTPURLResponse) -> FeedLoader.Result {
		if response.statusCode == 200, let root = try? JSONDecoder().decode(root.self, from: data){
			return .success(root.feedItems)
		}else{
			return .failure(Error.invalidData)
		}
	}
}
