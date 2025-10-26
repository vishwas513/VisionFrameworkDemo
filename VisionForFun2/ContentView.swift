//
//  ContentView.swift
//  VisionForFun2
//
//  Created by Vishwas Mukund on 2025-10-26.
//

import SwiftUI
import Vision
import PhotosUI

struct ContentView: View {
    @State private var recognizedText: String = ""
    @State private var status: String = "Ready - Tap to capture or select an image"
    @State private var isProcessing: Bool = false
    @State private var capturedImage: UIImage? = nil
    @State private var showImagePicker: Bool = false
    @State private var imageSourceType: UIImagePickerController.SourceType = .camera
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Image Preview Section
                    VStack(spacing: 12) {
                        Text("Image Preview")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        if let image = capturedImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 300)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(colorScheme == .dark ? Color.gray.opacity(0.3) : Color.gray.opacity(0.2), lineWidth: 1)
                                )
                                .shadow(color: colorScheme == .dark ? .black.opacity(0.5) : .black.opacity(0.1), radius: 8, x: 0, y: 4)
                                .accessibilityLabel("Captured image preview")
                        } else {
                            // Placeholder
                            VStack(spacing: 16) {
                                Image(systemName: "photo.on.rectangle.angled")
                                    .font(.system(size: 60))
                                    .foregroundStyle(.secondary)
                                
                                Text("No image selected")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 300)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(colorScheme == .dark ? Color(.systemGray6) : Color(.systemGray6))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(colorScheme == .dark ? Color.gray.opacity(0.3) : Color.gray.opacity(0.2), lineWidth: 1)
                            )
                        }
                    }
                    
                    // Action Buttons
                    HStack(spacing: 12) {
                        Button(action: {
                            imageSourceType = .camera
                            showImagePicker = true
                        }) {
                            HStack {
                                Image(systemName: "camera.fill")
                                Text("Camera")
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                        }
                        .buttonStyle(.bordered)
                        .tint(.blue)
                        
                        Button(action: {
                            imageSourceType = .photoLibrary
                            showImagePicker = true
                        }) {
                            HStack {
                                Image(systemName: "photo.fill")
                                Text("Library")
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                        }
                        .buttonStyle(.bordered)
                        .tint(.blue)
                    }
                    
                    // Recognition Button
                    Button(action: runTextRecognition) {
                        HStack(spacing: 8) {
                            if isProcessing {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Image(systemName: "text.viewfinder")
                            }
                            Text(isProcessing ? "Recognizing…" : "Recognize Text")
                                .bold()
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(isProcessing || capturedImage == nil)
                    .accessibilityLabel("Run Vision text recognition")
                    
                    // Status and Results Section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "info.circle.fill")
                                .foregroundStyle(.secondary)
                            Text(status)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        Divider()
                        
                        Text("Recognized Text")
                            .font(.headline)
                        
                        if recognizedText.isEmpty {
                            Text("No text recognized yet")
                                .foregroundStyle(.secondary)
                                .italic()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(colorScheme == .dark ? Color(.systemGray6) : Color(.systemGray6))
                                )
                        } else {
                            ScrollView {
                                Text(recognizedText)
                                    .textSelection(.enabled)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding()
                            }
                            .frame(maxHeight: 200)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(colorScheme == .dark ? Color(.systemGray6) : Color(.systemGray6))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(colorScheme == .dark ? Color.gray.opacity(0.3) : Color.gray.opacity(0.2), lineWidth: 1)
                            )
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(colorScheme == .dark ? Color(.systemGray5).opacity(0.5) : Color(.systemGray6).opacity(0.5))
                    )
                }
                .padding()
            }
            .navigationTitle("Vision Text Recognition")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(sourceType: imageSourceType) { image in
                    capturedImage = image
                    status = "Image captured - Ready to recognize text"
                    recognizedText = ""
                }
            }
        }
    }

    // MARK: - Vision Text Recognition

    private func runTextRecognition() {
        guard let uiImage = capturedImage, let cgImage = uiImage.cgImage else {
            status = "No suitable image available"
            recognizedText = ""
            return
        }

        isProcessing = true
        status = "Running VNRecognizeTextRequest…"
        recognizedText = ""

        // Configure request
        let request = VNRecognizeTextRequest { request, error in
            DispatchQueue.main.async {
                isProcessing = false
                if let error = error {
                    status = "Failed: \(error.localizedDescription)"
                    return
                }

                let observations = (request.results as? [VNRecognizedTextObservation]) ?? []
                let lines: [String] = observations.compactMap { obs in
                    // Highest confidence candidate per observation
                    obs.topCandidates(1).first?.string
                }
                recognizedText = lines.joined(separator: "\n")
                status = lines.isEmpty ? "Completed: No text found" : "Completed: \(lines.count) line(s) recognized"
            }
        }

        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        request.minimumTextHeight = 0.02 // Helps small text in larger images

        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                DispatchQueue.main.async {
                    isProcessing = false
                    status = "Failed to perform request: \(error.localizedDescription)"
                }
            }
        }
    }
}

// MARK: - Image Picker Wrapper

struct ImagePicker: UIViewControllerRepresentable {
    let sourceType: UIImagePickerController.SourceType
    let onImagePicked: (UIImage) -> Void
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.onImagePicked(image)
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

#Preview {
    ContentView()
}
