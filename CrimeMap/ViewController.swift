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

    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var lblCrimeRange: UILabel!
    @IBAction func DateSlider(_ sender: UISlider) {
//2) Days Ago on Label from Slider
        //**Begin Copy**
        currentValue = Int(sender.value)
        lblCrimeRange.text = "\(currentValue) Days Ago Until Now."
        //**End Copy**
        
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
    fileprivate var locationManager = CLLocationManager()
    fileprivate var dataPoints:[DataPoints] = [DataPoints]()
    var crimedate:String!
    var currentValue:Int!
    let startLocation = CLLocation(latitude: 42.306713, longitude: -88.989403	)
    let initialRadius:CLLocationDistance = 20000
    //**End Copy**

//5 Add func locationManager
    //**Begin Copy**
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last! as CLLocation
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        self.mapView.setRegion(region, animated: true)
    }
    //**End Copy**
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//6 When App loads get formatted date from slider
        //**Begin Copy**
        
        //GET DATE
        let now = Date()
        let calculatedDate = (Calendar.current as NSCalendar).date(byAdding: NSCalendar.Unit.day, value: -1, to: now, options: NSCalendar.Options.init(rawValue: 0))
        //Formate Date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let newDates = dateFormatter.string(from: calculatedDate!)
        crimedate = newDates
        
        centerMapOnLocation(startLocation)
        checkLocationAuthorizationStatus()
        mapView.delegate = self
        
        loadDataFromSODAApi()
        setUpNavigationBar()
        mapView.showsUserLocation = true
        
        //**End Copy**
    }
    
//7 Add mapview function. Needed to update location when user moves
    //**Begin Copy**
    func mapView(_ mapView: MKMapView, didUpdate
        userLocation: MKUserLocation) {
        mapView.centerCoordinate = userLocation.location!.coordinate
    }
    //**End Copy**
    
//8 Add checkLocationAuthorizationStatus Confirm user gives access to location
    //**Begin Copy**
    func checkLocationAuthorizationStatus() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            mapView.showsUserLocation = true
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    //**End Copy**
    
//9 Add centerMapOnLocation func
    //**Begin Copy**
    func centerMapOnLocation(_ location:CLLocation){
        let coordinateRegion:MKCoordinateRegion! = MKCoordinateRegionMakeWithDistance(location.coordinate, initialRadius * 2.0, initialRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
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
        
        
        let task = session.dataTask(with: url, completionHandler: {data, response, error in
            guard let actualData = data else{
                return
            }
            do{
                let jsonResult:NSArray = try JSONSerialization.jsonObject(with: actualData, options: JSONSerialization.ReadingOptions.mutableLeaves) as! NSArray
                //  print("Number of Json Results loaded  = \(jsonResult.count)")
                DispatchQueue.main.async(execute: {
                    for item in jsonResult {
                        let dataDictionary = item as! NSDictionary
                        let datapoint:DataPoints! = DataPoints.fromDataArray(dataDictionary)!
                        self.dataPoints.append(datapoint)
                        var thepoint = MKPointAnnotation()
                        thepoint = MKPointAnnotation()
                        thepoint.coordinate = datapoint.coordinate
                        //thepoint.title = datapoint.title!
                        thepoint.title = datapoint.title
                        thepoint.subtitle = datapoint.district
                        self.mapView.addAnnotation(thepoint)
                    }
                })
                
            }catch let parseError{
                print("Response Status - \(parseError)")
            }
        })
        task.resume()
    }
    //**End Copy**
    
    
    
}

/*
 
 12 Add to info.plist for location prompt
 
 1) Control + Click on info.plist, Open As Source Control
 2) Add Below 2 lines right above the <dict> tag
 
 <key>NSLocationWhenInUseUsageDescription</key>
 <string>To spot the criminal activities in the area</string>
 
 */

