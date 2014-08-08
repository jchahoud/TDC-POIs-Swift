//
//  ViewController.swift
//  TDC-POIs
//
//  Created by Juliana Chahoud on 7/27/14.
//  Copyright (c) 2014 jchahoud. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate, UISearchBarDelegate {
                            
    @IBOutlet weak var mapView: MKMapView!
    
    var tdcAnnotation: TDCAnnotation!
    
    var locationManager: CLLocationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.locationManager.requestWhenInUseAuthorization()

        //creates a map region around TDC coordinates
        let tdcLocation:CLLocationCoordinate2D  = CLLocationCoordinate2DMake(-23.600463,-46.674605)
        self.mapView.region = MKCoordinateRegionMakeWithDistance(tdcLocation, 8000, 8000)
        self.mapView.showsUserLocation = true
        self.mapView.delegate = self
    
        //Setting Ibirapuera Park annotation
        let ibiraAnnotation:MKPointAnnotation = MKPointAnnotation()
        ibiraAnnotation.coordinate = CLLocationCoordinate2DMake(-23.587416, -46.657634)
        ibiraAnnotation.title = "Parque do Ibirapuera"
        
        //Setting a the conference custom annotation
        self.tdcAnnotation = TDCAnnotation(coordinate: tdcLocation,
                                                title: "TDC",
                                             subtitle: "http://www.thedevelopersconference.com.br")
        
        self.mapView.addAnnotations([ibiraAnnotation, tdcAnnotation])
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func changeMapType (sender: UISegmentedControl) {
        
        //changes the mapView Type
        switch sender.selectedSegmentIndex {

        case 0:
            self.mapView.mapType = MKMapType.Standard
            
        case 1:
            self.mapView.mapType = MKMapType.Satellite

        case 2:
            self.mapView.mapType = MKMapType.Hybrid
            
        default:
            println("other value")
            
        }
    }
    
    func viewForTDCAnnotation(annotation: MKAnnotation, reuseIdentifier: String) -> MKAnnotationView
    {
        var anView:MKAnnotationView = MKAnnotationView(annotation: annotation,
                                                  reuseIdentifier: reuseIdentifier)
        
        //chnges the annotation sttaic image to be TDC's logo
        anView.image = UIImage(named:"TDCLogo")

        anView.canShowCallout = true
        
        //adding a button to the callout to implement a tap
        anView.rightCalloutAccessoryView = UIButton.buttonWithType(UIButtonType.DetailDisclosure) as UIButton
        
        return anView
    }
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        
        if annotation is TDCAnnotation{
            let reuseId = "tdcAnnot"
            var anView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId)
            if anView == nil {
                anView = self.viewForTDCAnnotation(annotation, reuseIdentifier: reuseId)
            }
            else {
                //we are re-using a view, update its annotation reference
                anView.annotation = annotation
            }
            return anView
        }
        return nil
    }

    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {

        if view.annotation is TDCAnnotation
        {
            //when the user taps the callout bubble it opens the conference website
            let url:NSURL = NSURL(string: "http://www.thedevelopersconference.com.br")
            UIApplication.sharedApplication().openURL(url)
        }
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar!) {
        
        //sets a request with the text typed on the search bar and with current map region
        var request:MKLocalSearchRequest = MKLocalSearchRequest()
        request.naturalLanguageQuery = searchBar.text
        request.region = self.mapView.region
        
        //inits a local search with the request
        var search:MKLocalSearch = MKLocalSearch(request: request)

        //sets an activity indicator
        var loading:UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        loading.center = self.view.center
        self.view.addSubview(loading)
        loading.startAnimating()
        
        //start the search
        search.startWithCompletionHandler {
            (response:MKLocalSearchResponse!, error:NSError!) in
            if !error {
            
                //creates an array to keep the annotations created with the items returned
                var placemarks:NSMutableArray = NSMutableArray()
                for item in response.mapItems {
                    
                    //creates a new point annotation per item returned
                    let place:MKPointAnnotation = MKPointAnnotation()
                    place.coordinate = (item as MKMapItem).placemark.coordinate
                    place.title = (item as MKMapItem).name
                    placemarks.addObject(place)
                }
                
                //clean and add the annotations in the placemarks array
                self.cleanAnnotations()
                self.mapView.addAnnotations(placemarks)
            
            }
            loading.stopAnimating()
            searchBar.resignFirstResponder()
            
        }
    }
    
    func cleanAnnotations(){
        
        //clean all the map annotations except fo the user and TDC Logo
        var anToremove = NSMutableArray(array: self.mapView.annotations)
        anToremove.removeObject(self.mapView.userLocation)
        anToremove.removeObject(self.tdcAnnotation)
        
        self.mapView.removeAnnotations(anToremove)
        
    }
    
}

