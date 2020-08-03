//
//  ContentView.swift
//  Instafilter
//
//  Created by Nate Lee on 7/28/20.
//  Copyright © 2020 Nate Lee. All rights reserved.
//

import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

struct ContentView: View {
    @State private var image: Image?
    @State private var inputImage: UIImage?
    @State private var showingImagePicker = false
    
    var body: some View {
        VStack {
            image?
                .resizable()
                .scaledToFit()
            
            Button("Select Image") {
                self.showingImagePicker = true
            }
        }
        .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
            ImagePicker(image: self.$inputImage)
        }
        
    }
    
    func loadImage() {
        guard let inputImage = inputImage else {
            return
        }
        self.image = Image(uiImage: inputImage)
        
        // Save image to the photo library
        let imageSaver = ImageSaver()
        imageSaver.saveToPhotoLibrary(uiImage: inputImage)
    }
    
}

class ImageSaver: NSObject {
    func saveToPhotoLibrary(uiImage: UIImage) {
        UIImageWriteToSavedPhotosAlbum(uiImage, self, #selector(saveError), nil)
    }
    
    @objc func saveError(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        print("Saved!")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
