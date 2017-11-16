//
//  MapController.swift
//
//
//  Created by Andy Kor on 11/4/17.
//

import GoogleMaps
import GooglePlaces
import Firebase

class MapController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapWindow: UIView!
    var ref: DatabaseReference!

    var mapView: GMSMapView?
    var locationManager: CLLocationManager!
    var loc: CLLocation!
    var ID: String!
    var dataID: String!
    var status: String!
    var currentZoom: Float!
    var alreadyLoaded = false
    let marker = GMSMarker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //GMSServices.provideAPIKey("AIzaSyDXg1UKvJQXArKfTo4j_aY3-Wbc3ohHxvU")
        GMSServices.provideAPIKey("AIzaSyAfoVZySQ9NiuArcD6LTJd_xxZ6iaATh4A")
        
        //Use Firebase library to configure APIs
        if (FirebaseApp.app() == nil){
            FirebaseApp.configure()
        }
        
        
        //initialize root node as deviceID
        ref = Database.database().reference().child("deviceID");
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ID = UIDevice.current.identifierForVendor!.uuidString
        status = "safe"
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        loc = locationManager.location
        locationManager.requestAlwaysAuthorization()
        
        
        ref.observeSingleEvent(of: .value, with: { snapshot in
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                var found = false
                var curChild: DataSnapshot!
                
                for child in snapshots {
                    let dict = child.value as! [String: Any]
                    let curStatus = String(describing: dict["status"])
                    let curLong = dict["longitude"] as! Double
                    let curLat = dict["latitude"] as! Double
                    let devID = dict["deviceID"] as! String
                    if (devID == self.ID) {
                        found = true
                        curChild = child
                        self.dataID = dict["id"] as! String!
                        break
                    }
                }
                
                if (!found) {
                    self.addStatus() //adds a new entry
                }
            }
        })
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
    }
    
    func addStatus() {
        dataID = ref.childByAutoId().key
        let attributes = ["id" : dataID,
                          "deviceID" : ID,
                          "status" : status,
                          "longitude" : loc.coordinate.longitude,
                          "latitude" : loc.coordinate.latitude
            ] as [String : Any]
        
        ref.child(dataID).setValue(attributes)
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if (!alreadyLoaded) {
            mapView = GMSMapView.map(withFrame: CGRect(x: 0, y:0, width: 500, height: 520), camera: GMSCameraPosition.camera(withLatitude: loc.coordinate.latitude, longitude: loc.coordinate.longitude, zoom: 15.0))
            mapView?.setMinZoom(15, maxZoom: 20)
            self.view.addSubview(mapView!)
            alreadyLoaded = true
        }
        
//        mapView = GMSMapView.map(withFrame: CGRect(x: 0, y:0, width: 500, height: 520), camera: GMSCameraPosition.camera(withLatitude: loc.coordinate.latitude, longitude: loc.coordinate.longitude, zoom: 15.0))
//        mapView?.setMinZoom(15, maxZoom: 20)
//        self.view.addSubview(mapView!)
        
//
//        if (currentZoom == nil) {
//            currentZoom = 15.0
//        } else {
//            currentZoom = self.mapView!.camera.zoom
//        }
//
//        mapView = GMSMapView.map(withFrame: CGRect(x: 0, y:0, width: 500, height: 520), camera: GMSCameraPosition.camera(withLatitude: loc.coordinate.latitude, longitude: loc.coordinate.longitude, zoom: currentZoom))
//        mapView?.setMinZoom(15, maxZoom: 20)
//        self.view.addSubview(mapView!)
        
        
        ref.observeSingleEvent(of: .value, with: { snapshot in
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                
                var mapMarkers = [GMSMarker]()
                
                for child in snapshots {
                    let newMarker = GMSMarker()
                    let dict = child.value as! [String: Any]
                    var curStatus = String(describing: dict["status"])
                    let curLong = dict["longitude"] as! Double
                    let curLat = dict["latitude"] as! Double
                    
                    if (curStatus == "help") {
                        newMarker.icon = GMSMarker.markerImage(with: .red)
                        newMarker.title = "☠️ D E A D"
                    } else if (curStatus == "disaster") {
                        newMarker.icon = GMSMarker.markerImage(with: .black)
                        newMarker.title = "Disaster Zone"
                    } else if (curStatus == "safe"){
                        newMarker.icon = GMSMarker.markerImage(with: .blue)
                        newMarker.title = "Safe Zone"
                    }
                    
                    newMarker.position = CLLocationCoordinate2D(latitude: curLat, longitude: curLong)
                    mapMarkers.append(newMarker)
                }
                for marker in mapMarkers {
                    marker.map = self.mapView
                }
            }
        });
        
        
    }
    
    @IBAction func Halp(_ sender: Any) {
        marker.icon = GMSMarker.markerImage(with: .red)
        marker.title = "☠️ D E A D"
        marker.position = CLLocationCoordinate2D(latitude: loc.coordinate.latitude, longitude: loc.coordinate.longitude)
        status = "help"
        ref.child(dataID).updateChildValues(["status": status])
        marker.map = mapView
    }
    
    @IBAction func setSafeZone(_ sender: UIButton) {
        print("Button 2 clicked")
        marker.icon = GMSMarker.markerImage(with: .blue)
        marker.position = CLLocationCoordinate2D(latitude: loc.coordinate.latitude, longitude: loc.coordinate.longitude)
        marker.title = "Safe Zone"
        status = "safe"
        ref.child(dataID).updateChildValues(["status": status])
        marker.map = mapView
    }
    
    @IBAction func setDisasterZone(_ sender: UIButton) {
        marker.icon = GMSMarker.markerImage(with: .black)
        marker.position = CLLocationCoordinate2D(latitude: loc.coordinate.latitude, longitude: loc.coordinate.longitude)
        marker.title = "Disaster Zone"
        status = "disaster"
        ref.child(dataID).updateChildValues(["status": status])
        marker.map = mapView
    }
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error \(error)")
    }
    
}
