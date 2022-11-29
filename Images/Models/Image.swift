//
//  Image.swift
//  Images
//
//  Created by Shimon Azulay on 28/11/2022.
//

import Foundation

struct Image {
  let url: URL
}

struct PixabayModel: Decodable {
  let hits: [PixabayImage]
}

struct PixabayImage: Decodable {
  let largeImageURL: String
}
