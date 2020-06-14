//
//  FeedImageResponseMapper.swift
//  FeedAPIChallenge
//
//  Created by Erik Agujari on 14/06/2020.
//  Copyright © 2020 Essential Developer Ltd. All rights reserved.
//
import Foundation

struct FeedImageResponseMapper {
    static func map(response: FeedImageResponse) -> FeedImage? {
        guard let uuid = UUID(uuidString: response.id),
            let url = URL(string: response.urlString)
            else { return nil }
        return FeedImage(id: uuid,
                         description: response.description,
                         location: response.location,
                         url: url)
    }
}
