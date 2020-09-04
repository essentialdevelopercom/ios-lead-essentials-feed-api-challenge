//
//  Copyright © 2018 Essential Developer. All rights reserved.
//

import Foundation

public final class RemoteFeedLoader: FeedLoader {
    private let url: URL
    private let request: Request
	
    public typealias Request = (URL, @escaping (Swift.Error) -> Void) -> Void
    
	public enum Error: Swift.Error {
        case connectivity
	}
		
    public init(url: URL, request: @escaping Request) {
        self.url = url
        self.request = request
	}
	
	public func load(completion: @escaping (FeedLoader.Result) -> Void) {
        request(url) { error in
            completion(.failure(Error.connectivity))
        }
    }
}
