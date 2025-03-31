//
//  ViewController.swift
//  DateConverterDemo
//
//  Created by MacBook_Air_41 on 26/07/24.
//

import UIKit
import SwiftDate

class ViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var dateTextField2: UITextField!
    @IBOutlet weak var dateTextField3: UITextField!
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var comparisonResultLabel: UILabel!
    @IBOutlet weak var lblTimeInterval: UILabel!

    @IBOutlet weak var btnSTD: UIButton!
    @IBOutlet weak var btnDTS: UIButton!
    @IBOutlet weak var btnCompare: UIButton!
    
    private let datePicker = UIDatePicker()
    private var activeTextField: UITextField?
    private var blurEffectView: UIVisualEffectView!
    var toolbar = UIToolbar()
    var parsedDate: Date?
    
    // Date formats array
    var dateFormateTypes = [
        "yyyy-MM-dd",
        "yyyy-MM-dd'T'HH:mm:ss",
        "yyyy-MM-dd'T'HH:mm:ss.SSS'Z''",
        "EEE, d MMM yyyy HH:mm:ss Z",
        "MM/dd/yyyy",
        "M/d/yyyy",
        "MM-dd-yyyy",
        "M-d-yyyy",
        "dd/MM/yyyy",
        "d/M/yyyy",
        "dd-MM-yyyy",
        "d-M-yyyy",
        "yyyy-MM-dd HH:mm:ss",
        "yyyy/MM/dd HH:mm:ss",
        "MM/dd/yyyy HH:mm:ss",
        "dd/MM/yyyy HH:mm:ss",
        "yyyy-MM-dd'T'HH:mm:ssXXX",
        "EEE, d MMM yyyy HH:mm:ss Z",
        "yyyy-MM-dd HH:mm:ss Z",
        "yyyy-'W'ww-u",
        "dd MMM yyyy",
        "MMMM d, yyyy",
        "d MMMM yyyy",
        "MMM d, yyyy",
        "yyyy MMM d",
        "dd MMM yyyy",
        "d. MMMM yyyy",
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
    }
    
    // MARK: - View controller methods
    private func setUpUI() {
        setupDatePicker()
        setupToolbar()
        btnDTS.layer.cornerRadius = btnDTS.frame.height/2
        btnSTD.layer.cornerRadius = btnSTD.frame.height/2
        btnCompare.layer.cornerRadius = btnCompare.frame.height/2
        dateTextField.placeholder = "Select a date"
        dateTextField2.placeholder = "Enter date A"
        dateTextField3.placeholder = "Enter date B"
        dateTextField.delegate = self
        dateTextField2.delegate = self
        dateTextField3.delegate = self
    }
    
    private func setupToolbar() {
        // Initialize the toolbar
        toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonTapped))
        
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelButtonTapped))
        
        // Create a flexible space item to push the buttons to the right
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        // Add buttons to the toolbar
        toolbar.setItems([cancelButton, flexibleSpace, doneButton], animated: false)
        
        // Assign the toolbar to the text fields' inputAccessoryView
        dateTextField.inputAccessoryView = toolbar
        dateTextField2.inputAccessoryView = toolbar
        dateTextField3.inputAccessoryView = toolbar
    }
    
    private func setupDatePicker() {
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        
        // Set the same date picker for all text fields
        dateTextField.inputView = datePicker
        dateTextField2.inputView = datePicker
        dateTextField3.inputView = datePicker
        
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        
    }
    
    private func addDatePickerToSubview() {
        // Give the background Blur Effect
        let blurEffect = UIBlurEffect(style: .regular)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(blurEffectView)
        self.view.addSubview(datePicker)
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        centerDatePicker()
        view.bringSubviewToFront(datePicker)
    }
    
    private func centerDatePicker() {
        NSLayoutConstraint.activate([
            datePicker.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            datePicker.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            datePicker.widthAnchor.constraint(equalTo: self.view.widthAnchor),
            datePicker.heightAnchor.constraint(equalToConstant: 250)
        ])
    }
    
    
    @objc private func doneButtonTapped() {
        toolbar.isHidden = true
        view.endEditing(true)
    }
    
    @objc private func cancelButtonTapped() {
        toolbar.isHidden = true
        activeTextField?.resignFirstResponder()
    }
    
    @objc private func dateChanged(_ sender: UIDatePicker) {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        let selectedDate = formatter.string(from: sender.date)
        activeTextField?.text = selectedDate
    }
    
    // MARK: - UITextField delegate methods
    @IBAction func textFieldDidBeginEditing(_ sender: UITextField) {
        activeTextField = sender
    }
    
    @IBAction func textFieldDidEndEditing(_ sender: UITextField) {
        activeTextField = sender
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //MARK: - Button Action
    @IBAction func convertButtonTapped(_ sender: UIButton) {
        convertDateToString()
    }
    
    @available(iOS 15, *)
    @IBAction func convertStringToDateButtonTapped(_ sender: UIButton) {
        convertStringToDate()
    }
    
    @IBAction func compareDatesButtonTapped(_ sender: UIButton) {
        compareDates()
    }
    
}

