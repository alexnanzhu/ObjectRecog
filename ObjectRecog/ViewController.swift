//
//  ViewController.swift
//  SeeFood
//
//  Created by Alex Z on 7/10/18.
//  Copyright © 2018 Alex Nan Zhu. All rights reserved.
//

import UIKit
import CoreML
import Vision
import PKHUD

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let imagePicker = UIImagePickerController()

    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let userPickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            fatalError()
        }
        imageView.image = userPickedImage
        
        HUD.show(.progress)

        DispatchQueue.main.asyncAfter(deadline: .now()) {
            guard let ciImage = CIImage(image: userPickedImage) else { fatalError("couldnt convert") }
            self.detect(image: ciImage)
            HUD.flash(.success, delay: 1.0)
        }
        imagePicker.dismiss(animated: true, completion: nil)
        
    }
    
    func detect(image: CIImage) {
        
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
            fatalError("loading coreml model failed")
        }
        
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("model failed to process image")
            }
            self.navigationItem.title = results.first?.identifier
            print(results)
            
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        do {
            try handler.perform([request])
        } catch {
            print("handler error \(error)")
        }
        
    }
    
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
    }
    

}

