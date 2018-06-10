//
//  WordDetail.swift
//  WordPass
//
//  Created by Apple on 11/03/2018.
//  Copyright © 2018 WordPass. All rights reserved.
//

import Foundation

struct Card: Codable {
    var word: String
    var definition: [Definition]
    var phoneticAm: String?
    var phoneticBr: String?
    var pronunciation: String?
    var samples: [Sample]?

    enum CodingKeys: String, CodingKey {
        case word
        case pronunciation
        case samples = "sams"
        case definition = "defs"
    }

    enum PronunciationKeys: String, CodingKey {
        case AmEmp3
        case AmE
        case BrE
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)


        let mp3 = try values.nestedContainer(keyedBy: PronunciationKeys.self, forKey: .pronunciation)
        pronunciation = try? mp3.decode(String.self, forKey: .AmEmp3)
        phoneticAm = try? mp3.decode(String.self, forKey: .AmE)
        phoneticBr = try? mp3.decode(String.self, forKey: .BrE)

        samples = try? values.decode([Sample].self, forKey: .samples)
        definition = try values.decode([Definition].self, forKey: .definition)
        word = try values.decode(String.self, forKey: .word)
    }
}

struct Definition: Codable {
    var type: String
    var meaning: String
    
    enum CodingKeys: String, CodingKey {
        case type = "pos"
        case meaning = "def"
    }
}
    
struct Sample: Codable {
    
    var englishSentence: String?
    var chineseTranslation: String?
    var mp3Url: String?
    
    enum CodingKeys: String, CodingKey {
        case englishSentence = "eng"
        case chineseTranslation = "chn"
        case mp3Url
    }
}
    


