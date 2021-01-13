//
//  Copyright © 2018 Essential Developer. All rights reserved.
//

import Foundation

public final class RemoteFeedLoader: FeedLoader {
	private let url: URL
	private let client: HTTPClient
	
	private struct root: Decodable{
		let items: [FeedImage]
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
		client.get(from: self.url){result in
			switch result{
			case .failure:
				completion(.failure(Error.connectivity))
			case let .success((data, response)):
				if response.statusCode != 200{
					return completion(.failure(Error.invalidData))
				}
				if let _ = try? JSONDecoder().decode(root.self, from: data){
					return completion(.success([]))
				}else{
					return completion(.failure(Error.invalidData))
				}
			}
		}
	}
}
