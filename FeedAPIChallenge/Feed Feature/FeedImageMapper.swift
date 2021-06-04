//
//  FeedImageMapper.swift
//  FeedAPIChallenge
//
//  Created by Константин Богданов on 04.06.2021.
//  Copyright © 2021 Essential Developer Ltd. All rights reserved.
//

import Foundation

protocol FeedImageMapper {
	func map(data: Data) throws -> [FeedImage]
}
