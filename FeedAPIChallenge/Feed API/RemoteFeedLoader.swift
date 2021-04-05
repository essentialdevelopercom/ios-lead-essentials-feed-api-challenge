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
		client.get(from: url) { [weak self] result in
			
			guard let _ = self else {return}
			
			switch result{
			case let .success((data, response)):
				if response.statusCode != 200 {
					completion(.failure(Error.invalidData))
				}else{
					let decoder = JSONDecoder()
					decoder.keyDecodingStrategy = .convertFromSnakeCase
					
					if let root = try? decoder.decode(Root.self, from: data) {
						completion(.success(root.feed))
					}else {
						completion(.failure(Error.invalidData))
					}
				}
			case .failure(_):
				completion(.failure(Error.connectivity)
				)
			}
		}
	}
}
