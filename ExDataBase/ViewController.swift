//
//  ViewController.swift
//  ExDataBase
//
//  Created by RLogixxTraining on 01/12/23.
//

import UIKit
import SQLite3

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return arrInciData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = arrInciData[indexPath.row]["title"] as! String
        
        return cell
        
        
    }
    
    var statement:OpaquePointer?
    var db: OpaquePointer?
    var dbFilePath:String?

    @IBOutlet weak var tblShow: UITableView!
    
    var arrInciData = [[String:Any]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tblShow.delegate = self
        tblShow.dataSource = self
        // Do any additional setup after loading the view.
        getdatabaseFile()
    }

    func getdatabaseFile(){
      
      let fileURL = try! FileManager.default
          .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
          .appendingPathComponent("InciData.db")
      
      // see if db is in app support directory already
      if sqlite3_open_v2(fileURL.path, &db, SQLITE_OPEN_READWRITE, nil) == SQLITE_OK {
          print("db ok")
          self.dbFilePath = fileURL.absoluteString
          print(dbFilePath)
          openDatabase()
          return
      }
      
      // clean up before proceeding
      sqlite3_close(db)
      db = nil
      
      // if not, get URL from bundle
      guard let bundleURL = Bundle.main.url(forResource: "InciData", withExtension: "db") else {
          print("db not found in bundle")
          return
      }
      
      // copy from bundle to app support directory
      do {
          try FileManager.default.copyItem(at: bundleURL, to: fileURL)
      } catch {
          print("unable to copy db", error.localizedDescription)
          return
      }
      
      
      // now open database again
      guard sqlite3_open_v2(fileURL.path, &db, SQLITE_OPEN_READWRITE, nil) == SQLITE_OK else {
          print("error opening database")
          sqlite3_close(db)
          db = nil
          return
      }
      self.dbFilePath = fileURL.absoluteString
        openDatabase()
  }
    
    
    func openDatabase(){
        
        if sqlite3_open(self.dbFilePath!, &db) == SQLITE_OK{
            print("db has connected")
            getIncidentFromDB()
            
        }else{
            print("error in opening database")
            sqlite3_close(db)
            db = nil
        }
    }
    
    func getIncidentFromDB(){
        
       
        let query = "Select * from InciData"
        print(query)
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) != SQLITE_OK{
            let errorMsg = String(cString: sqlite3_errmsg(db))
            print(errorMsg)
        }
        while sqlite3_step(statement) == SQLITE_ROW{
            
            let id = sqlite3_column_int64(statement, 0)
            print(id)
            
            
            var title :String?
            if let ttl = sqlite3_column_text(statement, 1){
                title = String(cString: ttl)
                print(title ?? "")
            }
            
            var desc :String?
            if let dsc = sqlite3_column_text(statement, 2){
                desc = String(cString: dsc)
                print(desc ?? "")
            }
            var long :String?
            if let lng = sqlite3_column_text(statement, 3){
                long = String(cString: lng)
                print(long ?? "")
            }
            var lati :String?
            if let lat = sqlite3_column_text(statement, 4){
                lati = String(cString: lat)
                print(lati ?? "")
            }
//            //print(imageType)
            let incData = ["id":id,"title":title!,"desc":desc,"long":long,"lati":lati] as [String : Any]
            arrInciData.append(incData as [String : Any])
            
            
        }
        
        sqlite3_finalize(statement)
        print(arrInciData)
      
    }

}

