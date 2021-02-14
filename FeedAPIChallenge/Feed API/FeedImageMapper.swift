//
//  FeedImageMapper.swift
//  FeedAPIChallenge
//
//  Created by Navi on 13/02/21.
//  Copyright © 2021 Essential Developer Ltd. All rights reserved.
//

import Foundation

final class FeedImageMapper{
	
	private struct Entity: Decodable{
		let items:[ImageItem]
		
		var feed: [FeedImage]{
			items.map{
				FeedImage(id: $0.id,
						  description: $0.description,
						  location: $0.location,
						  url: $0.url)
			}
		}
	}
	
	private struct ImageItem: Decodable{
		let id: UUID
		let description: String?
		let location: String?
		let url: URL
		
		private enum CodingKeys:String, CodingKey{
			case id = "image_id"
			case description = "image_desc"
			case location = "image_loc"
			case url = "image_url"
		}
	}
	
	private static var validStatusCode: Int {  return 200 }
	
	static func map(_ data: Data, from response: HTTPURLResponse) -> FeedLoader.Result{
		
		guard response.statusCode == validStatusCode,
			  let images = try? JSONDecoder().decode(Entity.self, from: data) else {
			return .failure(RemoteFeedLoader.Error.invalidData)
		}
		
		return .success(images.feed)
	}
	
}
