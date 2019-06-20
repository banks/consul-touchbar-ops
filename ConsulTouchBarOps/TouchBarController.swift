//
//  TouchBarController.swift
//  ConsulTouchBarOps
//
//  Created by Paul Banks on 17/06/2019.
//  Copyright © 2019 banks. All rights reserved.
//

import Cocoa

struct ServiceSplitterConfig : Codable {
    let Kind : String
    let Name : String
    let Splits : [ServiceSplitterConfigSplit]
}
struct ServiceSplitterConfigSplit : Codable {
    let Service : String
    let ServiceSubset : String
    let Weight : Double
}

class TouchBarController: NSWindowController {
    
    @IBOutlet weak var labelL: NSTextField!
    @IBOutlet weak var percentL: NSButton!
    @IBOutlet weak var labelR: NSTextField!
    @IBOutlet weak var percentR: NSButton!
    @IBOutlet weak var serviceLabel: NSTextField!
    
    private var percent : Double = 0
    private var lastPercent : Double = 0
    
    private let debounceWait : TimeInterval = 0.5
    private var debounceTimer: Timer?
    
    private let consulColor = NSColor.init(red: 198/256, green: 42/256, blue: 113/256, alpha: 0.4)
    private let blackColor = NSColor.init(red: 0, green: 0, blue: 0, alpha: 1)
    
    private let updateQ = DispatchQueue(label: "touchBarUpdater", qos: .default)
    
    @IBAction func onSlide(_ sender: NSSlider) {
        let viewController = contentViewController as! ViewController;
        percent = sender.doubleValue.rounded()
        viewController.textOut.doubleValue = percent
        updateTouchBar()
        
        // Debounce the actual sending of the request so we only send when we've paused changing for a bit
        debounceTimer?.invalidate()
        debounceTimer = Timer.scheduledTimer(withTimeInterval: debounceWait, repeats: false, block: { [weak self] timer in
            self?.handleTimer(timer)
        })
    }
    
    private func handleTimer(_ timer: Timer) {
        guard timer.isValid else {
            return
        }
        updateSplitConfig()
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
        self.updateTouchBar()
    }

    func updateSplitConfig() {
        let viewController = contentViewController as! ViewController;
        
        var urlPath = viewController.urlInput.stringValue
        if urlPath == "" {
            urlPath = "http://localhost:8500"
        }
        urlPath = urlPath.trimmingCharacters(in: CharacterSet.init(charactersIn: "/"))
        urlPath += "/v1/config"
        
        let url = URL(string: urlPath)!
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let session = URLSession.shared
        let body = ServiceSplitterConfig(
            Kind: "service-splitter",
            Name: viewController.serviceInput.stringValue,
            Splits: [
                ServiceSplitterConfigSplit(
                    Service: viewController.serviceInput.stringValue,
                    ServiceSubset: viewController.subsetLInput.stringValue,
                    Weight: 100-percent
                ),
                ServiceSplitterConfigSplit(
                    Service: viewController.serviceInput.stringValue,
                    ServiceSubset: viewController.subsetRInput.stringValue,
                    Weight: percent
                ),
            ]
        )
        guard let bodyData = try? JSONEncoder().encode(body) else {
            print ("encoding error")
            return
        }
        
        let task = session.uploadTask(with: request, from: bodyData) { data, response, error in
            // Even if it failed, pretend it worked and reset the state as we have no better error handling for now.
            // We have to dispatch this onto the main thread so it can update the UI and class variables.
            DispatchQueue.main.async {
                self.lastPercent = self.percent
                self.updateTouchBar()
            }
            
            if let error = error {
                print ("error: \(error)")
                return
            }
            if let response = response as? HTTPURLResponse {
                if !(200...299).contains(response.statusCode) {
                    print ("server error: \(response.description)")
                    return
                }
            } else {
                print ("response not an HTTPURLResponse")
                return
            }
        }
        task.resume()
    }
    
    func updateTouchBar() {
        let viewController = contentViewController as! ViewController;
        
        //print ("update \(lastPercent) \(percent)")
        if percent == lastPercent {
            percentL.bezelColor = blackColor
            percentR.bezelColor = blackColor
        } else {
            percentL.bezelColor = consulColor
            percentR.bezelColor = consulColor
        }
        
        var labelLVal = viewController.subsetLInput.stringValue
        if labelLVal == "" {
            labelLVal = "v1"
        }
        labelL.stringValue = labelLVal
        percentL.title = String(format:"%.0f%%", 100-percent)

        var labelRVal = viewController.subsetRInput.stringValue
        if labelRVal == "" {
            labelRVal = "v2"
        }
        labelR.stringValue = labelRVal
        percentR.title = String(format:"%.0f%%", percent)
        
        var service = viewController.serviceInput.stringValue
        if service == "" {
            service = "web"
        }
        serviceLabel.stringValue = service
    }
}
