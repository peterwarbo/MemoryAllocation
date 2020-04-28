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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func didTapPickImage(_ sender: UIButton) {
        let picker = UIImagePickerController()
        picker.delegate = self
        present(picker, animated: true)
    }
}

extension ViewController: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        dismiss(animated: true)
        queue.async {
            
            guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
            
            Process.longProcess()
                .sink(receiveCompletion: { (completion) in
                    
                }) { [weak self] (value) in
                    self?.image = image
                }
                .store(in: &self.storage)
        }
    }
    
}

enum Process {
    
    typealias Handler = (Result<Void, Swift.Error>) -> Void
    static func longProcess(handler: @escaping Handler) {
        DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + 0.5) {
            handler(.success(()))
        }
    }
    
    static func longProcess() -> AnyPublisher<Void, Swift.Error> {
        Future { Self.longProcess(handler: $0) }.eraseToAnyPublisher()
    }
}
