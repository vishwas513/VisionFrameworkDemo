//
//  BodyPoseDetectionView.swift
//  VisionForFun2
//
//  Created by Vishwas Mukund on 2025-10-26.
//

import SwiftUI
import Vision

struct BodyPoseDetectionView: View {
    @State private var status: String = "Ready - Tap to capture or select an image"
    @State private var isProcessing: Bool = false
    @State private var capturedImage: UIImage? = nil
    @State private var processedImage: UIImage? = nil
    @State private var imageSourceType: UIImagePickerController.SourceType? = nil
    @State private var detectedPeopleCount: Int = 0
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Image Preview Section
                imagePreviewSection
                
                // Action Buttons
                actionButtonsSection
                
                // Detection Button
                detectionButton
                
                // Status Section
                statusSection
            }
            .padding()
        }
        .navigationTitle("Body Pose Detection")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: Binding(
            get: { imageSourceType.map { SourceTypeWrapper(sourceType: $0) } },
            set: { imageSourceType = $0?.sourceType }
        )) { wrapper in
            ImagePicker(sourceType: wrapper.sourceType) { image in
                capturedImage = image
                processedImage = nil
                detectedPeopleCount = 0
                status = "Image captured - Ready to detect poses"
                imageSourceType = nil
            }
        }
    }
    
    // MARK: - View Components
    
    private var imagePreviewSection: some View {
        VStack(spacing: 12) {
            Text("Image Preview")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            if let image = processedImage ?? capturedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 400)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(colorScheme == .dark ? Color.gray.opacity(0.3) : Color.gray.opacity(0.2), lineWidth: 1)
                    )
                    .shadow(color: colorScheme == .dark ? .black.opacity(0.5) : .black.opacity(0.1), radius: 8, x: 0, y: 4)
                    .accessibilityLabel(processedImage != nil ? "Image with detected body poses" : "Captured image preview")
            } else {
                placeholderView
            }
        }
    }
    
    private var placeholderView: some View {
        VStack(spacing: 16) {
            Image(systemName: "figure.walk")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            
            Text("No image selected")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 400)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(colorScheme == .dark ? Color(.systemGray6) : Color(.systemGray6))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(colorScheme == .dark ? Color.gray.opacity(0.3) : Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
    
    private var actionButtonsSection: some View {
        HStack(spacing: 12) {
            Button(action: {
                imageSourceType = .camera
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
    }
    
    private var detectionButton: some View {
        Button(action: runBodyPoseDetection) {
            HStack(spacing: 8) {
                if isProcessing {
                    ProgressView()
                        .tint(.white)
                } else {
                    Image(systemName: "figure.walk.motion")
                }
                Text(isProcessing ? "Detecting…" : "Detect Body Poses")
                    .bold()
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
        }
        .buttonStyle(.borderedProminent)
        .disabled(isProcessing || capturedImage == nil)
        .accessibilityLabel("Run body pose detection")
    }
    
    private var statusSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "info.circle.fill")
                    .foregroundStyle(.secondary)
                Text(status)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            if detectedPeopleCount > 0 {
                Divider()
                
                HStack(spacing: 8) {
                    Image(systemName: "person.2.fill")
                        .foregroundStyle(.green)
                    Text("Detected \(detectedPeopleCount) person\(detectedPeopleCount == 1 ? "" : "s")")
                        .font(.subheadline)
                        .bold()
                        .foregroundStyle(.green)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(colorScheme == .dark ? Color(.systemGray5).opacity(0.5) : Color(.systemGray6).opacity(0.5))
        )
    }

    // MARK: - Vision Body Pose Detection

    private func runBodyPoseDetection() {
        guard let uiImage = capturedImage, let cgImage = uiImage.cgImage else {
            status = "No suitable image available"
            return
        }

        isProcessing = true
        status = "Running VNDetectHumanBodyPoseRequest…"
        detectedPeopleCount = 0
        processedImage = nil

        let request = VNDetectHumanBodyPoseRequest()
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
                
                guard let observations = request.results, !observations.isEmpty else {
                    DispatchQueue.main.async {
                        isProcessing = false
                        status = "No human bodies detected"
                        detectedPeopleCount = 0
                    }
                    return
                }
                
                // Draw skeleton on image
                let imageWithPoses = drawSkeletons(on: uiImage, observations: observations)
                
                DispatchQueue.main.async {
                    isProcessing = false
                    detectedPeopleCount = observations.count
                    processedImage = imageWithPoses
                    status = "Completed: Detected \(observations.count) person\(observations.count == 1 ? "" : "s")"
                }
                
            } catch {
                DispatchQueue.main.async {
                    isProcessing = false
                    status = "Failed to perform request: \(error.localizedDescription)"
                }
            }
        }
    }
    
    // MARK: - Drawing Functions
    
    private func drawSkeletons(on image: UIImage, observations: [VNHumanBodyPoseObservation]) -> UIImage {
        let imageSize = image.size
        let scale = image.scale
        
        UIGraphicsBeginImageContextWithOptions(imageSize, false, scale)
        image.draw(at: .zero)
        
        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return image
        }
        
        // Define colors for different people
        let colors: [UIColor] = [.systemGreen, .systemBlue, .systemPurple, .systemOrange, .systemPink, .systemYellow]
        
        for (index, observation) in observations.enumerated() {
            let color = colors[index % colors.count]
            drawSkeleton(observation: observation, in: context, imageSize: imageSize, color: color)
        }
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext() ?? image
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    private func drawSkeleton(observation: VNHumanBodyPoseObservation, in context: CGContext, imageSize: CGSize, color: UIColor) {
        // Define body connections (skeleton structure)
        let connections: [(VNHumanBodyPoseObservation.JointName, VNHumanBodyPoseObservation.JointName)] = [
            // Torso
            (.neck, .rightShoulder),
            (.neck, .leftShoulder),
            (.rightShoulder, .rightHip),
            (.leftShoulder, .leftHip),
            (.rightHip, .leftHip),
            
            // Right Arm
            (.rightShoulder, .rightElbow),
            (.rightElbow, .rightWrist),
            
            // Left Arm
            (.leftShoulder, .leftElbow),
            (.leftElbow, .leftWrist),
            
            // Right Leg
            (.rightHip, .rightKnee),
            (.rightKnee, .rightAnkle),
            
            // Left Leg
            (.leftHip, .leftKnee),
            (.leftKnee, .leftAnkle),
        ]
        
        // Get all recognized points
        guard let recognizedPoints = try? observation.recognizedPoints(.all) else { return }
        
        // Draw connections
        context.setStrokeColor(color.cgColor)
        context.setLineWidth(3.0)
        context.setLineCap(.round)
        
        for (startJoint, endJoint) in connections {
            guard let startPoint = recognizedPoints[startJoint],
                  let endPoint = recognizedPoints[endJoint],
                  startPoint.confidence > 0.3,
                  endPoint.confidence > 0.3 else {
                continue
            }
            
            let startCGPoint = convertPoint(startPoint.location, imageSize: imageSize)
            let endCGPoint = convertPoint(endPoint.location, imageSize: imageSize)
            
            context.move(to: startCGPoint)
            context.addLine(to: endCGPoint)
            context.strokePath()
        }
        
        // Draw joints
        context.setFillColor(color.cgColor)
        
        for (_, point) in recognizedPoints {
            guard point.confidence > 0.3 else { continue }
            
            let cgPoint = convertPoint(point.location, imageSize: imageSize)
            let radius: CGFloat = 6.0
            
            context.fillEllipse(in: CGRect(
                x: cgPoint.x - radius,
                y: cgPoint.y - radius,
                width: radius * 2,
                height: radius * 2
            ))
        }
    }
    
    private func convertPoint(_ point: CGPoint, imageSize: CGSize) -> CGPoint {
        // Vision coordinates are normalized (0-1) with origin at bottom-left
        // UIKit coordinates have origin at top-left
        return CGPoint(
            x: point.x * imageSize.width,
            y: (1 - point.y) * imageSize.height
        )
    }
}

#Preview {
    NavigationStack {
        BodyPoseDetectionView()
    }
}

