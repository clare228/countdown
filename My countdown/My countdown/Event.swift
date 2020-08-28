//
//  Event.swift
//  My countdown
//
//  Created by Andrea Clare Lam on 25/08/2020.
//  Copyright © 2020 Andrea Clare Lam. All rights reserved.
//

import Foundation
import SQLite3

struct Event {
    let id: Int
    var title: String
    var description: String
    var date: Date
}

class EventManager {
    

    var currentDate = Date()
        
    var database: OpaquePointer!
    
    // Singletance for calling
    static let main = EventManager()
    private init() {
    }
    
    
    // Function to connect to db
    func connect() {
        
        // if db already exists
        if database != nil {
            return
        }
                
        // Create path to file in user's device
        do {
            let databaseURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("events.sqlite3")
            
            // open db file
            if sqlite3_open(databaseURL.path, &database) != SQLITE_OK {
                print("Could not open db")
            }
            
            // create table
            if sqlite3_exec(database, "CREATE TABLE IF NOT EXISTS events (title TEXT, description TEXT, date TEXT)", nil, nil, nil) != SQLITE_OK {
                print("Could not create table")
            }
        }
        catch _ {
            print("Could not create a database")
        }
    }
    
    
    // Function to create new note
    // return row id of newly inserted row
    func create() -> Int {
        connect()
        
        // prepare statment
        var statement: OpaquePointer!
        if sqlite3_prepare_v2(database, "INSERT INTO events (title, description, date) VALUES ('New event', 'Event description', ?)", -1, &statement, nil) != SQLITE_OK {
            print("Could not create (insert) query")
            return -1
        }
                
        // bind
        // preset date of event to current date
        sqlite3_bind_text(statement, 1, NSString(string: dateToStringFormat(dateDate: currentDate)).utf8String, -1, nil)
                
        // execute statement
        if sqlite3_step(statement) != SQLITE_DONE {
            print("Could not execute insert statement")
            return -1
        }
        
        // Finalise statement
        sqlite3_finalize(statement)
        return Int(sqlite3_last_insert_rowid(database))
    }
    
    
    // Function to get all events from db
    // returns a list of events
    func getAllEvents() -> [Event] {
        connect()
        var result: [Event] = []
        
        // prepare
        var statement: OpaquePointer!
        if sqlite3_prepare_v2(database, "SELECT rowid, title, description, date FROM events", -1, &statement, nil) != SQLITE_OK{
            print("Could not create (select) query")
            return []
        }
        
        // execute
        while sqlite3_step(statement) == SQLITE_ROW {
            
            // change string date into Date date
            let Date_date = stringToDateFormat(stringDate: String(cString: sqlite3_column_text(statement, 3)))

            // append Events to result
            result.append(Event(id: Int(sqlite3_column_int(statement, 0)), title: String(cString: sqlite3_column_text(statement, 1)), description: String(cString: sqlite3_column_text(statement, 2)), date: Date_date))
        }
        
        // finalise
        sqlite3_finalize(statement)
    
        return result
    }
    
    
    // Function to save Event to db
    // pass in event to save
    func save(event: Event) {
        connect()
        
        // prepare
        var statement: OpaquePointer!
        if sqlite3_prepare_v2(database, "UPDATE events SET title = ?, date = ?, description = ? WHERE rowid = ?", -1, &statement, nil) != SQLITE_OK {
            print("Could not create (update) query")
        }
        
        // bind place holders
        sqlite3_bind_text(statement, 1, NSString(string:event.title).utf8String, -1, nil)
        sqlite3_bind_text(statement, 2, NSString(string:dateToStringFormat(dateDate: event.date)).utf8String, -1, nil)
        sqlite3_bind_text(statement, 3, NSString(string:event.description).utf8String, -1, nil)
        sqlite3_bind_int(statement, 4, Int32(event.id))
        
        // execute
        if sqlite3_step(statement) != SQLITE_DONE {
            print("Could not execute update statement")
        }
        
        // finalise
        sqlite3_finalize(statement)
    }
    
    
    // Function to delete event
    func delete(event: Event) {
        connect()
        
        // prepare
        var statement: OpaquePointer!
        if sqlite3_prepare_v2(database, "DELETE FROM events WHERE rowid = ?", -1, &statement, nil) != SQLITE_OK {
            print("Could not create (delete) query")
        }
        
        // bind
        sqlite3_bind_int(statement, 1, Int32(event.id))
        
        // execute
        if sqlite3_step(statement) != SQLITE_DONE {
            print("Could not execute delete statement")
        }
        
        // finalise
        sqlite3_finalize(statement)
    }
    
    /* -------------------------------------------------------------------------------------- */
    
    // Function to turn string date into Date date
    func stringToDateFormat(stringDate: String) -> Date {
        let formatter = ISO8601DateFormatter()
        let dateDate = formatter.date(from: stringDate)
        return dateDate!
    }
    
    // Function to turn Date date to String date
    func dateToStringFormat(dateDate: Date) -> String {
        let formatter = ISO8601DateFormatter()
        let stringDate = formatter.string(from: dateDate)
        
        return stringDate
    }
    
    // Date to String to show users not to calculate or to save in database
    func dateToStringShow(dateDate: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        let stringDate = formatter.string(from: dateDate)
        
        return stringDate
    }
    
    // Function to get days between 2 dates
    func daysBetween(start: Date, end: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: start, to: end).day!
    }
    
    // Function to sort Events in order of days left till events
    // if daysLeft >= 0, order from small to large
    // if daysLeft < 0, order from large to small
    // negative days are ordered after positive
    func sort(unorderedEvents: [Event]) -> [Event]{
        
        // create array of tuple of events and daysleft
        var eventTupList: [(event: Event, daysLeft: Int)] = []
        for event in unorderedEvents {
            let tempTup = (event, daysBetween(start: currentDate, end: event.date))
            eventTupList.append(tempTup)
        }
        
        // order array by daysLeft
        eventTupList.sort(by: {$0.1 < $1.1})
    
        
        // array for ordered Events
        var orderedEvents: [Event] = []
        
        // array for events with negative days left
        var negativeEventsTup: [(event: Event, daysLeft: Int)] = []
        
        for tup in eventTupList {
            // append of daysLeft is positive or 0, ie. event has not happened
            if tup.1 >= 0 {
                orderedEvents.append(tup.0)
            }
            else {
                negativeEventsTup.append(tup)
            }
        }
        
        negativeEventsTup.sort(by: {$0.1 > $1.1})
        for tup in negativeEventsTup {
            orderedEvents.append(tup.0)
        }
        
        return orderedEvents
    }
}
