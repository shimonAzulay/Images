//
//  ViewModel.swift
//  Images
//
//  Created by Shimon Azulay on 29/11/2022.
//

import Foundation
import Combine

extension PixabayImagesViewModel {
  enum Error: Swift.Error {
    case invalidImageName
    case invalidUrl
  }
}

class PixabayImagesViewModel {
  var imagesPublisher: AnyPublisher<[Image], Never> {
    imagesSubject.eraseToAnyPublisher()
  }
  let imageDataCache = ImageDataCache()
  
  private let imagesSubject = CurrentValueSubject<[Image], Never>([])
  private var imageName: String?
  private var currentPage = 0
  private var cancellables = Set<AnyCancellable>()
  
  func reset(toImageName imageName: String?) {
    self.imageName = imageName
    currentPage = 0
    imagesSubject.send([])
  }
  
  func fetchMoreImages() throws {
    guard let imageName,
          imageName.isEmpty == false else {
      throw PixabayImagesViewModel.Error.invalidImageName
    }
    
    currentPage += 1
    print("Fetching page: \(currentPage)")
    guard let url = URL(string: "https://pixabay.com/api/?key=19057131-d585b08b5672c1d1e3966d2e0&q=\(imageName)&image_type=photo&per_page=30&page=\(currentPage)") else {
      throw PixabayImagesViewModel.Error.invalidUrl
    }
    
    let urlRequest = URLRequest(url: url)
    
    URLSession.shared
      .dataTaskPublisher(for: urlRequest)
      .subscribe(on: DispatchQueue.global(qos: .userInitiated))
      .tryMap { element -> Data in
        guard let httpResponse = element.response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
          throw URLError(.badServerResponse)
        }
        return element.data
      }
      .decode(type: PixabayModel.self, decoder: JSONDecoder())
      .sink(receiveCompletion: {
        print("Received completion: \($0)")
      }, receiveValue: { [weak self] pixabayImages in
        let fetchedImages = pixabayImages.hits.compactMap { hit -> Image? in
          guard let url = URL(string: hit.largeImageURL) else { return nil }
          return Image(url: url)
        }
        
        self?.imagesSubject.send(fetchedImages)
      })
      .store(in: &cancellables)
  }
}
