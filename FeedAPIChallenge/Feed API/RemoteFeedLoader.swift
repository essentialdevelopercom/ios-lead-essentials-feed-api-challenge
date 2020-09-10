//
//  Copyright © 2018 Essential Developer. All rights reserved.
//

import Foundation

public final class RemoteFeedLoader: FeedLoader {
	private let url: URL
	private let client: HTTPClient
    private var urls = [URL]()
	
	public enum Error: Swift.Error {
		case connectivity
		case invalidData
	}
		
    public init(url: URL, client: HTTPClient) {
		self.url = url
		self.client = client
	}
	
	public func load(completion: @escaping (FeedLoader.Result) -> Void) {
        client.get(from: url){result in
            switch result{
            case  .failure(_):
                completion(.failure(RemoteFeedLoader.Error.connectivity))
            case let .success((data, response)):
                if response.statusCode != 200{
                    completion(.failure(RemoteFeedLoader.Error.invalidData))
                }
                else{
                    if let root = try? JSONDecoder().decode(Root.self, from: data){
                        completion(.success(root.items.map{FeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url)}))
                    }
                    else{
                        completion(.failure(RemoteFeedLoader.Error.invalidData))
                    }

                }
            }
        }
    }
}

struct Root : Decodable {
    var items : [RemoteFeedImage]
}

struct  RemoteFeedImage : Decodable {

    public let id: UUID
    public let description: String?
    public let location: String?
    public let url: URL

    public init(id: UUID, description: String?, location: String?, url: URL) {
        self.id = id
        self.description = description
        self.location = location
        self.url = url
    }

    private enum CodingKeys : String, CodingKey {
        case id = "image_id"
        case description = "image_desc"
        case location = "image_loc"
        case url = "image_url"
    }

}
