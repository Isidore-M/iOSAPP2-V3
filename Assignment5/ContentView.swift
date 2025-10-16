//
//  ContentView.swift
//  Assignment5
//
//  Created by Eezy Mongo on 2025-10-15.
//

import SwiftUI
import PDFKit

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = PlacesViewModel()
    @State private var showPDF = false
    
    var body: some View {
        NavigationView {
            List {
                // Pass a binding of each Place to FlippableCardView
                ForEach($viewModel.places) { $place in
                    NavigationLink(destination: FlippableCardView(place: $place, viewModel: viewModel)) {
                        PlaceRow(place: place)
                    }
                }
            }
            .listStyle(PlainListStyle())
            .navigationTitle("Places to Visit")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Generate Report") {
                        viewModel.generatePDF()
                        showPDF = true
                    }
                }
            }
            .sheet(isPresented: $showPDF) {
                if let url = viewModel.generatedPDFURL {
                    PDFKitView(url: url)
                }
            }
        }
    }
}

struct PlaceRow: View {
    var place: Place
    
    var body: some View {
        HStack(spacing: 16) {
            if let path = place.imagePath,
               let uiImage = UIImage(contentsOfFile: path) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                    .foregroundColor(.gray)
                    .opacity(0.5)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(place.name)
                    .font(.headline)
                Text(place.location)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 6)
    }
}
#Preview {
    HomeView()
}
