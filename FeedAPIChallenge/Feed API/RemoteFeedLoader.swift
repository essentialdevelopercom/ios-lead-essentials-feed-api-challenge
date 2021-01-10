//
//  Copyright © 2018 Essential Developer. All rights reserved.
//

import Foundation

public typealias WeakHTTPClient = HTTPClient & AnyObject

public final class RemoteFeedLoader: FeedLoader {
	private let url: URL
	private weak var client: WeakHTTPClient?
	
	public enum Error: Swift.Error {
		case connectivity
		case invalidData
	}
	
	public init(url: URL, client: WeakHTTPClient?) {
		self.url = url
		self.client = client
	}
	
	public func load(completion: @escaping (FeedLoader.Result) -> Void) {
		client?.get(from: url) { [weak self] result in
			guard self?.client != nil else { return }
			do {
				switch result {
				case .success((let data, let response)):
					if response.statusCode == 200 {
						let images = try RemoteImagesLoader.getImages(data)
						completion(.success(images))
					} else {
						completion(.failure(Error.invalidData))
					}
				case .failure(_): completion(.failure(Error.connectivity))
				}
			} catch {
				completion(.failure(Error.invalidData))
			}
		}
	}
}
