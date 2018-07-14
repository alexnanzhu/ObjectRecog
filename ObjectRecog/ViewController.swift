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
import ROGoogleTranslate

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let imagePicker = UIImagePickerController()
    
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var imageView: UIImageView!
    
    //MARK: - Translate part
    var jieguo = "test"
    
    
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
        self.navigationItem.title = "Recognizing... 识别中 🔍"
        HUD.show(.progress)
        
        
        guard let ciImage = CIImage(image: userPickedImage) else { fatalError("couldnt convert") }
        let word = self.detect(image: ciImage)
        let params = ROGoogleTranslateParams(source: "en",
                                             target: "zh-CN",
                                             text: word)
        
        
        let translator = ROGoogleTranslate()
        translator.translate(params: params) { (result) in
            print("Translation: \(result)")
            self.navigationItem.title = result
            HUD.hide()
        }
        
        
        
        imagePicker.dismiss(animated: true, completion: nil)
        
    }
    
    func detect(image: CIImage) -> String {
        
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
            fatalError("loading coreml model failed")
        }
        
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("model failed to process image")
            }
            
            self.jieguo = results.first!.identifier
            
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        do {
            try handler.perform([request])
        } catch {
            print("handler error \(error)")
        }
        
        return jieguo
        
    }
    
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
        
    }

    
}



