//
//  ViewController.swift
//  MemoryAllocation
//
//  Created by Peter Warbo on 2020-04-28.
//  Copyright © 2020 Peter Warbo. All rights reserved.
//

import UIKit
import Combine

class ViewController: UIViewController, UINavigationControllerDelegate {
    let queue = DispatchQueue(label: "Queue", qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem)
    var image: UIImage?
    var storage: Set<AnyCancellable> = []
    let publisher = PassthroughSubject<UIImage, Never>()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.publisher
            .flatMap {image in
                self.futureMaker(image: image)
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { (completion) in
            }) { (value) in
                print("finished processing image")
                self.image = value
            }
            .store(in: &self.storage)
    }
    @IBAction func didTapPickImage(_ sender: UIButton) {
        let picker = UIImagePickerController()
        picker.delegate = self
        present(picker, animated: true)
    }
    func futureMaker(image: UIImage) -> AnyPublisher<UIImage, Never> {
        Future<UIImage, Never> { promise in
            self.queue.asyncAfter(deadline: .now() + 0.5) {
                promise(.success(image))
            }
        }.eraseToAnyPublisher()
    }
}
extension ViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        dismiss(animated: true)
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        print("got image")
        self.publisher.send(image)
    }
}

