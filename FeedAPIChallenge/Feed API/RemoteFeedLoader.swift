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
			self?.mapHTTPClientresult(result, completion)
		}
	}
	
	
	private func mapHTTPClientresult(_ result: HTTPClient.Result, _ completion: @escaping (FeedLoader.Result)-> Void) {
		switch result {
		case .success((let data, let httpResponse)):
			mapSuccessData(data, httpResponse, completion)
		case .failure(_):
			completion(.failure(Error.connectivity))
		}
		
	}
	
	private func mapSuccessData(_ data: Data, _ response:HTTPURLResponse, _ completion: (FeedLoader.Result)-> Void) {
		do {
			completion(.success(try FeedImageMapper.map(data, response)))
		} catch {
			completion(.failure(Error.invalidData))
		}
		
		
	}
}
