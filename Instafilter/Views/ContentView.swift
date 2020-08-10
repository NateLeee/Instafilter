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
    @State private var filterIntensityDisabled = true
    @State private var filterRadius = 0.5
    @State private var filterRadiusDisabled = true
    @State private var filterScale = 0.5
    @State private var filterScaleDisabled = true
    
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
                        .shadow(color: .black, radius: 1, x: 0, y: 1)
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
                        .disabled(filterIntensityDisabled)
                }
                
                HStack {
                    Text("Radius")
                    Slider(value: radiusBinding)
                        .disabled(filterRadiusDisabled)
                }
                
                HStack {
                    Text("Scale")
                    Slider(value: scaleBinding)
                        .disabled(filterScaleDisabled)
                }
            }
            .padding(.vertical)
            
            HStack {
                Button("Change Filter (\(currentFilterName))") {
                    self.showingFilterSheet = true
                }
                .disabled(image == nil)
                
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
                .disabled(image == nil)
            }
        }
        .padding([.bottom, .horizontal])
        .navigationBarTitle("Instafilter")
        .sheet(isPresented: $showingImagePicker, onDismiss: {
            self.setFilter(CIFilter.sepiaTone(), "Sepia Tone")
        }, content: {
            ImagePicker(inputUIImage: self.$inputUIImage)
        })
            .actionSheet(isPresented: $showingFilterSheet) {
                ActionSheet(
                    title: Text("Filter List"),
                    message: Text("Choose a filter"),
                    buttons: [
                        .default(Text("Crystallize")) {
                            self.setFilter(CIFilter(name: "CICrystallize")!, "Crystallize")
                        },
                        .default(Text("Edges")) {
                            self.setFilter(CIFilter(name: "CIEdges")!, "Edges")
                        },
                        .default(Text("Gaussian Blur")) {
                            self.setFilter(CIFilter(name: "CIGaussianBlur")!, "Gaussian Blur")
                        },
                        .default(Text("Pixellate")) {
                            self.setFilter(CIFilter(name: "CIPixellate")!, "Pixellate")
                        },
                        .default(Text("Sepia Tone")) {
                            self.setFilter(CIFilter(name: "CISepiaTone")!, "Sepia Tone")
                        },
                        .default(Text("Unsharp Mask")) {
                            self.setFilter(CIFilter(name: "CIUnsharpMask")!, "Unsharp Mask")
                        },
                        .default(Text("Vignette")) {
                            self.setFilter(CIFilter(name: "CIVignette")!, "Vignette")
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
        
        // Reset stuff
        filterIntensityDisabled = true
        filterScaleDisabled = true
        filterScaleDisabled = true
        
        let inputKeys = currentFilter.inputKeys
        if inputKeys.contains(kCIInputIntensityKey) {
            filterIntensityDisabled = false
        }
        if inputKeys.contains(kCIInputRadiusKey) {
            filterRadiusDisabled = false
        }
        if inputKeys.contains(kCIInputScaleKey) {
            filterScaleDisabled = false
        }
        
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
        if (!filterIntensityDisabled) {
            currentFilter.setValue(filterIntensity, forKey: kCIInputIntensityKey)
        }
        
        if (!filterRadiusDisabled) {
            currentFilter.setValue(filterRadius * 270, forKey: kCIInputRadiusKey)
        }
        
        if (!filterScaleDisabled) {
            currentFilter.setValue(filterScale * 26, forKey: kCIInputScaleKey)
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
