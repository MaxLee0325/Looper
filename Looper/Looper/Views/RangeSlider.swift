//
//  RangeSlider.swift
//  Looper
//
//  Created by Max Lee on 2025-08-29.
//

import SwiftUI

struct RangeSlider: View {
    @Binding var start: Double
    @Binding var end: Double
    var url: URL
    var maxValue: Double
    
    @State private var startDragValue: Double = 0
    @State private var endDragValue: Double = 0
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Track
                SoundWaveView(audioURL: url)
                    .frame(height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous)) // Smoother corners
                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4) // Soft shadow
                    .padding(.vertical, 8)
                
                // Dimmed area outside selection
                Color.black.opacity(0.4)
                    .frame(width: geo.size.width, height: 120)
                    .mask(
                        HStack(spacing: 0) {
                            Rectangle().frame(width: (start / maxValue) * geo.size.width)
                            Spacer(minLength: 0)
                            Rectangle().frame(width: (1 - end / maxValue) * geo.size.width)
                        }
                    )
                                
                // Start Handle
                Rectangle()
                    .fill(Color.white)
                    .frame(width: 4, height: 120)
                    .shadow(radius: 1)
                    .position(x: (start / maxValue) * geo.size.width, y: geo.size.height / 2)
                    .gesture(
                        DragGesture()
                        .onChanged { value in
                            let ratio = (value.startLocation.x + value.translation.width) / geo.size.width
                            let clamped = min(max(0, ratio), end / maxValue)
                            start = clamped * maxValue
                        }
                    )
                                
                // End Handle
                Rectangle()
                    .fill(Color.white)
                    .frame(width: 4, height: 120)
                    .shadow(radius: 1)
                    .position(x: (end / maxValue) * geo.size.width, y: geo.size.height / 2)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                let ratio = (value.startLocation.x + value.translation.width) / geo.size.width
                                let clamped = max(min(1, ratio), start / maxValue)
                                end = clamped * maxValue
                            }
                    )
            }

            .onAppear {
                startDragValue = start
                endDragValue = end
            }
        }
    }
}

