//
//  ContentView.swift
//  Assignment5
//
//  Created by Eezy Mongo on 2025-10-15.
//
import SwiftUI
import PDFKit

struct HomeView: View {
    @StateObject private var viewModel = PlacesViewModel()
    @State private var showPDF = false

    var body: some View {
        NavigationView {
            List(viewModel.places) { place in
                NavigationLink(destination: FlippableCardView(viewModel: viewModel, place: place)) {
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
            .listStyle(PlainListStyle())
            .navigationTitle("Places to Visit")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Generate Report") {
                        viewModel.generatePDFReport()
                        if viewModel.generatedPDFURL != nil {
                            showPDF = true
                        }
                    }
                }
            }
            .sheet(isPresented: $showPDF) {
                if let pdfURL = viewModel.generatedPDFURL {
                    PDFKitView(url: pdfURL)
                }
            }
        }
    }
}

#Preview {
    HomeView()
}
