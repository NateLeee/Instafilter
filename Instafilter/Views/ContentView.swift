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
    
    var body: some View {
        VStack {
            image?
                .resizable()
                .scaledToFit()
        }
        .onAppear(perform: loadImage)
        
    }
    
    func loadImage() {
        // image = Image("example")
        
        guard let inputUIImage = UIImage(named: "example") else {
            return
        }
        let ciImage = CIImage(image: inputUIImage)
        
        let context = CIContext()
        let filter = CIFilter.sepiaTone()
        
        filter.inputImage = ciImage
        filter.intensity = 0.9
        
        guard let outputCIImage = filter.outputImage else { return }
        if let outputCGImage = context.createCGImage(outputCIImage, from: outputCIImage.extent) {
            let uiImage = UIImage(cgImage: outputCGImage)
            image = Image(uiImage: uiImage)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
