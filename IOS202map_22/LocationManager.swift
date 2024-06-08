//
//  LocationManager.swift
//  IOS202map_22
//
//  Created by cmStudent on 2024/05/10.
//

import Foundation
import MapKit

@MainActor
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    var manager = CLLocationManager()
    
    @Published var transport: MKDirectionsTransportType = .any
    @Published var results: [MKMapItem] = []
    @Published var transitTime: Int = 0
    static let dev: [Station] = [
        Station(name: "大久保", prefecture: "東京都", line: "JR総武線", x: 139.69732, y: 35.700784, postal: "1690073", distance: "220m", prev: nil, next: "新宿"),
        Station(name: "大久保", prefecture: "東京都", line: "JR総武線", x: 139.69732, y: 35.700784, postal: "1690073", distance: "220m", prev: nil, next: "新宿"),
        Station(name: "大久保", prefecture: "東京都", line: "JR総武線", x: 139.69732, y: 35.700784, postal: "1690073", distance: "220m", prev: nil, next: "新宿"),
        Station(name: "大久保", prefecture: "東京都", line: "JR総武線", x: 139.69732, y: 35.700784, postal: "1690073", distance: "220m", prev: nil, next: "新宿")
        
    ]
    
    
    // 35.80872144507752, 139.4466782203013
    static let spots: [MenuSpotModel] = [
        MenuSpotModel(title: "自宅", location: CLLocationCoordinate2D(latitude: 35.80872144507752, longitude: 139.4466782203013)),
        MenuSpotModel(title: "レストラン", location: CLLocationCoordinate2D(latitude: 35.80872144507752, longitude: 139.4466782203013)),
        MenuSpotModel(title: "コーヒー", location: CLLocationCoordinate2D(latitude: 35.80872144507752, longitude: 139.4466782203013)),
        MenuSpotModel(title: "ショッピング", location: CLLocationCoordinate2D(latitude: 35.80872144507752, longitude: 139.4466782203013)),
        MenuSpotModel(title: "アパレル", location: CLLocationCoordinate2D(latitude: 35.80872144507752, longitude: 139.4466782203013)),
        MenuSpotModel(title: "ラーメン", location: CLLocationCoordinate2D(latitude: 35.80872144507752, longitude: 139.4466782203013)),
        MenuSpotModel(title: "駐車場", location: CLLocationCoordinate2D(latitude: 35.80872144507752, longitude: 139.4466782203013))
    ]
    
    @Published var region = MKCoordinateRegion()
    @Published var mapLocation = CLLocationCoordinate2D()
    @Published var xPosition: CGFloat = 0
    @Published var yPosition: CGFloat = 0
    @Published var isShowSheet: Bool = false
    @Published var route: MKRoute?
    @Published var userLocation = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    
    override init() {
        super.init()
        manager.delegate = self
        manager.requestWhenInUseAuthorization() // 権限の許可をリクエストするメソッド
        manager.desiredAccuracy = kCLLocationAccuracyBest //
        manager.distanceFilter = 2
        manager.startUpdatingLocation()
        mapLocation = region.center
        
        
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locations.last.map {
            let center = CLLocationCoordinate2D(
                latitude: $0.coordinate.latitude,
                longitude: $0.coordinate.longitude)
            
            region = MKCoordinateRegion(
                center: center,
                latitudinalMeters: 1000.0,
                longitudinalMeters: 1000.0
            )
        }
    }
    
    
    func updateRegion(center: CLLocationCoordinate2D) {
        self.region = MKCoordinateRegion(center: center, latitudinalMeters: 0.1, longitudinalMeters: 0.1)
    }
     
    
    func calculateRoute(
        from: CLLocationCoordinate2D,
        to: CLLocationCoordinate2D,
        transportType: MKDirectionsTransportType) async {
            
            // MapItemを作るためのPlacemarkを宣言
            let fromPlacemark = MKPlacemark(coordinate: from)
            let toPlacemark = MKPlacemark(coordinate: to)
            
            // Routeを取得するためのRequest
            let request = MKDirections.Request() // リクエストを作成
            request.source = MKMapItem(placemark: fromPlacemark) // 出発の位置をセットする
            request.destination = MKMapItem(placemark: toPlacemark) // 到着の位置をセットする
            request.transportType = transportType // 交通機関をセットする
            
            
            
            if request.transportType == .transit { // 電車の場合
                let directions = MKDirections(request: request) // 時間と距離を計算するオブジェクトを生成する
                do {
                    let etaResponse = try await directions.calculateETA() // 到着する予定
                    let etaSecond = etaResponse.expectedTravelTime // 行くには何秒かかるか
                    let etaMinutes = Int(etaSecond / 60)
                    self.transitTime = etaMinutes
                    print("EAT:\(etaMinutes)")
                } catch {
                    print("error: \(error.localizedDescription)")
                }
            } else { // 歩く、自転車、車の場合
                do {
                    let directions = MKDirections(request: request)
                    let response = try await directions.calculate()
                    let routes = response.routes
                    self.route = routes.first
                } catch {
                    print("error: \(error.localizedDescription)")
                }
            }
        }
    
    
    func searchPlaces(keyword: String) async {
        let req = MKLocalSearch.Request()
        req.naturalLanguageQuery = keyword
        req.resultTypes = .pointOfInterest
        req.region = region
        
        Task {
            let search = MKLocalSearch(request: req)
            let response = try? await search.start()
            self.results = response?.mapItems ?? []
        }
       
    }
}

