//
//  Note.swift
//  Notes
//
//  Created by Damian on 07/11/2022.
//

import Foundation

struct Note: Identifiable, Codable {
    var id: String {return _id}
    var _id: String
    var note: String
    
}
