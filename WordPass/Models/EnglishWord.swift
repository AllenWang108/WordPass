//
//  EnglishWord.swift
//  WordPass
//
//  Created by Apple on 12/03/2018.
//  Copyright © 2018 WordPass. All rights reserved.
//

import Foundation

struct EnglishWord: Codable {
    
    var word: String
    var def: String
    
    enum CodingKeys: String, CodingKey {
        case word = "单词"
        case def = "释义"
    }
}
