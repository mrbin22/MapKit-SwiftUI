//
//  HomeView.swift
//  IOS202map_22
//
//  Created by cmStudent on 2024/05/10.
//

import SwiftUI
import MapKit

struct HomeView: View {
    @Namespace var mapScope
    @EnvironmentObject var manager: LocationManager
    @StateObject var network = NetworkManager()
    @State private var searchText = ""
    @State private var xPosition: CGFloat = 0
    @State private var yPosition: CGFloat = 0
    // 35.80712234947154, 139.45623598023406
//    @State private var region = MKCoordinateRegion(center: .jec, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
    @State private var cameraPosition: MapCameraPosition = .region(MKCoordinateRegion(
        center: .jec,
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)))
    @State private var isShowSheet = false
    @State private var isShowAlert = false
    @State private var selectedResult: MKMapItem?
    @State private var isMapStyleStandard = true
    
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack {
                
                MapReader { mapProxy in
                    Map(position: $cameraPosition, selection: $selectedResult) {
                        UserAnnotation(anchor: .center) { userAnotation in
                            VStack {
                                Image(systemName: "figure.wave")
                                    .foregroundColor(.red)
                                    .scaleEffect(2)
                            }
                        }
                        if let routePolyline = manager.route?.polyline {
                            MapPolyline(routePolyline)
                                .stroke(.blue, lineWidth: 5)
                        }
                        
                        
                        ForEach(manager.results, id: \.self) { item in
                            Marker(item.name ?? "", coordinate: item.placemark.coordinate)
                        }
                        
                    }
                    .mapStyle(isMapStyleStandard ? .standard : .hybrid)
                    .overlay(alignment: .top) {
                        VStack(spacing: 0) {
                            TextField("住所を入力してください", text: $searchText)
                                .frame(height: 55)
                                .font(.subheadline)
                                .padding(12)
                                .textFieldStyle(.roundedBorder)
                            .shadow(radius: 10)
                            FilterMenuBarView()
                                .padding(.horizontal)
                        }
                    }
                    .onChange(of: selectedResult, { oldValue, newValue in
                        isShowSheet = newValue != nil
                        
                    })
                    .sheet(isPresented: $isShowSheet, content: {
                        ItemInfoView(mapSelection: $selectedResult, show: $isShowSheet, currentLocation: CLLocationCoordinate2D(latitude: xPosition, longitude: yPosition))
                            .presentationDetents([.height(340)])
                            .presentationBackgroundInteraction(
                                .enabled(upThrough: .height(340))) // sheetが表示されている時でもMapを操作できる
                            .presentationCornerRadius(12)
                        
                    })
                    .onSubmit {
                        Task { await manager.searchPlaces(keyword: searchText) }
                       
                    }
                }
                
                
                HStack(spacing: 50) {
                    Button(action: {
                        manager.isShowSheet.toggle()
                        manager.transport = .walking
                        Task {
                            await network.getData(x: manager.region.center.latitude ,y: manager.region.center.longitude)
                            
                        }
                    }, label: {
                        Image(systemName: "figure.walk")
                    })
                    
                    Button(action: {
                        manager.isShowSheet.toggle()
                        manager.transport = .any
                        Task {
                            await network.getData(x: manager.region.center.latitude ,y: manager.region.center.longitude)
                            
                        }
                    }, label: {
                        Image(systemName: "bicycle")
                    })
                    
                    Button(action: {
                        manager.isShowSheet.toggle()
                        manager.transport = .automobile
                        Task {
                            await network.getData(x: manager.region.center.latitude ,y: manager.region.center.longitude)
                           
                        }
                    }, label: {
                        Image(systemName: "car.fill")
                    })
                    
                    Button(action: {
                        manager.isShowSheet.toggle()
                        manager.transport = .transit
                        Task {
                            await network.getData(x: manager.region.center.latitude ,y: manager.region.center.longitude)
                           
                        }
                    }, label: {
                        Image(systemName: "tram.fill")
                    })
                    
                }
            }
            .alert("時刻表", isPresented: $isShowAlert, actions: {
                Button("確認") {
                    isShowAlert.toggle()
                }
            }, message: {
                Text("電車でかかる時間は: \(manager.transitTime)")
            })
            
            .sheet(isPresented: $manager.isShowSheet, content: {
                
                ListStationView(nearestStation: network.stations?.response.station ?? LocationManager.dev, isShowAlert: $isShowAlert)
        })
            
            Button(action: {
                isMapStyleStandard.toggle()
            }, label: {
                Image(systemName: isMapStyleStandard ? "building.2" : "map.fill")
                    .tint(.yellow)
                    .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                    .background(
                        Circle()
                            .fill(.red)
                            .frame(width: 50, height: 100)
                            .opacity(1)
                    )
            })
            .padding(.vertical, 50)
            .padding(.horizontal)
            
        }
    }
    
}
#Preview {
    HomeView()
        .environmentObject(LocationManager())
}

extension CLLocationCoordinate2D {
    static let jec = CLLocationCoordinate2D(latitude: 35.6989221, longitude: 139.6966153)
}
