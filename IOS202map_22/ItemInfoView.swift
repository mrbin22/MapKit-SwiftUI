//
//  ItemInfoView.swift
//  IOS202map_22
//
//  Created by cmStudent on 2024/05/14.
//

import SwiftUI
import MapKit
struct ItemInfoView: View {
    @Binding var mapSelection: MKMapItem?
    @Binding var show: Bool
    @State private var lookAroundScene: MKLookAroundScene?
    @EnvironmentObject var manager: LocationManager
    var currentLocation: CLLocationCoordinate2D
    

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                VStack(alignment: .leading) {
                    Text(mapSelection?.placemark.name ?? "")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text(mapSelection?.placemark.title ?? "")
                        .font(.footnote)
                        .foregroundStyle(.gray)
                        .lineLimit(3)
                        .padding(.trailing)
                }
                
                Spacer()
                Button(action: {
                    show.toggle()
                    mapSelection = nil
                    
                }, label: {
                    Image(systemName: "xmark.circle.fill")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundStyle(.gray)
                })
            }
            
            
            Button(action: {
                // 現在地から目的までのルートを表示する
                Task {
                    await manager.calculateRoute(from: currentLocation,to: mapSelection?.placemark.coordinate ?? CLLocationCoordinate2D(),transportType: .automobile)
                }
                
            }, label: {
                Text("ルート")
                    .foregroundStyle(.white)
                    .font(.headline)
            })
            .padding(10)
            .background(Color.blue)
            .cornerRadius(10)
            
            
            
            
            if let scene = lookAroundScene {
                LookAroundPreview(initialScene: scene)
                    .frame(height: 200)
                    .cornerRadius(12)
                    .padding()
            } else {
                ContentUnavailableView("画面が存在しません", systemImage: "eye.slash")
            }
        }
        .padding()
        .onAppear {
            fetchLookAroundPreview()
        }
        .onChange(of: mapSelection) { oldValue, newValue in
            fetchLookAroundPreview()
        }
    }
    
    func fetchLookAroundPreview() {
        if let mapSelection {
            lookAroundScene = nil
            Task {
                let request = MKLookAroundSceneRequest(mapItem: mapSelection)
                lookAroundScene = try? await request.scene
            }
        }
    }
}

#Preview {
    ItemInfoView(mapSelection: .constant(nil), show: .constant(false), currentLocation: CLLocationCoordinate2D())
        .environmentObject(LocationManager())
}
