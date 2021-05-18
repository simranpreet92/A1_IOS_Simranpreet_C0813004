
import UIKit
import MapKit


class ViewController: UIViewController , CLLocationManagerDelegate {
    
    @IBOutlet weak var map: MKMapView!
    // distance variable is taken to check the distance
    var distance = 0.0
    // counts no. of pins
    var counts = 0
    
    var firstCoordinate: CLLocationCoordinate2D!
    var secondCoordinate: CLLocationCoordinate2D!
    var thirdCoordinate: CLLocationCoordinate2D!
    var userCurrentLocation : CLLocationCoordinate2D!
    var sourceCoordinate : CLLocationCoordinate2D!
    
   // var places: [CLLocationCoordinate2D]!
    // create location manager
    var locationManager = CLLocationManager()
    
    // destination variable
    var destination: CLLocationCoordinate2D!
    
    // create the places array
    var places = [Place]()
       

    override func viewDidLoad() {
        super.viewDidLoad()
        map.isZoomEnabled = true
        map.showsUserLocation = true
        
       
        // Do any additional setup after loading the view.
        // we assign the delegate property of the location manager to be this class
         locationManager.delegate = self
         
         // we define the accuracy of the location
         locationManager.desiredAccuracy = kCLLocationAccuracyBest
         
         // rquest for the permission to access the location
        locationManager.requestWhenInUseAuthorization()
         //locationManager.requestAlwaysAuthorization()/
         
         // start updating the location
         locationManager.startUpdatingLocation()
         
         // 1st step is to define latitude and longitude
        // 1st step is to define latitude and longitude
        map.delegate = self
        
        
    }
   
    //firstly, useris current location is displayed on map
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
    let userLocation = locations[0]
    
    let Userlatitude = userLocation.coordinate.latitude
    let Userlongitude = userLocation.coordinate.longitude
        userCurrentLocation = CLLocationCoordinate2D(latitude: Userlatitude, longitude: Userlongitude)
        // calling the function locationManager here
        
    displayLocation(latitude: Userlatitude, longitude: Userlongitude, title: "your Current location", subtitle: "You are currently here")
        
        // calling function for marker
        let uilpgr = UILongPressGestureRecognizer(target: self, action: #selector(addLongPressAnnotation))
        
        
        
        map.addGestureRecognizer(uilpgr)
    
    }

    //MARK: - display user location method
    
    func displayLocation(latitude: CLLocationDegrees,
                         longitude: CLLocationDegrees,
                         title: String,
                         subtitle: String) {
        // 2nd step - define span
        let latDelta: CLLocationDegrees = 0.05
        let lngDelta: CLLocationDegrees = 0.05
        
        let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lngDelta)
        // 3rd step is to define the location
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        // 4th step is to define the region
        let region = MKCoordinateRegion(center: location, span: span)
        
        // 5th step is to set the region for the map
        map.setRegion(region, animated: true)
        
