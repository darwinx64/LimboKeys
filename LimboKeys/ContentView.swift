//
//  ContentView.swift
//  LimboKeys
//
//  Created by tiramisu on 9/4/24.
//

import SwiftUI
import AppKit
import AVFoundation
import ConfettiSwiftUI

class AudioPlayer: ObservableObject {
    var player: AVAudioPlayer?
    
    func playSound(named soundName: String) {
        guard let url = Bundle.main.url(forResource: soundName, withExtension: "mp3") else {
            return
        }
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.play()
        } catch {
            print("error playing sound: \(error.localizedDescription)")
        }
    }
    
    func stopSound() {
        player?.stop()
    }
}


struct ContentView: View {
    @State private var isStartButtonVisible = true
    @State private var keysAvailable = false
    @State private var keyShouldPulse = false
    @State private var keySelected = 0
    @State private var effectCounter = 0
    @State private var showAlert = false
    @State private var selectionCorrect = false
    @State private var keysOrder = Array(0..<8)
    @StateObject var audioPlayer = AudioPlayer()
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            VisualEffectView()
                .edgesIgnoringSafeArea(.all)
            VStack {
                ZStack {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 50), count: 2), spacing: 20) {
                        ForEach(keysOrder, id:\.self) { i in
                            Button(action: {chooseKey(index: i)}) {
                                Image(systemName: "key.horizontal.fill")
                                    .font(.system(size: 40))
                                    .foregroundStyle((keyShouldPulse && i == keySelected) ? (colorScheme == .dark ? Color.white : Color.black) : .accentColor)
                                    .animation(.easeIn(duration: 0.5), value: (keyShouldPulse && i == keySelected))
                                    .allowsHitTesting(keysAvailable)
                            }.buttonStyle(PlainButtonStyle())
                                .alert(isPresented: $showAlert) {
                                    Alert(
                                        title: Text(selectionCorrect ? "Correct!" : "Incorrect"),
                                        dismissButton: .default(Text("OK"))
                                    )
                                }
                                .confettiCannon(counter: $effectCounter)
                        }
                    }
                    .padding(40)
                    .animation(.default, value: keysOrder)
                }
                Button(action: start) {
                    Text("Start")
                }
                .padding(isStartButtonVisible ? 20 : 0)
                .opacity(isStartButtonVisible ? 1 : 0)
                .frame(width: isStartButtonVisible ? 100 : 0, height: isStartButtonVisible ? 20 : 0)
                .animation(.easeIn(duration: 0.5), value: isStartButtonVisible)
                .allowsHitTesting(isStartButtonVisible)
            }
        }
        .onAppear {
            if let window = NSApplication.shared.windows.first {
                window.titlebarAppearsTransparent = true
                window.isMovableByWindowBackground = true
                window.backgroundColor = .clear
            }
        }
    }
    
    private func start() {
        withAnimation {
            isStartButtonVisible = false
        }
        
        audioPlayer.playSound(named: "Song")
        
        keySelected = Int.random(in: 0..<8)
        keyShouldPulse = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            keyShouldPulse = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 15) {
            keysAvailable = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.9) {
            for i in 1...23 {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.4) {
                    keysOrder.shuffle()
                }
            }
        }
    }
    
    private func chooseKey(index : Int) {
        print("chose \(index)")
        if index == keySelected {
            selectionCorrect = true
            effectCounter += 1
        }
        showAlert = true
        keysAvailable = false
    }
}

struct VisualEffectView: NSViewRepresentable {
    func makeNSView(context: Context) -> NSVisualEffectView {
        let effectView = NSVisualEffectView()
        effectView.blendingMode = .behindWindow
        effectView.material = .underWindowBackground
        effectView.state = .active
        return effectView
    }
    
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
    }
}

#Preview {
    ContentView()
}
