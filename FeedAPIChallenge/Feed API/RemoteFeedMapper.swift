//
//  Created by Thiago Penna on 03/02/21.
//  Copyright © 2021 Essential Developer Ltd. All rights reserved.
//

import Foundation

internal struct RemoteFeedMapper {
	static func map(_ data: Data, response: HTTPURLResponse) -> FeedLoader.Result {
		guard response.statusCode == 200,
			  let feed = try? JSONDecoder().decode(RootObject.self, from: data) else {
			return .failure(RemoteFeedLoader.Error.invalidData)
		}
		return .success(feed.images)
	}
	
	private struct RootObject: Decodable {
		let items: [Image]
		
		var images: [FeedImage] {
			items.compactMap { item in
				FeedImage(id: item.id,
						  description: item.description,
						  location: item.location,
						  url: item.url)
			}
		}
	}
	
	private struct Image: Decodable {
		let id: UUID
		let description: String?
		let location: String?
		let url: URL
		
		enum CodingKeys: String, CodingKey {
			case id = "image_id"
			case description = "image_desc"
			case location = "image_loc"
			case url = "image_url"
		}
	}
}
