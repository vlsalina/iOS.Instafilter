//
//  ContentView.swift
//  Instafilter
//
//  Created by Vincent Salinas on 9/12/22.
//

import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

struct ContentView: View {
    @State private var image: Image?
    @State private var inputImage: UIImage?
    @State private var filterIntensity = 0.5
    @State private var radiusIntensity = 0.5
    @State private var scaleIntensity = 0.5
    @State private var showingImagePicker = false
    @State private var showingFilterSheet = false
    @State private var processedImage: UIImage?
    @State private var currentFilter: CIFilter = CIFilter.sepiaTone()
    
    @State private var intensityFlag = true
    @State private var radiusFlag = false
    @State private var scaleFlag = false
    
    let context = CIContext()
    
    var body: some View {
        NavigationView {
            VStack {
                ZStack {
                    Rectangle()
                        .fill(.secondary)
                    
                    Text("Tap to select a picture")
                        .foregroundColor(.white)
                        .font(.headline)
                    
                    image?
                        .resizable()
                        .scaledToFit()
                }
                .onTapGesture {
                    // select an image
                    showingImagePicker = true
                }
                
                HStack {
                    Text("Intensity")
                    Slider(value: $filterIntensity)
                        .disabled(!intensityFlag)
                        .onChange(of: filterIntensity) { _ in
                            applyProcessing()
                        }
                }
                .padding(.vertical)
                
                HStack {
                    Text("Radius   ")
                    Slider(value: $radiusIntensity)
                        .disabled(!radiusFlag)
                        .onChange(of: radiusIntensity) { _ in
                            applyProcessing()
                        }
                }
                .padding(.bottom)
                
                HStack {
                    Text("Scale     ")
                    Slider(value: $scaleIntensity)
                        .disabled(!scaleFlag)
                        .onChange(of: scaleIntensity) { _ in
                            applyProcessing()
                        }
                }
                .padding(.bottom)
                
                
                HStack {
                    Button("Change Filter") {
                        // change filter
                        
                        showingFilterSheet = true
                    }
                    .confirmationDialog("Select a filter", isPresented: $showingFilterSheet) {
                        // dialog here
                        Group {
                            Button("Crystallize") {
                                setFilter(CIFilter.crystallize())
                                toDisable()
                            }
                            Button("Edges") {
                                setFilter(CIFilter.edges())
                                toDisable()
                            }
                            Button("Gaussian Blur") {
                                setFilter(CIFilter.gaussianBlur())
                                toDisable()
                            }
                            Button("Pixellate") {
                                setFilter(CIFilter.pixellate())
                                toDisable()
                            }
                            Button("Sepia Tone") {
                                setFilter(CIFilter.sepiaTone())
                                toDisable()
                            }
                            Button("Unsharp Mask") {
                                setFilter(CIFilter.unsharpMask())
                                toDisable()
                            }
                            Button("Vignette") {
                                setFilter(CIFilter.vignette())
                                toDisable()
                            }
                            Button("Pointillize") {
                                setFilter(CIFilter.pointillize())
                                toDisable()
                            }
                            Button("Circular Wrap") {
                                setFilter(CIFilter.circularWrap())
                                toDisable()
                            }
                            Button("Photo Effect Instant") {
                                setFilter(CIFilter.photoEffectInstant())
                                toDisable()
                            }
                        }
                        Button("Cancel", role: .cancel) { }
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        save()
                    }) {
                        // save the picture
                        Text("Save")
                    }
                    .disabled((image != nil) ? false : true)
                }
            }
            .padding([.horizontal, .bottom])
            .navigationTitle("Instafilter")
            .onChange(of: inputImage) { _ in loadImage() }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $inputImage)
            }
        }
    }
    
    func loadImage() {
        guard let inputImage = inputImage else { return }
        
        let beginImage = CIImage(image: inputImage)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        applyProcessing()
    }
    
    func save() {
        guard let processedImage = processedImage else { return }
        
        let imageSaver = ImageSaver()
        
        imageSaver.successHandler = {
            print("Success!")
        }
        
        imageSaver.errorHandler = {
            print("Oops: \($0.localizedDescription)")
        }
        
        imageSaver.writeToPhotoAlbum(image: processedImage)
    }
    
    func toDisable() {
        let inputKeys = currentFilter.inputKeys
        
        if inputKeys.contains(kCIInputIntensityKey) {
            intensityFlag = true
            radiusFlag = false
            scaleFlag = false
        }
        if inputKeys.contains(kCIInputRadiusKey) {
            intensityFlag = false
            radiusFlag = true
            scaleFlag = false
        }
        if inputKeys.contains(kCIInputScaleKey) {
            intensityFlag = false
            radiusFlag = false
            scaleFlag = true
        }
    }
    
    func applyProcessing() {
        let inputKeys = currentFilter.inputKeys
        
        if inputKeys.contains(kCIInputIntensityKey) { currentFilter.setValue(filterIntensity, forKey: kCIInputIntensityKey) }
        if inputKeys.contains(kCIInputRadiusKey) { currentFilter.setValue(radiusIntensity * 200, forKey: kCIInputRadiusKey) }
        if inputKeys.contains(kCIInputScaleKey) { currentFilter.setValue(scaleIntensity * 10, forKey: kCIInputScaleKey) }
        
        guard let outputImage = currentFilter.outputImage else { return }
        
        if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
            let uiImage = UIImage(cgImage: cgimg)
            image = Image(uiImage: uiImage)
            processedImage = uiImage
        }
    }
    
    func setFilter(_ filter: CIFilter) {
        currentFilter = filter
        loadImage()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
