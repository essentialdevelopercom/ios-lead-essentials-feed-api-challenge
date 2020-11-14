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
        client.get(from: url) {
            [completion] (result: Result) in
            switch result {
            case let .success((data, response)):
                completion(FeedLoader.Result{
                            try mapToFeedImage((data, response))
                })
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }
    
}

private func mapToFeedImage(_ result: (Data, HTTPURLResponse)) throws ->  [FeedImage] {
    let (data, response) = result
    try throwIfNot200(response: response)
    try throwIfNotJSON(data: data)
    return []
}

private func throwIfNot200(response: HTTPURLResponse) throws {
    guard response.statusCode == 200 else {
        throw RemoteFeedLoader.Error.invalidData
    }
}
private func throwIfNotJSON(data: Data) throws {
    let jsonString = String(data: data, encoding: .utf8) ?? ""
    guard
        jsonString.hasPrefix("{"),
        jsonString.hasSuffix("}") else {
        throw RemoteFeedLoader.Error.invalidData
    }
}
