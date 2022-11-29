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
  private var cancellables = Set<AnyCancellable>()
  private var shouldFetchMore = true
  
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
        guard $0.isEmpty == false else {
          self?.images.removeAll()
          self?.shouldFetchMore = false
          try? self?.viewModel.fetchMoreImages()
          return
        }
        
        self?.shouldFetchMore = true
        self?.images.append(contentsOf: $0)
      }
      .store(in: &cancellables)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
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
    if indexPath.row > images.count - 10,
       shouldFetchMore {
      do {
        shouldFetchMore = false
        try viewModel.fetchMoreImages()
      } catch {
        print(error.localizedDescription)
      }
    }
  }
}
