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
    let ciContext = CIContext() // Expensive to create!
    
    @State private var image: Image?
    @State private var inputUIImage: UIImage?
    @State private var processedUIImage: UIImage?
    
    @State private var currentFilter: CIFilter = CIFilter.sepiaTone()
    // Challenge II: - Make the Change Filter button change its title to show the name of the currently selected filter.
    @State private var currentFilterName = "Sepia Tone"
    @State private var filterIntensity = 0.5
    @State private var filterRadius = 180.0
    @State private var filterScale = 9.0
    
    @State private var showingImagePicker = false
    @State private var showingFilterSheet = false
    
    // Challenge I: - Try making the Save button show an error if there was no image in the image view.
    @State private var showingSavingStatus = false
    @State private var savingStatusMsg: String = ""
    @State private var savingStatusTitle = ""
    
    var body: some View {
        let intensityBinding = Binding<Double>(get: {
            self.filterIntensity
        }, set: { newValue in
            self.filterIntensity = newValue
            self.applyProcessing()
        })
        
        let radiusBinding = Binding<Double>(get: {
            self.filterRadius
        }, set: { newValue in
            self.filterRadius = newValue
            self.applyProcessing()
        })
        
        let scaleBinding = Binding<Double>(get: {
            self.filterScale
        }, set: { newValue in
            self.filterScale = newValue
            self.applyProcessing()
        })
        
        
        return VStack {
            ZStack {
                Rectangle()
                    .fill(Color.secondary)
                
                // Display the image
                if image != nil {
                    image!
                        .resizable()
                        .scaledToFit()
                } else {
                    Text("Tap to select a picture")
                        .foregroundColor(.white)
                        .font(.headline)
                }
                
            }
            .onTapGesture {
                // Select an image picker
                self.showingImagePicker = true
            }
            
            // MARK: - Control Group
            VStack {
                HStack {
                    Text("Intensity")
                    Slider(value: intensityBinding)
                }
                
                HStack {
                    Text("Radius")
                    Slider(value: radiusBinding)
                }
                
                HStack {
                    Text("Scale")
                    Slider(value: scaleBinding)
                }
            }
            .padding(.vertical)
            
            HStack {
                Button("Change Filter (\(currentFilterName))") {
                    self.showingFilterSheet = true
                }
                
                Spacer()
                
                Button("Save") {
                    // Save the photo applied with the filter
                    guard let processedUIImage = self.processedUIImage else {
                        // Show an error alert
                        self.showingSavingStatus = true
                        self.savingStatusTitle = "Oops!"
                        self.savingStatusMsg = "There appears to be no photo."
                        
                        return
                    }
                    
                    let imageSaver = ImageSaver()
                    
                    imageSaver.successHandler = {
                        self.showingSavingStatus = true
                        self.savingStatusTitle = "Saved!"
                        self.savingStatusMsg = "Thanks for using this app!"
                    }
                    
                    imageSaver.errorHandler = {
                        self.showingSavingStatus = true
                        self.savingStatusTitle = "Error!"
                        self.savingStatusMsg = "\($0.localizedDescription)"
                    }
                    
                    imageSaver.writeToPhotoLibrary(processedUIImage)
                }
            }
        }
        .padding([.bottom, .horizontal])
        .navigationBarTitle("Instafilter")
        .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
            ImagePicker(inputUIImage: self.$inputUIImage)
        }
        .actionSheet(isPresented: $showingFilterSheet) {
            ActionSheet(
                title: Text("Filter List"),
                message: Text("Choose a filter"),
                buttons: [
                    .default(Text("Crystallize")) {
                        self.setFilter(CIFilter.crystallize(), "Crystallize")
                    },
                    .default(Text("Edges")) {
                        self.setFilter(CIFilter.edges(), "Edges")
                    },
                    .default(Text("Gaussian Blur")) {
                        self.setFilter(CIFilter.gaussianBlur(), "Gaussian Blur")
                    },
                    .default(Text("Pixellate")) {
                        self.setFilter(CIFilter.pixellate(), "Pixellate")
                    },
                    .default(Text("Sepia Tone")) {
                        self.setFilter(CIFilter.sepiaTone(), "Sepia Tone")
                    },
                    .default(Text("Unsharp Mask")) {
                        self.setFilter(CIFilter.unsharpMask(), "Unsharp Mask")
                    },
                    .default(Text("Vignette")) {
                        self.setFilter(CIFilter.vignette(), "Vignette")
                    },
                    .cancel()
            ])
        }
        .alert(isPresented: $showingSavingStatus) {
            Alert(title: Text("\(self.savingStatusTitle)"), message: Text("\(self.savingStatusMsg)"), dismissButton: .default(Text("Got it")))
        }
    }
    
    // Custom Funcs go here...
    func setFilter(_ filter: CIFilter, _ filterName: String) {
        self.currentFilter = filter
        self.currentFilterName = filterName
        loadImage()
    }
    
    func loadImage() {
        guard let inputUIImage = inputUIImage else { return }
        
        // self.image = Image(uiImage: inputUIImage)
        let beginCIImage = CIImage(image: inputUIImage)
        currentFilter.setValue(beginCIImage, forKey: kCIInputImageKey)
        
        applyProcessing()
    }
    
    func applyProcessing() {
        // currentFilter.intensity = Float(filterIntensity)
        // currentFilter.setValue(Float(filterIntensity), forKey: kCIInputIntensityKey) // This could crash!
        let inputKeys = currentFilter.inputKeys
        if inputKeys.contains(kCIInputIntensityKey) {
            currentFilter.setValue(filterIntensity, forKey: kCIInputIntensityKey)
        }
        if inputKeys.contains(kCIInputRadiusKey) {
            currentFilter.setValue(filterIntensity * 180, forKey: kCIInputRadiusKey)
        }
        if inputKeys.contains(kCIInputScaleKey) {
            currentFilter.setValue(filterIntensity * 9, forKey: kCIInputScaleKey)
        }
        
        guard
            let outputCIImage = currentFilter.outputImage,
            let outputCGImage = ciContext.createCGImage(outputCIImage, from: outputCIImage.extent)
            else { return }
        
        let outputUIImage = UIImage(cgImage: outputCGImage)
        
        // Stash this processed UIImage
        processedUIImage = outputUIImage
        
        image = Image(uiImage: outputUIImage)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
