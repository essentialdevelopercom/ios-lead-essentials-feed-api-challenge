//
//  Copyright © 2018 Essential Developer. All rights reserved.
//

import Foundation

public final class RemoteFeedLoader: FeedLoader {
    private let url: URL
    private let client: HTTPClient
    
    private static var OK_200: Int { return 200 }
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load(completion: @escaping (FeedLoader.Result) -> Void) {
        client.get(from: url, completion: { result in
            switch result {
            case let .success((data, response)):
                if let _ = try? JSONSerialization.jsonObject(with: data),
                    response.statusCode == RemoteFeedLoader.OK_200 {
                    completion(.success([]))
                } else {
                    completion(.failure(Error.invalidData))
                }
            case .failure(_):
                completion(.failure(Error.connectivity))
            }
        })
    }
}

