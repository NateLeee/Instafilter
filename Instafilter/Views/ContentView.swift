//
//  ContentView.swift
//  Instafilter
//
//  Created by Nate Lee on 7/28/20.
//  Copyright © 2020 Nate Lee. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State private var showingActionSheet = false
    @State private var backgroundColor = Color.white
    
    var body: some View {
        VStack {
            Text("Hello, World!")
                .background(backgroundColor)
                .onTapGesture {
                    self.showingActionSheet.toggle()
            }
        }
        .actionSheet(isPresented: $showingActionSheet) { () -> ActionSheet in
            ActionSheet(title: Text("Demo"), message: Text("Msg"), buttons: [
                ActionSheet.Button.destructive(Text("destructive")) {
                    self.backgroundColor = .yellow
                },
                .default(Text("Default One")),
                .cancel()
            ])
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
