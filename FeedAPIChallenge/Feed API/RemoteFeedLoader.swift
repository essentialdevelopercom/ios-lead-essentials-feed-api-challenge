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
		
    public typealias Result = LoadFeedResult

	public init(url: URL, client: HTTPClient) {
		self.url = url
		self.client = client
	}
	    
	public func load(completion: @escaping (LoadFeedResult) -> Void) {
        self.client.get(from: self.url, completion: { response
            in
         switch response {
         case .failure :
                completion(.failure(Error.connectivity))
            
         case  let .success(data,response):
            return completion(FeedItemsMapper.map(data, from: response))
          
            }
        })

    }
}
