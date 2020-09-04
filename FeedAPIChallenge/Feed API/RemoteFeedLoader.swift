//
//  Copyright © 2018 Essential Developer. All rights reserved.
//

import Foundation

public final class RemoteFeedLoader: FeedLoader {
    private let url: URL
    private let request: Request
	
    public typealias Request = (URL, @escaping (Swift.Result<(Data, HTTPURLResponse), Swift.Error>) -> Void) -> Void
    
	public enum Error: Swift.Error {
        case connectivity
        case invalidData
	}
		
    public init(url: URL, request: @escaping Request) {
        self.url = url
        self.request = request
	}
	
	public func load(completion: @escaping (FeedLoader.Result) -> Void) {
        request(url) { result in
            switch result {
            case .failure:
                completion(.failure(Error.connectivity))
            case let .success(data, _):
                if let _ = try? JSONSerialization.jsonObject(with: data) {
                    return completion(.success([]))
                }
                completion(.failure(Error.invalidData))
            }
        }
    }
}
