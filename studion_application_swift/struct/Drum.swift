//
//  drum.swift
//  studion_application_swift
//
//  Created by 김진홍 on 2022/03/21.
//

import Foundation

public class Drum {
    struct key: Codable{
        var type: String
        var key: String
        var socketId: String
    }
}
