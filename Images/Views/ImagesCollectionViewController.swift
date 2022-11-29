//
//  ImagesCollectionViewController.swift
//  Images
//
//  Created by Shimon Azulay on 28/11/2022.
//

import UIKit
import Combine

class ImagesCollectionViewController: UICollectionViewController {
  var viewModel: PixabayImagesViewModel!
  var cancellables = Set<AnyCancellable>()
  var images = [Image]() {
    didSet {
      collectionView.reloadData()
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    collectionView.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: ImageCollectionViewCell.identifier)
    viewModel.imagesPublisher
      .receive(on: DispatchQueue.main)
      .sink { [weak self] in
        self?.images.append(contentsOf: $0)
      }
      .store(in: &cancellables)
    
    try? viewModel.fetchMoreImages(page: 1)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    try? viewModel.fetchMoreImages(page: 1)
  }
  
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    images.count
  }
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let image = images[indexPath.row]
    
    guard let reusedCell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCollectionViewCell.identifier, for: indexPath) as? ImageCollectionViewCell else {
      let imageView = ImageCollectionViewCell()
      imageView.imageViewModel = ImageViewModel(imageCache: viewModel.imageDataCache)
      imageView.image = image
      return imageView
    }
    
    reusedCell.imageViewModel = ImageViewModel(imageCache: viewModel.imageDataCache)
    reusedCell.image = image
    return reusedCell
  }
  
  override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    if indexPath.row > images.count - 10 {
      do {
        print("Will fetch more images: \(indexPath.row), \(images.count)")
        try viewModel.fetchMoreImages(page: UInt(indexPath.row / (images.count + 1)) + 1)
      } catch {
        print(error.localizedDescription)
      }
    }
  }
}
