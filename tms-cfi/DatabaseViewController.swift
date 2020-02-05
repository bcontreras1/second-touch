
//
//  ViewController.swift
//  SwiftExample
//
//  Created by Belal Khan on 18/11/17.
//  Copyright © 2017 Belal Khan. All rights reserved.
//

import UIKit
import SQLite3
import MessageUI

class Hero {
    
    var id: Int
    var name: String?
    var powerRanking: Int
    
    init(id: Int, name: String?, powerRanking: Int){
        self.id = id
        self.name = name
        self.powerRanking = powerRanking
    }
}

class PCStatus {
    
    var id: Int
    var name: String?
    var notes: String?
    var status: String?
    var timestamp: String?
    
    init(id: Int, name: String?, notes: String?, status: String?, timestamp: String?){
        self.id = id
        self.name = name
        self.notes = notes
        self.status = status
        self.timestamp = timestamp
    }
}



class DatabaseViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource, MFMailComposeViewControllerDelegate {
    
    
    var db: OpaquePointer?
    var heroList = [PCStatus]()
    
    @IBOutlet weak var tableViewHeroes: UITableView!
   
    @IBOutlet weak var textFieldName: UITextField!
    @IBOutlet weak var textFieldPowerRanking: UITextField!
    
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var ProjectList: UIPickerView!
    
    var pickerData: [String] = [String]()
    
    
    @IBAction func buttonSave(_ sender: UIButton) {
        let name = textFieldName.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let notes = textFieldPowerRanking.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let status = pickerData[self.ProjectList.selectedRow(inComponent: 0)]
        
        if(name?.isEmpty)!{
            textFieldName.layer.borderColor = UIColor.red.cgColor
            return
        }
        
        if(status == "----Select Status----" ){
            ProjectList.layer.borderColor = UIColor.red.cgColor
            //return
            let alertController = UIAlertController(title: "TMS CFI Application", message:  "Must select status", preferredStyle: UIAlertController.Style.alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            present(alertController, animated: true, completion: nil)
            return
        }
        
        //if(powerRanking?.isEmpty)!{
           // textFieldName.layer.borderColor = ////UIColor.red.cgColor
            //return
        //}
        
        //update
        
        let itemName = name as! NSString
        let itemNotes = notes as! NSString
        let itemStatus = status as NSString
        
        
        var stmt: OpaquePointer?
        
        let queryString = "INSERT INTO pc_status_session (name, notes, status) VALUES (?,?,?)"
        
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return
        }
        
        if sqlite3_bind_text(stmt, 1, itemName.utf8String, -1, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding name: \(errmsg)")
            return
        }
        
        if sqlite3_bind_text(stmt, 2, itemNotes.utf8String, -1, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding name: \(errmsg)")
            return
        }
        
        if sqlite3_bind_text(stmt, 3, itemStatus.utf8String, -1, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding name: \(errmsg)")
            return
        }
        
        if sqlite3_step(stmt) != SQLITE_DONE {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure inserting hero: \(errmsg)")
            return
        }
        
        textFieldName.text=""
        textFieldPowerRanking.text=""
        ProjectList.selectRow(0, inComponent: 0, animated: true)
        
        textFieldName.becomeFirstResponder()
        
        readValues()
        
        print("PC status saved successfully")
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return heroList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "cell")
        //let hero: Hero
        //hero = heroList[indexPath.row]
        //cell.textLabel?.text = hero.name
        
        let hero: PCStatus
        hero = heroList[indexPath.row]
        //cell.textLabel?.text =  hero.timestamp! + " " + hero.name! + " " + hero.status!
        
