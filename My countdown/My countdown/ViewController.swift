//
//  ViewController.swift
//  My countdown
//
//  Created by Andrea Clare Lam on 25/08/2020.
//  Copyright © 2020 Andrea Clare Lam. All rights reserved.
//
// event view controller

import UIKit

class ViewController: UIViewController {

    var event: Event!
    
    // title text view
    @IBOutlet var titleTextView: UITextView!
    
    // Event description text view
    @IBOutlet var descriptionTextView: UITextView!
    
    // delete button
    @IBAction func deleteEvent(_ sender: Any) {
        let alert = UIAlertController(title: "Delete event", message: "Are you sure?", preferredStyle: .alert)

        // yes action
        let yesAction = UIAlertAction(title: "Yes", style: .default) { _ in
            // replace data variable with your own data array
            // delete from db
            EventManager.main.delete(event: self.event)
            self.dismissView()
        }

        alert.addAction(yesAction)

        // cancel action
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        present(alert, animated: true, completion: nil)
    }
    
    // date picker
    @IBOutlet var datePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleTextView.text = event.title
        descriptionTextView.text = event.description
        datePicker.date = event.date
    }
    
    // save event details when quit view
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        event.title = titleTextView.text
        event.description = descriptionTextView.text
        event.date = datePicker.date
        
        EventManager.main.save(event:event)
    }
    
    /* -------------------------------------------------------------------------------- */
    
    // Function to dismiss view
    func dismissView() {
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
}

