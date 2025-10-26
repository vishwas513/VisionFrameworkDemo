//
//  ContentView.swift
//  VisionForFun2
//
//  Created by Vishwas Mukund on 2025-10-26.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    headerSection
                    
                    // Feature Cards
                    VStack(spacing: 16) {
                        NavigationLink(destination: TextRecognitionView()) {
                            FeatureCard(
                                icon: "doc.text.viewfinder",
                                title: "Text Recognition",
                                description: "Extract and recognize text from images using Vision framework",
                                gradient: [.blue, .cyan]
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        NavigationLink(destination: BodyPoseDetectionView()) {
                            FeatureCard(
                                icon: "figure.walk.motion",
                                title: "Body Pose Detection",
                                description: "Detect and track human body poses with skeleton overlay",
                                gradient: [.green, .mint]
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    // Info Section
                    infoSection
                }
                .padding()
            }
            .navigationTitle("Vision Demos")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    // MARK: - View Components
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "eye.fill")
                .font(.system(size: 60))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            Text("Vision Framework Demos")
                .font(.title2)
                .bold()
            
            Text("Explore on-device computer vision capabilities")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 20)
    }
    
    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "info.circle.fill")
                    .foregroundStyle(.blue)
                Text("About")
                    .font(.headline)
            }
            
            Text("All processing happens on-device using Apple's Vision framework. No data is sent to external servers.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(colorScheme == .dark ? Color(.systemGray6).opacity(0.5) : Color(.systemGray6).opacity(0.8))
        )
    }
}

// MARK: - Feature Card Component

struct FeatureCard: View {
    let icon: String
    let title: String
    let description: String
    let gradient: [Color]
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: gradient,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)
                
                Image(systemName: icon)
                    .font(.system(size: 28))
                    .foregroundStyle(.white)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            // Chevron
            Image(systemName: "chevron.right")
                .foregroundStyle(.secondary)
                .font(.system(size: 14, weight: .semibold))
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(colorScheme == .dark ? Color(.systemGray6) : .white)
                .shadow(color: colorScheme == .dark ? .clear : .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(colorScheme == .dark ? Color.gray.opacity(0.3) : Color.clear, lineWidth: 1)
        )
    }
}

#Preview {
    ContentView()
}
