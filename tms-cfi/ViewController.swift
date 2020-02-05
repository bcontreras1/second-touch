//
//  ViewController.swift
//  tms-cfi
//
//  Created by Brenda Contreras on 1/18/19.
//  Copyright © 2019 Brenda Contreras. All rights reserved.
//

import UIKit


class ViewController:  UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var barcode: UITextField!
    
    @IBOutlet weak var currentSessionText: UITextView!
   
    var pickerData: [String] = [String]()
    
    @IBOutlet weak var ProjectList: UIPickerView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        // Connect data:
     
        //self.ProjectList.delegate = self
        //self.ProjectList.dataSource = self
        //pickerData = ["Build-Started", "OS-Loaded", "Build-Complete"]
      
        //self.currentSessionText.text = ""
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
    
    // Number of columns of data
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        return pickerData.count
    }
    
    // The data to return fopr the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int)-> String?{
        
        return pickerData[row]
    }
    
    @IBAction func enterStatus(sender: UIButton) {
        //let alertController = UIAlertController(title: "Welcome to My //First App", message: self.barcode.text ?? "" + pickerData[self.ProjectList.selectedRow(inComponent: 0)], preferredStyle: UIAlertController.Style.alert)
        // let alertController = UIAlertController(title: "Welcome to My First App", message:  pickerData[self.ProjectList.selectedRow(inComponent: 0)], preferredStyle: UIAlertController.Style.alert)
        //alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        //present(alertController, animated: true, completion: nil)
    
       
        self.currentSessionText.text += "\n"
        self.currentSessionText.text += self.barcode.text ?? ""
        self.currentSessionText.text += "\t"
        self.currentSessionText.text += pickerData[self.ProjectList.selectedRow(inComponent: 0)]
        self.currentSessionText.text += "\n"
        
        //clear selections
        self.barcode.text = ""
        
    }
    
    @IBAction func uploadToDell(sender: UIButton) {
        //let alertController = UIAlertController(title: "Welcome to My //First App", message: self.barcode.text ?? "" + pickerData[self.ProjectList.selectedRow(inComponent: 0)], preferredStyle: UIAlertController.Style.alert)
        let alertController = UIAlertController(title: "Welcome to My First App", message:  "Uploaded to Dell", preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        present(alertController, animated: true, completion: nil)
        
       
        self.currentSessionText.text = ""
        
        //clear selections
        self.barcode.text = ""
        
    }
}

