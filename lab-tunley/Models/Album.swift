//
//  Album.swift
//  lab-tunley
//
//  Created by Zaybo on 9/17/23.
//

import Foundation

struct AlbumSearchResponse: Decodable {
    let results: [Album]
}

struct Album: Decodable {
    let artworkUrl100: URL
}