extension ViewController {
    //MARK: - Conversion String to Date type
    func dateFromString(dateString: String, formats: [String]) -> Date? {
        let dateFormatter = DateFormatter()
        
        for format in formats {
            dateFormatter.dateFormat = format
            if let date = dateFormatter.date(from: dateString) {
                return date
            }
        }
        return nil
    }
    
    //MARK: -  Function to compare dates
    func compareDates1() {
        guard let dateString1 = dateTextField2.text, !dateString1.isEmpty,
              let dateString2 = dateTextField3.text, !dateString2.isEmpty else {
            comparisonResultLabel.text = "Please enter both date strings"
            return
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        
        guard let dateA = dateFormatter.date(from: dateString1),
              let dateB = dateFormatter.date(from: dateString2) else {
            comparisonResultLabel.text = "Failed to convert one or both date strings"
            return
        }
        
        let dateInRegionA = DateInRegion(dateA)
        let dateInRegionB = DateInRegion(dateB)
        let comparison1 = dateInRegionA.date >= dateInRegionB.date
        
        comparisonResultLabel.text = "Comparison 1 (A >= B): \(comparison1)"
        
    }
    
    func compareDates() {
        guard let dateString1 = dateTextField2.text, !dateString1.isEmpty,
              let dateString2 = dateTextField3.text, !dateString2.isEmpty else {
            comparisonResultLabel.text = "Please enter both date strings"
            return
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        
        guard let dateA = dateFormatter.date(from: dateString1),
              let dateB = dateFormatter.date(from: dateString2) else {
            comparisonResultLabel.text = "Failed to convert one or both date strings"
            return
        }
        
        var dateInRegionA = DateInRegion(dateA)
        let dateInRegionB = DateInRegion(dateB)
        let comparison1 = dateInRegionA.date >= dateInRegionB.date
        
        // Calculate the time interval between dateA and dateB
        let timeInterval = dateA.timeIntervalSince(dateB)
        let timeIntervalString = timeInterval.toClock()
        
        dateInRegionA = DateInRegion().dateAt(.endOfDay)
        var comparisonResults = "Comparison 1 (A >= B): \(comparison1)\n"
        print("Date ragion A : \(dateInRegionA)")
        
        comparisonResults += "Time Interval between A and B: \(timeIntervalString)\n"
        lblTimeInterval.text = comparisonResults
        
        comparisonResultLabel.text = comparisonResults
    }

    
    // MARK: - Function to convert date to String
    func convertDateToString() {
        let selectedDate = datePicker.date
        
        // Define the output date format
        let outputDateFormatter = DateFormatter()
        outputDateFormatter.dateFormat =  "MMM dd, yyyy - h:mm a"
        outputDateFormatter.timeZone = TimeZone.current
        outputDateFormatter.locale = Locale.current
        
        // Define the formatter to get current time
        let currentTimeFormatter = DateFormatter()
        currentTimeFormatter.dateFormat = "h:mm a"
        currentTimeFormatter.timeZone = TimeZone.current
        currentTimeFormatter.locale = Locale.current
        
        var dateString: String?
        
        // Try to find the correct format by attempting to format and parse the selected date
        for format in dateFormateTypes {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = format
            dateFormatter.timeZone = TimeZone.current
            dateFormatter.locale = Locale.current
            
            // Convert the selected date to string using the current format
            let formattedDate = dateFormatter.string(from: selectedDate)
            
            // Try to parse the formatted date string back to a Date object
            if let parsedDate = dateFormatter.date(from: formattedDate) {
                // Include the current time in the output
                let currentTime = currentTimeFormatter.string(from: Date())
                let formattedDateWithTime = outputDateFormatter.string(from: parsedDate)
                dateString = "\(formattedDateWithTime.replacingOccurrences(of: "12:00 AM", with: currentTime))"
                break
            }
        }
        
        if let result = dateString {
            resultLabel.text = "Converted Date: \(result)"
            print("Converted Date: \(result)")
        } else {
            resultLabel.text = "Invalid date format"
        }
    }
    
    
    // MARK: - Function to convert Array of String to Date
    @available(iOS 15, *)
    func convertStringToDate() {
        let selectedDate = datePicker.date
        guard let dateString = dateTextField.text, !dateString.isEmpty else {
            resultLabel.text = "Please enter a date string"
            return
        }
        
        // Define the output date format
        let outputDateFormatter = DateFormatter()
        outputDateFormatter.dateFormat = "MMM dd, yyyy - h:mm a z"
        outputDateFormatter.timeZone = TimeZone.current
        outputDateFormatter.locale = Locale.current
        
        // Define the formatter to get current time
        let currentTimeFormatter = DateFormatter()
        currentTimeFormatter.dateFormat = "h:mm a"
        currentTimeFormatter.timeZone = TimeZone.current
        currentTimeFormatter.locale = Locale.current
        
        var parsedDate: Date?
        
        for format in dateFormateTypes {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = format
            dateFormatter.timeZone = TimeZone.current
            dateFormatter.locale = Locale.current
            
            if let date = dateFormatter.date(from: dateString) {
                parsedDate = date
                break
            }
        }
        
        if let date = parsedDate {
            // Calculate the time interval
            let timeInterval = selectedDate.timeIntervalSince(date)
            
            // Format the time interval
            let intervalString = timeInterval.toString {
                $0.maximumUnitCount = 4
                $0.allowedUnits = [.day, .hour, .minute, .second]
                $0.collapsesLargestUnit = true
                $0.unitsStyle = .abbreviated
            }
            // Static time interval example
            let staticInterval: TimeInterval = (2.hours.timeInterval) + (34.minutes.timeInterval) + (5.seconds.timeInterval)
            let staticIntervalString = staticInterval.toClock() // "2:34:05"
            let currentTime = currentTimeFormatter.string(from: selectedDate)
            let formattedDateString = outputDateFormatter.string(from: selectedDate)
            let finalDateString = formattedDateString.replacingOccurrences(of: "12:00 AM", with: currentTime)
            
            //resultLabel.text = "Converted Date: \(finalDateString)"
            resultLabel.text = "Converted Date: \(finalDateString) \n Time Interval: \(intervalString) \n Static Interval: \(staticIntervalString)"
            print("Converted Date: \(formattedDateString)")
            print("Time Interval: \(intervalString)")
            print("Static Interval: \(staticIntervalString)")
        } else {
            resultLabel.text = "Failed to convert string to date"
        }
    }
    
    // MARK: - Function to convert string to date and then to a different format
    func convertStringToDate1() {
        guard let dateString = dateTextField.text, !dateString.isEmpty else {
            resultLabel.text = "Please enter a date string"
            return
        }
        
        // Define the output date format
        let outputDateFormatter = DateFormatter()
        outputDateFormatter.dateFormat = "MMM dd, yyyy - h:mm a z"
        outputDateFormatter.timeZone = TimeZone.current
        outputDateFormatter.locale = Locale.current
        
        // Define the formatter to get current time
        let currentTimeFormatter = DateFormatter()
        currentTimeFormatter.dateFormat = "h:mm a"
        currentTimeFormatter.timeZone = TimeZone.current
        currentTimeFormatter.locale = Locale.current
        
        let selectedDate = datePicker.date
        
        // Convert the selected date to string using the output format
        let formattedDateString = outputDateFormatter.string(from: selectedDate)
        
        // Get the current time
        let currentTime = currentTimeFormatter.string(from: selectedDate)
        
        let finalDateString = formattedDateString.replacingOccurrences(of: "12:00 AM", with: currentTime)
        resultLabel.text = "Converted Date: \(finalDateString)"
        print("Converted Date: \(finalDateString)")
    }
}

