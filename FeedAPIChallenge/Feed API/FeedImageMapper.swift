//
//  FeedImageMapper.swift
//  FeedAPIChallengeTests
//
//  Created by Shilpa Bansal on 12/01/21.
//  Copyright © 2021 Essential Developer Ltd. All rights reserved.
//

import Foundation
extension FeedImage: Decodable {
	enum CodingKeys: String, CodingKey {
		case id = "image_id"
		case description = "image_desc"
		case location = "image_loc"
		case url = "image_url"
	}

	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.location = try container.decodeIfPresent(String.self, forKey: .location)
		self.description = try container.decodeIfPresent(String.self, forKey: .description)
		if let idString = try? container.decodeIfPresent(String.self, forKey: .id),
		   let uid = UUID(uuidString: idString)  {
			self.id = uid
		} else {
			fatalError()
		}
		if let urlString = try? container.decodeIfPresent(String.self, forKey: .url),
		   let imgUrl = URL(string: urlString)  {
			self.url = imgUrl
		} else {
			fatalError()
		}
	}
}

struct FeedItems : Decodable {
	var images: [FeedImage]?
	
	enum CodingKeys: String, CodingKey {
		case items
	}
	
	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.images = try container.decodeIfPresent([FeedImage].self, forKey: .items)
	}
}