        // 6th step is to define annotation
        let annotation = MKPointAnnotation()
        annotation.title = title
        annotation.subtitle = subtitle
        annotation.coordinate = location
        map.addAnnotation(annotation)
       
    }
    
    
    //MARK: - polygon method
     func createPolygon() {
        if places.count < 2 {
            // three points are required to make a triangle
            return
        }
        else
        {
        let coordinates = places.map {$0.coordinate}
        let polygon = MKPolygon(coordinates: coordinates, count: coordinates.count)
        map.addOverlay(polygon)
        }
     }
    //MARK: - polyline method
    func polyline() {
        let coordinates = places.map {$0.coordinate}
        let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
        map.addOverlay(polyline)
    
    }
    
   
    
    
    //MARK: - long press gesture recognizer for the annotation
    @objc func addLongPressAnnotation(_ gestureRecognizer: UIGestureRecognizer) {
        counts = counts + 1
        let startPoint = gestureRecognizer.location(in: map)
        let coordinate = map.convert(startPoint, toCoordinateFrom: map)
        
        // add annotation for the coordinate
        switch counts  {
        case 2:
            let annotation = MKPointAnnotation()
            annotation.title = "A"
            annotation.coordinate = coordinate
            firstCoordinate = coordinate
           
            let loc1 = CLLocation(latitude: firstCoordinate.latitude, longitude: firstCoordinate.longitude)
           
            let uLoc = userCurrentLocation.latitude
            let uLOc = userCurrentLocation.longitude
            let ul = CLLocation(latitude: uLoc, longitude: uLOc)
            

            distance = loc1.distance(from: ul)
            print("distance a" ,distance)

           
            map.addAnnotation(annotation)
            break
           
            
          
        case 4:
            let annotation = MKPointAnnotation()
            annotation.title = "B"
            annotation.coordinate = coordinate
            secondCoordinate = coordinate
           
            let loc1 = CLLocation(latitude: secondCoordinate.latitude, longitude: secondCoordinate.longitude)
           
            let uLoc = userCurrentLocation.latitude
            let uLOc = userCurrentLocation.longitude
            let ul = CLLocation(latitude: uLoc, longitude: uLOc)
            

            distance = loc1.distance(from: ul)
            print("distance b" ,distance)

           
            map.addAnnotation(annotation)
            break
            
        case 6:
            let annotation = MKPointAnnotation()
            annotation.title = "C"
            annotation.coordinate = coordinate
            thirdCoordinate = coordinate
           
            let loc1 = CLLocation(latitude: thirdCoordinate.latitude, longitude: thirdCoordinate.longitude)
           
            let uLoc = userCurrentLocation.latitude
            let uLOc = userCurrentLocation.longitude
            let ul = CLLocation(latitude: uLoc, longitude: uLOc)
            

            distance = loc1.distance(from: ul)
            print("distance c" ,distance)

           
            map.addAnnotation(annotation)
            break
        default:
            print("default")
        }
        
        
        if counts % 2 == 0 {
            
       // whenever count is divisible by 2 then that coordinate is taken on map
        let place = Place(title: " ", subtitle: " ", coordinate: coordinate)
        places.append(place)
      
        if places.count == 3{
          // if total 3 points are plotted on map then call createPolygon function
            createPolygon()
            
            }
            if places.count > 3
            {
                removePin()
                
            }
        }
        
        
    }
    
    //MARK: - remove pin from map
    func removePin() {
        for annotation in map.annotations {
            map.removeAnnotation(annotation)
            map.removeOverlays(map.overlays)
            counts = 0
            places.removeAll()
        }
       
    }

    
    @IBAction func drawRoute() {
       
        let sourcePlaceMark = MKPlacemark(coordinate: sourceCoordinate)
        let destinationPlaceMark = MKPlacemark(coordinate: destination)
        
        // request a direction
       let directionRequest = MKDirections.Request()
        
        // assign the source and destination properties of the request
        directionRequest.source = MKMapItem(placemark: sourcePlaceMark)
        directionRequest.destination = MKMapItem(placemark: destinationPlaceMark)
        
        // transportation type
        directionRequest.transportType = .automobile
        
        // calculate the direction
        let directions = MKDirections(request: directionRequest)
        directions.calculate { (response, error) in
            guard let directionResponse = response else {return}
            // create the route
            let route = directionResponse.routes[0]
            // drawing a polyline
            self.map.addOverlay(route.polyline)
            
        }
        
    }
}
extension ViewController: MKMapViewDelegate {
    
    //MARK: - viewFor annotation method
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            return nil
        }
        
        switch annotation.title {
        case "A" ,"B" , "C":
            let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "MyMarker")
            annotationView.markerTintColor = UIColor.red
            annotationView.canShowCallout = true
            annotationView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            return annotationView
      
        default:
            return nil
        }
    }
    
    //MARK: - callout accessory control tapped
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        var message = distance.description
      
        let alertController = UIAlertController(title: "distance between user location and this point is", message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    //MARK: - rendrer for overlay func
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        if overlay is MKPolyline {
            let rendrer = MKPolylineRenderer(overlay: overlay)
            rendrer.fillColor = UIColor.red.withAlphaComponent(0.5)
            rendrer.strokeColor = UIColor.green
            rendrer.lineWidth = 2
           
            return rendrer
            
        } else if overlay is MKPolygon {
    let rendrer = MKPolygonRenderer(overlay: overlay)
    rendrer.fillColor = UIColor.red.withAlphaComponent(0.5)
    rendrer.strokeColor = UIColor.green
    rendrer.lineWidth = 3
    return rendrer
    }
        return MKOverlayRenderer()
    }
}




