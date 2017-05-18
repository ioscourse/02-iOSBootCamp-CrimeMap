//
//  ViewController.swift
//  CrimeMap
//
//  Created by Charles Konkol on 5/29/16.
//  Copyright © 2016 Charles Konkol. All rights reserved.
//

import UIKit
//1) Add Import Statements
import MapKit
import Foundation

//1a) Add to right of UIViewController
//    ,MKMapViewDelegate,CLLocationManagerDelegate




class ViewController: UIViewController,MKMapViewDelegate,CLLocationManagerDelegate {
    var gameTimer: Timer!
    @IBAction func btnMe(_ sender: UIBarButtonItem) {
        centermeonmap()
    }
    
    @IBOutlet weak var lblcount: UILabel!
    
    func centermeonmap(){
        
       let userLocation = mapView.userLocation
        
                let region = MKCoordinateRegionMakeWithDistance(
                    userLocation.location!.coordinate, 5000, 5000)
        
        mapView.setRegion(region, animated: true)
        
    }
    
    func centeronmap(){
        
        let userLocation = startLocation
        
        let region = MKCoordinateRegionMakeWithDistance(
            userLocation.coordinate, 18000, 18000)
        
        mapView.setRegion(region, animated: true)

    }
    //let regionRadius: CLLocationDistance = 1000
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var lblCrimeRange: UILabel!
    @IBAction func DateSlider(_ sender: UISlider) {
//2) Days Ago on Label from Slider
        //**Begin Copy**
        currentValue = Int(sender.value)
        if (currentValue == 1){
             lblCrimeRange.text = "\(currentValue!) Day Ago Until Now."
        } else{
              lblCrimeRange.text = "\(currentValue!) Days Ago Until Now."

        }
        
    }
    
    func UpdateCount(){
        lblcount.text = "\(mapView.visibleAnnotations().count.description) visible crimes"
    }
    
    @IBAction func DateSliderUp(_ sender: UISlider) {
//3 Add Code to DateSliderUp determines how far back to get crime json and display on map
       //**Begin Copy**
        currentValue = Int(sender.value)
        let now = Date()
        mapView.removeAnnotations(mapView.annotations)
        var i = 1
        

        while i <= currentValue {
            
            let daysToAdd = i
            let calculatedDate = (Calendar.current as NSCalendar).date(byAdding: NSCalendar.Unit.day, value: -daysToAdd, to: now, options: NSCalendar.Options.init(rawValue: 0))
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let newDates = dateFormatter.string(from: calculatedDate!)
            crimedate = newDates
            loadDataFromSODAApi()
            i = i + 1
            
        }
        //**End Copy**
       
        
    }
    
//4 Create Variables
    //**Begin Copy**
    var intCount:Int! = 0
    var dataPoints:[DataPoints] = [DataPoints]()
    var crimedate:String!
    var currentValue:Int!
    let startLocation = CLLocation(latitude:  42.288880, longitude: -89.061026	)
    let initialRadius:CLLocationDistance = 20000
    //**End Copy**

//5 Add func locationManager
    //**Begin Copy**
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        let location = locations.last as! CLLocation
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        self.mapView.setRegion(region, animated: true)
    }
    
       //**End Copy**
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//6 When App loads get formatted date from slider
        //**Begin Copy**
        //mapView.delegate = self
        //GET DATE
        let now = Date()
        let daysToAdd = 1
        let calculatedDate = (Calendar.current as NSCalendar).date(byAdding: NSCalendar.Unit.day, value: -daysToAdd, to: now, options: NSCalendar.Options.init(rawValue: 0))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let newDates = dateFormatter.string(from: calculatedDate!)
        crimedate = newDates
        
        //centerMapOnLocation(startLocation)
       // checkLocationAuthorizationStatus()
        mapView.delegate = self
        
      
        setUpNavigationBar()
        mapView.showsUserLocation = true
        //centerMapOnLocation(location: locationManager.location!)
        
        gameTimer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(centeronmap), userInfo: nil, repeats: false)
        
         gameTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(UpdateCount), userInfo: nil, repeats: true)
        //**End Copy**
    }
    
//7 Add mapview function. Needed to update location when user moves
    //**Begin Copy**
    func mapView(_ mapView: MKMapView, didUpdate
        userLocation: MKUserLocation) {
        //mapView.centerCoordinate = userLocation.location!.coordinate
    }
    //**End Copy**
    

//10 Add setUpNavigationBar Nav Bar Color
    //**Begin Copy**
    func setUpNavigationBar(){
        self.navigationBar.barTintColor = UIColor.red
        self.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
    }
    //**End Copy**
    
//11 Add loadDataFromSODAApi
    
   //**Begin Copy**
    func loadDataFromSODAApi(){
        let session:URLSession! = URLSession.shared
        print(crimedate)
        var strURL:String!
        strURL = "https://data.illinois.gov/resource/ctfx-e3rj.json?occurred_on_date=\(crimedate!)"
        //let url:URL = URL(string:"https://data.illinois.gov/resource/ctfx-e3rj.json?occurred_on_date=\(crimedate)")!
        let url:URL = URL(string:strURL)!
       // intCount = 0
        
        let task = session.dataTask(with: url, completionHandler: {data, response, error in
            guard let actualData = data else{
                return
            }
            do{
                let jsonResult:NSArray = try JSONSerialization.jsonObject(with: actualData, options: JSONSerialization.ReadingOptions.mutableLeaves) as! NSArray
                //  print("Number of Json Results loaded  = \(jsonResult.count)")
                DispatchQueue.main.async(execute: {
                    for item in jsonResult {
                        self.intCount = self.intCount + 1
                        let dataDictionary = item as! NSDictionary
                        let datapoint:DataPoints! = DataPoints.fromDataArray(dataDictionary)!
                        self.dataPoints.append(datapoint)
                        var thepoint = MKPointAnnotation()
                        thepoint = MKPointAnnotation()
                        thepoint.coordinate = datapoint.coordinate
                        //thepoint.title = datapoint.title!
                        let s1 : String =  (datapoint?.title)!
                        let s2 = s1.replacingOccurrences(of: "Optional(", with: "")
                        let s3 = s2.replacingOccurrences(of: "):", with: " ")
                        let s4 = s3.replacingOccurrences(of: ")", with: "")
                        let s5 = s4.replacingOccurrences(of: "\"", with: "")
                        print(s5)
                        thepoint.title = s5
                        thepoint.subtitle = datapoint.district
                        self.mapView.addAnnotation(thepoint)
                        
                    }
                })
                
            }catch let parseError{
                print("Response Status - \(parseError)")
            }
        })
       // intCount = 0
        task.resume()
        
    }
    //**End Copy**
    
    
    
}
extension MKMapView {
    func visibleAnnotations() -> [MKAnnotation] {
        return self.annotations(in: self.visibleMapRect).map { obj -> MKAnnotation in return obj as! MKAnnotation }
    }
}

/*
 
 12 Add to info.plist for location prompt
 
 1) Control + Click on info.plist, Open As Source Control
 2) Add Below 2 lines right above the <dict> tag
 
 <key>NSLocationWhenInUseUsageDescription</key>
 <string>To spot the criminal activities in the area</string>
 
 */

