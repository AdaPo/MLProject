//
//  BottomBarView.swift
//  MachineLearningProject
//
//  Created by Adam Poustka on 10.04.2023.
//

import SwiftUI

struct BottomBarView: View {
    var onImage: (()->Void)?
    var onText: (()->Void)?
    var onSettings: (()->Void)?
    
    var body: some View {
        HStack {
            BarButtonItem(titleText: "Image", imageName: "photo", action: onImage)
            BarButtonItem(titleText: "Text", imageName: "text.bubble", action: onText)
            BarButtonItem(titleText: "Settings", imageName: "gear", action: onSettings)
        }
        .background(Color(UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 0.1)))
        
    }
}

struct BarButtonItem: View {
    var titleText: String
    var imageName: String
    var action: (()->Void)?
    
    var body: some View {
        if let action = action {
            Button {
                action()
            } label: {
                VStack {
                    Image(systemName: imageName)
                        .renderingMode(.template)
                        .resizable()
                        .frame(width: 25, height: 25)
                        .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 50)
            .overlay(Divider()
                .background(Color(white: 255,opacity: 0.1))
                .ignoresSafeArea(), alignment: .leading)
        } else {
            HStack{
                Image(systemName: imageName)
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: 25, height: 25)
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.gray)
            }
            .frame(height: 50)
            .overlay(Divider().ignoresSafeArea(), alignment: .leading)

        }
    }
}
struct BottomBarView_Previews: PreviewProvider {
    static var previews: some View {
        BottomBarView(onImage: {})
    }
}
