//
//  TableViewController.swift
//  My countdown
//
//  Created by Andrea Clare Lam on 25/08/2020.
//  Copyright © 2020 Andrea Clare Lam. All rights reserved.
//
// Event list controller

import UIKit

// cell controller for custom table view cell
class TableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var daysLeftLabel: UILabel!
}

class TableViewController: UITableViewController {
    
    var events: [Event] = []
    
    // today's date
    var currentDate = Date()
    
    // Add button function
    @IBAction func createEvent() {
        let _ = EventManager.main.create()
        // reload table after create
        reload()
    }
    
    @IBOutlet var swipeDelete: UISwipeGestureRecognizer!
    
    // Delete swipe function
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // delete from db
            EventManager.main.delete(event: self.events[indexPath.row])
            
            // remove from array
            self.events.remove(at: indexPath.row)
            
            // remove from table view
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    // reload table when view loads
    override func viewDidLoad() {
        super.viewDidLoad()
        reload()
    }
    
    // reload when return to table from note
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reload()
    }
    
    // number of sections
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // number of rows in section
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    // Create cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath) as! TableViewCell
        
        // set label values
        let event = events[indexPath.row]
        cell.titleLabel?.text = event.title
        cell.dateLabel?.text = EventManager.main.dateToStringShow(dateDate: event.date) // String of event date in the form of short
        cell.dayLabel?.text = String(daysBetween(start: currentDate, end: event.date))
        cell.daysLeftLabel?.text = "days left"
        
        return cell
    }
    
    // Pass event from table view to event view
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // FInd correct segue
        if segue.identifier == "EventSegue" {
            if let destination = segue.destination as? ViewController {
                destination.event = events[tableView.indexPathForSelectedRow!.row]
            }
        }
    }
    
    
    
    // Function to get days between 2 dates
    func daysBetween(start: Date, end: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: start, to: end).day!
    }
    
    // Function to reload table
    func reload() {
        events = EventManager.main.getAllEvents()
        self.tableView.reloadData()
    }
    
}
