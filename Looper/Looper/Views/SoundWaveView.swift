//
//  SoundWaveView.swift
//  Looper
//
//  Created by Max Lee on 2025-08-28.
//

import SwiftUI
import FDWaveformView

struct SoundWaveView: UIViewRepresentable {
    var audioURL: URL
    
    func makeUIView(context: Context) -> FDWaveformView {
        let waveformView = FDWaveformView()
        waveformView.audioURL = audioURL
        waveformView.doesAllowScroll = false
        waveformView.doesAllowStretch = false
        waveformView.doesAllowScrubbing = false  // no tap-to-seek
        waveformView.wavesColor = .systemBlue
        waveformView.layer.cornerRadius = 8
        return waveformView
    }
    
    func updateUIView(_ uiView: FDWaveformView, context: Context) {}
}
