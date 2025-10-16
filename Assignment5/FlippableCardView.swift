//
//  FlippableCardView.swift
//  Assignment5
//
//  Created by Eezy Mongo on 2025-10-15.
//

import SwiftUI
import UIKit

struct FlippableCardView: View {
    @Binding var place: Place              // <-- binding ensures updates persist
    @ObservedObject var viewModel: PlacesViewModel
    
    @State private var rotation = 0.0
    @State private var showingImagePicker = false
    @State private var imagePickerSource: UIImagePickerController.SourceType = .photoLibrary
    @State private var isFlipped = false
    
    var body: some View {
        ZStack {
            if !isFlipped {
                VStack {
                    if let path = place.imagePath,
                       let uiImage = UIImage(contentsOfFile: path) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                    } else {
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .foregroundColor(.gray)
                            .opacity(0.5)
                            .padding()
                    }
                    
                    HStack(spacing: 12) {
                        Button("Select Photo") {
                            imagePickerSource = .photoLibrary
                            showingImagePicker = true
                        }
                        .buttonStyle(CardButtonStyle(color: .blue))
                        
                        Button("Take Photo") {
                            imagePickerSource = .camera
                            showingImagePicker = true
                        }
                        .buttonStyle(CardButtonStyle(color: .green))
                        
                        if place.imagePath != nil {
                            Button("Remove Image") {
                                place.imagePath = nil      // directly update binding
                                viewModel.savePlaces()    // persist change
                            }
                            .buttonStyle(CardButtonStyle(color: .red))
                        }
                    }
                    .padding(.horizontal)
                }
                .cardStyle()
                .onTapGesture { flipCard() }
            } else {
                VStack(spacing: 16) {
                    Text(place.name).font(.title).bold()
                    Text(place.location).font(.subheadline).foregroundColor(.secondary)
                    Text(place.description).font(.body).multilineTextAlignment(.center).padding()
                }
                .cardStyle(background: Color(white: 0.95))
                .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                .onTapGesture { flipCard() }
            }
        }
        .rotation3DEffect(Angle(degrees: rotation), axis: (x: 0, y: 1, z: 0), perspective: 0.6)
        .frame(height: 350)
        .padding()
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(sourceType: imagePickerSource) { image in
                if let image = image {
                    do {
                        let path = try FileHelper.saveImage(image, withName: "\(place.id).jpg")
                        place.imagePath = path       // update binding
                        viewModel.savePlaces()       // persist change
                    } catch {
                        print("❌ Failed to save image: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    private func flipCard() {
        withAnimation(.easeInOut(duration: 0.6)) {
            rotation += 180
            isFlipped.toggle()
        }
    }
}

struct CardButtonStyle: ButtonStyle {
    var color: Color
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .frame(maxWidth: .infinity)
            .background(color.opacity(configuration.isPressed ? 0.5 : 0.7))
            .foregroundColor(.white)
            .cornerRadius(10)
    }
}

extension View {
    func cardStyle(background: Color = .white) -> some View {
        self
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(background)
            .cornerRadius(15)
            .shadow(radius: 5)
    }
}
