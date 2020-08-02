//
//  ContentView.swift
//  Instafilter
//
//  Created by Nate Lee on 7/28/20.
//  Copyright © 2020 Nate Lee. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State private var blurAmount: CGFloat = 0
    
    let blurBinding = Binding<CGFloat>(
        get: {
            self.blurAmount
        },
        set: {
            self.blurAmount = $0
            print("New value is \(self.blurAmount)")
        }
    )
    
    var body: some View {
        return VStack {
            Text("Hello, World!")
                .blur(radius: blurAmount)
            
            Slider(value: blurBinding, in: 0...20)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
