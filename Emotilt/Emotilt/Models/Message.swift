//
//  Message.swift
//  Emotilt
//
//  Created by 최유림 on 2023/02/27.
//

import Foundation

struct Message: Codable {
    let emoji: String
    let content: String
}

/// Contains `sender` information
struct MessageMetaData: Codable {
    let sender: String
    let message: Message
}
