//
//  Copyright © 2018 Essential Developer. All rights reserved.
//

import Foundation

public final class RemoteFeedLoader: FeedLoader {
    private let url: URL
    private let client: HTTPClient
    private let statusCodeOk: Int = 200
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
        
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load(completion: @escaping (FeedLoader.Result) -> Void) {
        client.get(from: url, completion: { [weak self] result in
            guard let strongSelf = self else { return }
            
            switch result {
            case let .success((data, response)):
                let feedResult = strongSelf.success(for: data, with: response)
                completion(feedResult)
            case .failure:
                completion(.failure(Error.connectivity))
            }
        })
    }
    
    private func success(for data: Data, with response: HTTPURLResponse) -> FeedLoader.Result {
        if response.statusCode == statusCodeOk, let items = try? map(from: data) {
            return .success(items)
        } else {
            return .failure(Error.invalidData)
        }
    }
    
    private func map(from data: Data) throws -> [FeedImage] {
        let decoder = JSONDecoder()
        let feedItemRoot = try decoder.decode(FeedItemRoot.self, from: data)
        var feedimageList: [FeedImage] = []
        
        feedItemRoot.items.forEach({ item in
            let feedImage = FeedImage(id: item.imageId,
                                      description: item.desc,
                                      location: item.location,
                                      url: URL(string: item.url)!)
            
            feedimageList.append(feedImage)
        })
        return feedimageList
    }
}
