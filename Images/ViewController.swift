//
//  ViewController.swift
//  Images
//
//  Created by Shimon Azulay on 28/11/2022.
//

import UIKit

class ViewController: UIViewController {
  let viewModel = PixabayImagesViewModel()
  
  private lazy var container: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.alignment = .fill
    stackView.distribution = .fill
    stackView.spacing = 5
    stackView.translatesAutoresizingMaskIntoConstraints = false
    return stackView
  }()
  
  private lazy var searchTextField: UITextField = {
    let textView = UITextField()
    textView.placeholder = "Search"
    textView.borderStyle = .line
    return textView
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    setupContainerView()
    setupSearchTextField()
    setupImageCollectionView()
  }
}

private extension ViewController {
  func setupContainerView() {
    view.addSubview(container)
    container.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
    container.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    container.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10).isActive = true
    container.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10).isActive = true
  }
  
  func setupSearchTextField() {
    container.addArrangedSubview(searchTextField)
    searchTextField.addTarget(self, action: #selector(textFieldDidEnd), for: .editingDidEnd)
  }
  
  func setupImageCollectionView() {
    let flowLayout = UICollectionViewFlowLayout()
    flowLayout.sectionInset = UIEdgeInsets(top: 5, left: 15, bottom: 5, right: 15)
    flowLayout.itemSize = CGSize(width: 150, height: 150)
    let imagesCollectionViewController = ImagesCollectionViewController(collectionViewLayout: flowLayout)
    imagesCollectionViewController.viewModel = viewModel
    addChild(imagesCollectionViewController)
    container.addArrangedSubview(imagesCollectionViewController.collectionView)
    imagesCollectionViewController.didMove(toParent: self)
  }
  
  @objc func textFieldDidEnd(_ textField: UITextField) {
    viewModel.reset(toImageName: textField.text)
  }
}

