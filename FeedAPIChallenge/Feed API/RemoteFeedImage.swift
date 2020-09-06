//
//  RemoteFeedImage.swift
//  FeedAPIChallenge
//
//  Created by Araceli Ruiz Ruiz on 06/09/2020.
//  Copyright © 2020 Essential Developer Ltd. All rights reserved.
//

import Foundation

struct RemoteFeedImage: Decodable {
    let image_id: UUID
    let image_desc: String?
    let image_loc: String?
    let image_url: URL
}
