//
//  Copyright © 2018 Essential Developer. All rights reserved.
//

import Foundation

public final class RemoteFeedLoader: FeedLoader {
	
	// MARK: Private properties
	private let url: URL
	private let client: HTTPClient
	
	private enum HTTPStatusCode {
		static var OK: Int { 200 }
	}
	
	// MARK: Public errors
	public enum Error: Swift.Error {
		case connectivity
		case invalidData
	}
	
	// MARK: Initializers
	public init(url: URL, client: HTTPClient) {
		self.url = url
		self.client = client
	}
	
	// MARK: Public methods
	public func load(completion: @escaping (FeedLoader.Result) -> Void) {
		client.get(from: url) { [weak self] result in
			guard let self = self else { return }
	
			switch result {
			case let .success((data, httpResponse)):
				return completion(self.handleSuccessfulResult(data: data, with: httpResponse))
			case .failure:
				return completion(.failure(Error.connectivity))
			}
		}
	}
	
	// MARK: Private methods
	private func handleSuccessfulResult(data: Data, with httpResponse: HTTPURLResponse) -> FeedLoader.Result {
		guard httpResponse.statusCode == HTTPStatusCode.OK,
					let feedImages = FeedImageDecoder.decodeImages(from: data) else {
			return .failure(Error.invalidData)
		}
		return .success(feedImages)
	}

}
