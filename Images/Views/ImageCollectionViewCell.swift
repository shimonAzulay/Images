//
//  ImageCollectionViewCell.swift
//  Images
//
//  Created by Shimon Azulay on 28/11/2022.
//

import UIKit
import Combine

class ImageCollectionViewCell: UICollectionViewCell {
  private lazy var imageView: UIImageView = {
    let imageView = UIImageView()
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.layer.cornerRadius = 10
    imageView.backgroundColor = .blue
    return imageView
  }()
  
  private var cancellable: AnyCancellable?
  
  static let identifier = "ImageCollectionViewCell"
  var imageViewModel: ImageViewModel!
  var image: Image? {
    didSet {
      guard let url = image?.url else { return }
      cancellable = imageViewModel.fetchImage(atUrl: url)
        .receive(on: DispatchQueue.main)
        .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] in
          self?.imageView.image = UIImage(data: $0)
        })
    }
  }
  
  func populateImage(_ data: Data) {
    DispatchQueue.main.async { [weak self] in
      self?.imageView.image = UIImage(data: data)
    }
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupView()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    cancellable?.cancel()
    cancellable = nil
    imageView.image = nil
  }
}

private extension ImageCollectionViewCell {
  func setupView() {
    contentView.addSubview(imageView)
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
    imageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    imageView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
    imageView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
  }
}
