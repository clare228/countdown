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
    
    @IBOutlet var eventsTableView: UITableView!
    
    // Add button function
    @IBAction func createEvent() {
        let _ = EventManager.main.create()
        // reload table after create
        reload()
    }
    
    @IBOutlet var swipeDelete: UISwipeGestureRecognizer!
    
    // swipe to delete
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            presentDeletionFailsafe(indexPath: indexPath)
        }
    }
    
    // reload table when view loads
    override func viewDidLoad() {
        super.viewDidLoad()
        reload()
        
        // set background colour of table view
        self.tableView.backgroundColor = UIColor.init(displayP3Red: 234/255, green: 228/255, blue: 242/255, alpha: 1)
        
        // add footer to hide separation lines of empty cells in table view
        self.tableView.tableFooterView = UIView()
        
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
        
        // Change background colour of table view cell according to number of days left
        let daysLeft = daysBetween(start: currentDate, end: events[indexPath.row].date)
        
        if daysLeft == 0 {
            cell.backgroundColor = UIColor.init(displayP3Red: 175/255, green: 220/255, blue: 223/255, alpha: 1)
        }
        else if daysLeft > 0 {
            cell.backgroundColor = UIColor.init(displayP3Red: 182/255, green: 207/255, blue: 236/255, alpha: 1)
        }
        else if daysLeft < 0 {
            cell.backgroundColor = UIColor.init(displayP3Red: 215/255, green: 215/255, blue: 215/255, alpha: 1)
        }
                
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
    
/* ------------------------------------------------------------------------------------------- */
    
    // Function to get days between 2 dates
    func daysBetween(start: Date, end: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: start, to: end).day!
    }
    
    // Function to reload table
    func reload() {
        events = EventManager.main.sort(unorderedEvents: EventManager.main.getAllEvents())
        self.tableView.reloadData()
        
        // display message if no events
        if events.count == 0 {
            eventsTableView.backgroundView = UIView()
            let noDataLabel: UILabel  = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            noDataLabel.text = "Add an event!"
            noDataLabel.textColor = UIColor.lightGray
            noDataLabel.textAlignment = .center
            noDataLabel.font = UIFont.boldSystemFont(ofSize: 30)
            tableView.backgroundView = noDataLabel
            tableView.separatorStyle = .none
        }
        else {
            eventsTableView.backgroundView = nil
        }
    }
    
    // Function for delete confirmation pop up window
    func presentDeletionFailsafe(indexPath: IndexPath) {
        let alert = UIAlertController(title: "Delete event", message: "Are you sure?", preferredStyle: .alert)

        // yes action
        let yesAction = UIAlertAction(title: "Yes", style: .default) { _ in
            
            // remove event from db
            EventManager.main.delete(event: self.events[indexPath.row])
            
            // remove event from array
            self.events.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .fade)
            self.reload()
        }

        alert.addAction(yesAction)

        // cancel action
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        present(alert, animated: true, completion: nil)
    }
    
}
