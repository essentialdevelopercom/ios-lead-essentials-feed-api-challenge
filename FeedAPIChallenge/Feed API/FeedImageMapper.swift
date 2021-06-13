//
//  FeedImageMapper.swift
//  FeedAPIChallenge
//
//  Created by Daniel Gallego Peralta on 13/6/21.
//  Copyright © 2021 Essential Developer Ltd. All rights reserved.
//

import Foundation

struct FeedImageMapper {
	private struct GroupItem: Decodable {
		let items: [RemoteImage]
	}

	static func decode(from data: Data) -> [FeedImage]? {
		guard let groupItem = try? JSONDecoder().decode(GroupItem.self, from: data) else {
			return nil
		}

		return mapRemoteImages(groupItem.items)
	}

	static private func mapRemoteImages(_ items: [RemoteImage]) -> [FeedImage] {
		return items.map { remoteImage in
			return FeedImage(
				id: remoteImage.image_id,
				description: remoteImage.image_desc,
				location: remoteImage.image_loc,
				url: remoteImage.image_url)
		}
	}
}
