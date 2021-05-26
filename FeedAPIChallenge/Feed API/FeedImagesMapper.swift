//
//  FeedImagesMapper.swift
//  FeedAPIChallenge
//
//  Created by Darren Findlay on 26/05/2021.
//  Copyright © 2021 Essential Developer Ltd. All rights reserved.
//

import Foundation

struct FeedImageMapper {
	static func map(result: Result<(Data, HTTPURLResponse), Error>) -> FeedLoader.Result {
		if case let .success((data, response)) = result, response.statusCode == 200 {
			return map(data: data, response: response)
		} else if case .success = result {
			return .failure(RemoteFeedLoader.Error.invalidData)
		} else {
			return .failure(RemoteFeedLoader.Error.connectivity)
		}
	}

	private static func map(data: Data, response: HTTPURLResponse) -> FeedLoader.Result {
		do {
			let remoteFeeditems = try JSONDecoder().decode(GetRemoteFeedImageResponseBody.self, from: data)
			let items = remoteFeeditems.items.map(FeedImage.init)
			return .success(items)
		} catch {
			return .failure(RemoteFeedLoader.Error.invalidData)
		}
	}
}

extension FeedImage {
	fileprivate init(remoteFeedImage: RemoteFeedImage) {
		self.id = remoteFeedImage.id
		self.description = remoteFeedImage.description
		self.location = remoteFeedImage.location
		self.url = remoteFeedImage.imageUrl
	}
}
