//
//  FlippableCardView.swift
//  Assignment5
//
//  Created by Eezy Mongo on 2025-10-15.
//

import SwiftUI
import UIKit
import MapKit
import ImageIO
import CoreLocation

struct MapPin: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}

struct FlippableCardView: View {
    @ObservedObject var viewModel: PlacesViewModel
    var place: Place

    @State private var rotation = 0.0
    @State private var showingImagePicker = false
    @State private var imagePickerSource: UIImagePickerController.SourceType = .photoLibrary
    @State private var isFlipped = false
    @State private var region: MKCoordinateRegion? = nil

    var body: some View {
        ZStack {
            if !isFlipped {
                VStack(spacing: 16) {
                    // Display image
                    if let path = place.imagePath,
                       let uiImage = UIImage(contentsOfFile: path) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                            .onAppear {
                                updateRegionFromImage(at: path)
                            }

                        // Mini-map with pin
                        if var region = region {
                            Map(
                                coordinateRegion: Binding(get: { region }, set: { region = $0 }),
                                annotationItems: [MapPin(coordinate: region.center)]
                            ) { pin in
                                MapMarker(coordinate: pin.coordinate, tint: .red)
                            }
                            .frame(height: 150)
                            .cornerRadius(10)

                            Text("📍 Lat: \(region.center.latitude), Lon: \(region.center.longitude)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    } else {
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .foregroundColor(.gray)
                            .opacity(0.5)
                            .padding()
                    }

                    // Buttons
                    HStack(spacing: 16) {
                        Button("Select Photo") {
                            imagePickerSource = .photoLibrary
                            showingImagePicker = true
                        }
                        .buttonStyle(CardButtonStyle(background: .blue))

                        Button("Take Photo") {
                            imagePickerSource = .camera
                            showingImagePicker = true
                        }
                        .buttonStyle(CardButtonStyle(background: .green))

                        Button("Remove") {
                            removeImage()
                        }
                        .buttonStyle(CardButtonStyle(background: .red))
                    }
                    .padding(.horizontal)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.white)
                .cornerRadius(15)
                .shadow(radius: 5)
                .onTapGesture { flipCard() }
            } else {
                // Back side
                VStack {
                    Text(place.name)
                        .font(.title)
                        .bold()
                    Text(place.location)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text(place.description)
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .padding()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(white: 0.95))
                .cornerRadius(15)
                .shadow(radius: 5)
                .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                .onTapGesture { flipCard() }
            }
        }
        .rotation3DEffect(
            Angle(degrees: rotation),
            axis: (x: 0, y: 1, z: 0),
            perspective: 0.6
        )
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(sourceType: imagePickerSource) { image in
                if let image = image {
                    viewModel.updateImage(for: place.id, image: image)
                    if let path = viewModel.places.first(where: { $0.id == place.id })?.imagePath {
                        updateRegionFromImage(at: path)
                    }
                }
            }
        }
        .frame(height: 500)
        .padding()
    }

    private func flipCard() {
        withAnimation(.easeInOut(duration: 0.6)) {
            rotation += 180
            isFlipped.toggle()
        }
    }

    private func removeImage() {
        if let index = viewModel.places.firstIndex(where: { $0.id == place.id }) {
            viewModel.places[index].imagePath = nil
            viewModel.savePlaces()
            region = nil
        }
    }

    private func updateRegionFromImage(at path: String) {
        if let loc = getLocationFromImage(at: path) {
            region = MKCoordinateRegion(
                center: loc,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
        } else {
            region = nil
        }
    }

    private func getLocationFromImage(at path: String) -> CLLocationCoordinate2D? {
        let imageURL = URL(fileURLWithPath: path)
        guard let imageSource = CGImageSourceCreateWithURL(imageURL as CFURL, nil),
              let metadata = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as? [CFString: Any],
              let gps = metadata[kCGImagePropertyGPSDictionary] as? [CFString: Any],
              let latitude = gps[kCGImagePropertyGPSLatitude] as? Double,
              let latitudeRef = gps[kCGImagePropertyGPSLatitudeRef] as? String,
              let longitude = gps[kCGImagePropertyGPSLongitude] as? Double,
              let longitudeRef = gps[kCGImagePropertyGPSLongitudeRef] as? String
        else { return nil }

        let lat = latitudeRef == "S" ? -latitude : latitude
        let lon = longitudeRef == "W" ? -longitude : longitude
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
}

struct CardButtonStyle: ButtonStyle {
    var background: Color
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .frame(maxWidth: .infinity)
            .background(background.opacity(configuration.isPressed ? 0.5 : 0.7))
            .foregroundColor(.white)
            .cornerRadius(10)
    }
}
