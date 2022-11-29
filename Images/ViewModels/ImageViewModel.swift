//
//  ImageViewModel.swift
//  Images
//
//  Created by Shimon Azulay on 29/11/2022.
//

import Foundation
import Combine

extension ImageViewModel {
  enum Error: Swift.Error {
    case badResponse
  }
}

class ImageViewModel {
  let imageCache: ImageDataCache
  
  init(imageCache: ImageDataCache) {
    self.imageCache = imageCache
  }
  
  func fetchImage(atUrl url: URL) -> AnyPublisher<Data, ImageViewModel.Error> {
//    if let imageData = imageCache.getItem(forKey: url.absoluteString) {
//      return Just<Data>(imageData).eraseToAnyPublisher()
//    }
    
    let urlRequest = URLRequest(url: url)
    
    return URLSession.shared
      .dataTaskPublisher(for: urlRequest)
      .subscribe(on: DispatchQueue.global(qos: .userInitiated))
      .tryMap { element -> Data in
        guard let httpResponse = element.response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
          throw URLError(.badServerResponse)
        }
        return element.data
      }
      .mapError { _ in ImageViewModel.Error.badResponse }
      .eraseToAnyPublisher()
  }
}
