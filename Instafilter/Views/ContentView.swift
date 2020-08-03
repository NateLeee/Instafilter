//
//  ContentView.swift
//  Instafilter
//
//  Created by Nate Lee on 7/28/20.
//  Copyright © 2020 Nate Lee. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State private var image: Image?
    @State private var filterIntensity = 0.5
    
    var body: some View {
        VStack {
            ZStack {
                Rectangle()
                    .fill(Color.secondary)
                
                // Display the image
                image?
                    .resizable()
                    .scaledToFit()
                
            }
            .onTapGesture {
                // Select an image
            }
            
            HStack {
                Text("Intensity")
                
                Slider(value: $filterIntensity)
            }
            .padding(.vertical)
            
            HStack {
                Button("Change Filter") {
                    // TODO: - Change Filter
                }
                
                Spacer()
                
                Button("Save") {
                    // TODO: - Save the photo applied with the filter
                }
            }
            
        }
        .padding([.bottom, .horizontal])
        .navigationBarTitle("Instafilter")
    }
    
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
