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
		client.get(from: url) { [unowned self] result in
			switch result {
			
			case .failure:
				completion(.failure(Error.connectivity))
				
			case .success(let(data, response)):
				
				guard response.statusCode == 200,
					  let root = rootObject(from: data) else {
					completion(.failure(Error.invalidData))
					return
				}
				
				completion(.success(root.items))
			}
		}
	}
	
	private func rootObject(from data: Data) -> Root? {
		try? JSONDecoder().decode(Root.self, from: data)
	}
	
	private struct Root: Decodable {
		let items: [FeedImage]
	}
}
