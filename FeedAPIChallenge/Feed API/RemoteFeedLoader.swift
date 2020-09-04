//
//  Copyright © 2018 Essential Developer. All rights reserved.
//

import Foundation

public final class RemoteFeedLoader: FeedLoader {
    private let url: URL
    private let request: (URL) -> Void
	
	public enum Error: Swift.Error {
	}
		
    public init(url: URL, request: @escaping (URL) -> Void) {
        self.url = url
        self.request = request
	}
	
	public func load(completion: @escaping (FeedLoader.Result) -> Void) {
        request(url)
    }
}