        cell.textLabel?.text =  hero.name! + " " + hero.status!
        return cell
    }
    
    
    func readValues(){
        heroList.removeAll()
        
        let queryString = "SELECT id, name, notes, status, timestamp FROM pc_status_session"
        
        var stmt:OpaquePointer?
        
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing select: \(errmsg)")
            return
        }
        
        while(sqlite3_step(stmt) == SQLITE_ROW){
            let id = sqlite3_column_int(stmt, 0)
            let name = String(cString: sqlite3_column_text(stmt, 1))
            let notes = String(cString: sqlite3_column_text(stmt, 2))
            let status = String(cString: sqlite3_column_text(stmt, 3))
            let timestamp = String(cString: sqlite3_column_text(stmt, 4))
            
            //heroList.append(Hero(id: Int(id), name: String(describing: name), powerRanking: Int(powerrank)))
            
            
            heroList.append(PCStatus(id: Int(id), name: String(describing: name), notes: String(describing: notes), status: String(describing: status), timestamp: String(describing: timestamp)))
        }
        
        self.tableViewHeroes.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("HeroesDatabase.sqlite")
        
        
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("error opening database")
        }
        
        if sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS Heroes (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, powerrank INTEGER)", nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error creating table: \(errmsg)")
        }
        
        if sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS Session_Status (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, notes TEXT, Timestamp DATETIME DEFAULT CURRENT_TIMESTAMP)", nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error creating table: \(errmsg)")
        }
        
       // if sqlite3_exec(db, "drop TABLE pc_status_session", nil, nil, nil) != SQLITE_OK {
         //   let errmsg = String(cString: sqlite3_errmsg(db)!)
           // print("error dropping table: \(errmsg)")
      //  }
        
        if sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS pc_status_session (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, notes TEXT, status TEXT, timestamp DATETIME DEFAULT CURRENT_TIMESTAMP)", nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error creating table: \(errmsg)")
        }
        
        readValues()
        
        self.ProjectList.delegate = self
        self.ProjectList.dataSource = self
        pickerData = ["----Select Status----","Build-Started", "OS-Loaded", "Build-Complete"]
        
        
         self.tableViewHeroes.flashScrollIndicators()
        
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
    
    @IBAction func uploadToDell(sender: UIButton) {
        //let alertController = UIAlertController(title: "Welcome to My //First App", message: self.barcode.text ?? "" + pickerData[self.ProjectList.selectedRow(inComponent: 0)], preferredStyle: UIAlertController.Style.alert)
       // let alertController = UIAlertController(title: "TMS CFI Application", message:  "Uploaded to Dell", preferredStyle: UIAlertController.Style.alert)
      //  alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
      //  present(alertController, animated: true, completion: nil)
        
        sendStatusToTms()
        
        backButton.sendActions(for: .touchUpInside)
    }
    
    func sendStatusToTms(){
        let fileName = "operator_today.csv"
        let path = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
        
        var csvText = "Timestamp,Barcode,Notes,Status\n"
        
        
        let count = heroList.count
        
        if count > 0 {
            
            var val1 : String! // This is not optional.
            var val2 : String! // This is not optional.
            var val3 : String! // This is not optional.
            var val4 : String! // This is not optional.
            
            for pc in heroList {
                
                //let dateFormatter = DateFormatter()
                //dateFormatter.dateStyle = DateFormatter.Style.short
                //let convertedDate = dateFormatter.stringFromDate(pc.timestamp)
                
                //let newLine = pc.timestamp+","+pc.name+","+pc.notes+","+pc.status+"\n"
                
                val1 = pc.timestamp
                val2 = pc.name
                val3 = pc.notes
                val4 = pc.status
                
                 let newLine = "\(val1!),\(val2!),\(val3!),\(val4!)\n"
                
                //csvText.appendContentsOf(newLine)
                csvText.append(contentsOf: newLine)
            }
            
            do {
                try csvText.write(to: path!, atomically: true, encoding: String.Encoding.utf8)
                
              //  let vc = UIActivityViewController(activityItems: [path], applicationActivities: [])
              //  vc.excludedActivityTypes = [
                  //  UIActivity.ActivityType.assignToContact,
                  //  UIActivity.ActivityType.saveToCameraRoll,
                  //  UIActivity.ActivityType.postToFlickr,
                  //  UIActivity.ActivityType.postToVimeo,
                  //  UIActivity.ActivityType.postToTencentWeibo,
                  //  UIActivity.ActivityType.postToTwitter,
                  //  UIActivity.ActivityType.postToFacebook,
                  //  UIActivity.ActivityType.openInIBooks
                //]
                //present(vc, animated: true, completion: nil)
                
                //send email w/ csv attached
                
                if MFMailComposeViewController.canSendMail() {
                    let emailController = MFMailComposeViewController()
                    emailController.mailComposeDelegate = self
                    emailController.setToRecipients(["tms-edi@tms-lp.com"])
                    emailController.setSubject("TMS-CFI PC Status Data Export")
                    emailController.setMessageBody("Hi,\n\nThe .csv data export is attached\n\n\nSent from the CFI app: http://www.tms-lp/cfi", isHTML: false)
                    
                    emailController.addAttachmentData(NSData(contentsOf: path!)! as Data, mimeType: "text/csv", fileName: "operator_today.csv")
                    
                    present(emailController, animated: true, completion: nil)
                }
                else{
                //test purposes
                
                  let vc = UIActivityViewController(activityItems: [path], applicationActivities: [])
                  vc.excludedActivityTypes = [
                  UIActivity.ActivityType.assignToContact,
                  UIActivity.ActivityType.saveToCameraRoll,
                  UIActivity.ActivityType.postToFlickr,
                  UIActivity.ActivityType.postToVimeo,
                  UIActivity.ActivityType.postToTencentWeibo,
                  UIActivity.ActivityType.postToTwitter,
                  UIActivity.ActivityType.postToFacebook,
                  UIActivity.ActivityType.openInIBooks
                ]
                present(vc, animated: true, completion: nil)
                }
                
                //cleanup up DB
                if sqlite3_exec(db, "drop TABLE pc_status_session", nil, nil, nil) != SQLITE_OK {
                    let errmsg = String(cString: sqlite3_errmsg(db)!)
                    print("error dropping table: \(errmsg)")
                }
                
                if sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS pc_status_session (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, notes TEXT, status TEXT, timestamp DATETIME DEFAULT CURRENT_TIMESTAMP)", nil, nil, nil) != SQLITE_OK {
                    let errmsg = String(cString: sqlite3_errmsg(db)!)
                    print("error creating table: \(errmsg)")
                }
                
                readValues()
                
            } catch {
                
                print("Failed to create file")
                print("\(error)")
            }
            
        } else {
            //showErrorAlert("Error", msg: "There is no data to export")
            
            let errmsg = "There is no data to export"
            print("failure exporting data: \(errmsg)")
        }
    }
    @IBAction func doneWithInput(_ sender: Any) {
        self.view.endEditing(true)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    func onUserAction(data: String)
    {
        print("Data received: \(data)")
        textFieldName.text = data
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is ScannerViewController
        {
            let vc = segue.destination as? ScannerViewController
            vc?.databaseViewController = self
        }
    }
}
