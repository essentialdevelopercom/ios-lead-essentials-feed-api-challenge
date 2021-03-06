//
//  FeedImageItemsMapper.swift
//  FeedAPIChallenge
//
//  Created by Hitender Kumar on 06/03/21.
//  Copyright © 2021 Essential Developer Ltd. All rights reserved.
//

import Foundation

internal final class FeedImageItemsMapper {
	
	private struct Item : Decodable {
		var image_id : UUID
		var image_desc : String?
		var image_loc : String?
		var image_url : URL
		
		var item : FeedImage {
			return FeedImage(id: image_id, description: image_desc, location: image_loc, url: image_url)
		}
	}
	
	private struct Root : Decodable {
		var items : [Item]
		
		var images : [FeedImage] {
			items.map({ $0.item })
		}
	}
	
	private static var OK_200 : Int { return 200 }
   
	internal static func map(data : Data, from response : HTTPURLResponse) -> FeedLoader.Result {
		
		guard response.statusCode == OK_200,
			  let root = try? JSONDecoder().decode(Root.self, from: data) else {
			return .failure(RemoteFeedLoader.Error.invalidData)
		}
		return .success(root.images)
	}
}
