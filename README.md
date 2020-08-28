# countdown

- First iOS mobile app project
- App to count down to an event


Main features
- Create an event (title, description and time of event editable)
- Event sorted according to days left till the event
- Colour of cells in table view differ according to days left (green if event that is happening on the day, blue for upcoming events, grey for past events)
- swipe delete events or delete on editing page with pop up window asking for delete confirmation
- message for if table cell view is empty


What I have learnt in this project:
- use a table view controller
- layout objects using stack view and constraints
- create, connect to and update a sqlite3 database
- deal with dates in swift (converting date object to a string and vice versa to store in database)
- create pop up windows
- customise each cell (e.g. colour, fonts, background) both in swift code or in storyboard


What I wish I have done but couldn't due to the lack of a developer account
- Add push notifications for when the event is due
- Add events to iphone calendar


Things I want to try in future project
- Adding an extra tab on the table view (One tab for upcoming events and one for past events)


Files:
1) TableViewController.swift
- file to control view of list of the events

2) ViewController.swift
- file to control view of editing event details

3) Event.swift
- file to manage database of events

