//
//  ViewController.swift
//  KProgressHUD
//
//  Created by raniys on 09/19/2019.
//  Copyright (c) 2019 raniys. All rights reserved.
//

import UIKit
import KProgressHUD

class ViewController: UIViewController {
    
    enum ProgressMode {
        case indeterminate, indeterminateLabel, indeterminateDetails
        case determinate, determinateAnnular, determinateBar
        case text, customView, actionButton, modeSwitching
        case onWindow, urlSession, determinateProgress, dimBackground, colored
        
        var title: String {
            switch self {
            case .indeterminate:
                return "Indeterminate mode"
            case .indeterminateLabel:
                return "With label"
            case .indeterminateDetails:
                return "With details label"
            case .determinate:
                return "Determinate mode"
            case .determinateAnnular:
                return "Annular determinate mode"
            case .determinateBar:
                return "Bar determinate mode"
            case .text:
                return "Text only"
            case .customView:
                return "Custom view"
            case .actionButton:
                return "With action button"
            case .modeSwitching:
                return "Mode switching"
            case .onWindow:
                return "On window"
            case .urlSession:
                return "NSURLSession"
            case .determinateProgress:
                return "Determinate with NSProgress"
            case .dimBackground:
                return "Dim background"
            case .colored:
                return "Colored"
            }
        }
    }
    
    
    let examples: [[ProgressMode]] = [
        [.indeterminate, .indeterminateLabel, .indeterminateDetails],
        [.determinate, .determinateAnnular, .determinateBar],
        [.text, .customView, .actionButton, .modeSwitching],
        [.onWindow, .urlSession, .determinateProgress, .dimBackground, .colored]
    ]
    
    // Atomic, because it may be canceled from main thread, flag is read on a background thread
    var canceled: Bool = false
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        title = "KProgressHUD"
    }
    
    
    func doSomeWork() {
        sleep(3)
    }
    
    func doSomeWorkWithProgress() {
        canceled = false
        
        var progress: CGFloat = 0.0
        while progress < 1.0 {
            guard !canceled else { break }
            
            progress += 0.01
            DispatchQueue.main.async {[weak self] in
                guard
                    let self = self,
                    let rootView = self.navigationController?.view else { return }
                KProgressHUD.HUD(for: rootView)?.progress = progress
            }
            usleep(50000)
        }
    }
    
    func doSomeWork(with progressObject: Progress) {
        while progressObject.fractionCompleted < 1 {
            guard !progressObject.isCancelled else { return }
            
            progressObject.becomeCurrent(withPendingUnitCount: 1)
            progressObject.resignCurrent()
            
            usleep(50000)
        }
    }
    
    @objc
    func cancelWork(_ sender: Any) {
        canceled = true
    }
    
    func doSomeWorkWithMixedProgress(_ hud: KProgressHUD) {
        sleep(2)
        
        DispatchQueue.main.async {
            hud.mode = .determinate
            hud.titleLabel.text = "Loading..."
        }
        
        var progress: CGFloat = 0
        
        while progress < 1 {
            progress += 0.01
            DispatchQueue.main.async {
                hud.progress = progress
            }
            
            usleep(50000)
        }
        
        DispatchQueue.main.async {
            hud.mode = .indeterminate
            hud.titleLabel.text = "Cleaning up..."
        }
        
        sleep(2)
        
        DispatchQueue.main.sync {
            let image = UIImage(named: "Checkmark")
            hud.customView = UIImageView(image: image)
            hud.mode = .customView
            hud.titleLabel.text = "Completed"
        }
        
        sleep(2)
    }
}


// MARK: - Indeterminate Examples

extension ViewController {
    
    func indeterminateExample() {
        guard let rootView = navigationController?.view else { return }
        
        let hud = KProgressHUD.showAdded(to: rootView, animated: true)
        DispatchQueue.global(qos: .userInitiated).async {[weak self] in
            guard let self = self else { return }
            
            self.doSomeWork()
            DispatchQueue.main.async {
                hud.hide(animated: true)
            }
        }
    }
    
    func indeterminateLabelExample() {
        guard let rootView = navigationController?.view else { return }
        
        let hud = KProgressHUD.showAdded(to: rootView, animated: true)
        hud.titleLabel.text = "Loading..."
        DispatchQueue.global(qos: .userInitiated).async {[weak self] in
            guard let self = self else { return }
            
            self.doSomeWork()
            DispatchQueue.main.async {
                hud.hide(animated: true)
            }
        }
    }
    
    func indeterminateDetailsLabelExample() {
        guard let rootView = navigationController?.view else { return }
        
        let hud = KProgressHUD.showAdded(to: rootView, animated: true)
        hud.titleLabel.text = "Loading..."
        hud.detailsLabel.text = "Parsing data\n(1/1)"
        DispatchQueue.global(qos: .userInitiated).async {[weak self] in
            guard let self = self else { return }
            
            self.doSomeWork()
            DispatchQueue.main.async {
                hud.hide(animated: true)
            }
        }
    }
    
}



// MARK: - Determinate Examples

extension ViewController {
    
    func determinateExample() {
        guard let rootView = navigationController?.view else { return }
        
        let hud = KProgressHUD.showAdded(to: rootView, animated: true)
        hud.mode = .determinate
        hud.titleLabel.text = "Loading..."
        DispatchQueue.global(qos: .userInitiated).async {[weak self] in
            guard let self = self else { return }
            
            self.doSomeWorkWithProgress()
            DispatchQueue.main.async {
                hud.hide(animated: true)
            }
        }
    }
    
    func annularDeterminateExample() {
        guard let rootView = navigationController?.view else { return }
        
        let hud = KProgressHUD.showAdded(to: rootView, animated: true)
        hud.mode = .annularDeterminate
        hud.titleLabel.text = "Loading..."
        DispatchQueue.global(qos: .userInitiated).async {[weak self] in
            guard let self = self else { return }
            
            self.doSomeWorkWithProgress()
            DispatchQueue.main.async {
                hud.hide(animated: true)
            }
        }
    }
    
    
    func barDeterminateExample() {
        guard let rootView = navigationController?.view else { return }
        
        let hud = KProgressHUD.showAdded(to: rootView, animated: true)
        hud.mode = .determinateHorizontalBar
        hud.titleLabel.text = "Loading..."
        DispatchQueue.global(qos: .userInitiated).async {[weak self] in
            guard let self = self else { return }
            
            self.doSomeWorkWithProgress()
            DispatchQueue.main.async {
                hud.hide(animated: true)
            }
        }
    }
}

// MARK: -
extension ViewController {
    
    func textExample() {
        guard let rootView = navigationController?.view else { return }
        
        let hud = KProgressHUD.showAdded(to: rootView, animated: true)
        hud.mode = .text
        hud.titleLabel.text = "在各种沟通场合"
        hud.bezelVectorialMargin = 16
        let width = view.bounds.width * (1.0 / 3.0)
        hud.bezelHorizontalMargin = width / 2
        hud.hide(animated: true, after: 3)
    }
    
    
    func customViewExample() {
        guard let rootView = navigationController?.view else { return }
        
        let hud = KProgressHUD.showAdded(to: rootView, animated: true)
        hud.mode = .customView
        
        let image = UIImage(named: "Checkmark")
        hud.customView = UIImageView(image: image)
        hud.square = true
        hud.titleLabel.text = "Progress Done"
        
        hud.hide(animated: true, after: 3)
    }
    
    func cancelationExample() {
        guard let rootView = navigationController?.view else { return }
        let hud = KProgressHUD.showAdded(to: rootView, animated: true)
        hud.mode = .determinate
        
        hud.actionButton.setTitle("Cancel", for: .normal)
        hud.actionButton.addTarget(self, action: #selector(cancelWork(_:)), for: .touchUpInside)
        
        DispatchQueue.global(qos: .userInitiated).async {[weak self] in
            guard let self = self else { return }
            
            self.doSomeWorkWithProgress()
            DispatchQueue.main.async {
                hud.hide(animated: true)
            }
        }
    }
    
    func modeSwitchingExample() {
        guard let rootView = navigationController?.view else { return }
        let hud = KProgressHUD.showAdded(to: rootView, animated: true)
        hud.titleLabel.text = "Preparing..."
        
        DispatchQueue.global(qos: .userInitiated).async {[weak self] in
            guard let self = self else { return }
            
            self.doSomeWorkWithMixedProgress(hud)
            DispatchQueue.main.async {
                hud.hide(animated: true)
            }
        }
    }
}


// MARK: -
extension ViewController {
    func windowExample() {
        guard let rootView = self.view.window else { return }
        let hud = KProgressHUD.showAdded(to: rootView, animated: true)
        
        DispatchQueue.global(qos: .userInitiated).async {[weak self] in
            guard let self = self else { return }
            
            self.doSomeWork()
            DispatchQueue.main.async {
                hud.hide(animated: true)
            }
        }
    }
    
    func networkingExample() {
        guard let rootView = navigationController?.view else { return }
        let hud = KProgressHUD.showAdded(to: rootView, animated: true)
        hud.titleLabel.text = "Preparing..."
        
        doSomeWorkWithProgress()
    }
    
    func determinateProgressExample() {
        guard let rootView = navigationController?.view else { return }
        
        let hud = KProgressHUD.showAdded(to: rootView, animated: true)
        hud.mode = .determinate
        hud.titleLabel.text = "Loading..."
        
        let progressObject = Progress(totalUnitCount: 100)
        hud.progressObject = progressObject
        
        hud.actionButton.setTitle("Cancel", for: .normal)
        hud.actionButton.addTarget(progressObject, action: NSSelectorFromString("cancel"), for: .touchUpInside)
        
        DispatchQueue.global(qos: .userInitiated).async {[weak self] in
            guard let self = self else { return }
            
            self.doSomeWork(with: progressObject)
            DispatchQueue.main.async {
                hud.hide(animated: true)
            }
        }
    }
    
    func dimBackgroundExample() {
        guard let rootView = navigationController?.view else { return }
        let hud = KProgressHUD.showAdded(to: rootView, animated: true)
        
        hud.backgroundView.style = .solidColor
        hud.backgroundView.color = UIColor.black.withAlphaComponent(0.5)
        
        DispatchQueue.global(qos: .userInitiated).async {[weak self] in
            guard let self = self else { return }
            
            self.doSomeWork()
            DispatchQueue.main.async {
                hud.hide(animated: true)
            }
        }
    }
    
    func colorExample() {
        guard let rootView = navigationController?.view else { return }
        let hud = KProgressHUD.showAdded(to: rootView, animated: true)
        
        hud.contentColor = UIColor.red
        hud.titleLabel.text = "Loading..."
        
        DispatchQueue.global(qos: .userInitiated).async {[weak self] in
            guard let self = self else { return }
            
            self.doSomeWork()
            DispatchQueue.main.async {
                hud.hide(animated: true)
            }
        }
    }
}



// MARK: - UITableViewDataSource

extension ViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return examples.count
    }
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return examples[section].count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let example = examples[indexPath.section][indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = example.title
        cell.textLabel?.textAlignment = .center
        return cell
    }
}

// MARK: - UITableViewDelegate

extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let example = examples[indexPath.section][indexPath.row]
        
        switch example {
        case .indeterminate:
            indeterminateExample()
        case .indeterminateLabel:
            indeterminateLabelExample()
        case .indeterminateDetails:
            indeterminateDetailsLabelExample()
        case .determinate:
            determinateExample()
        case .determinateAnnular:
            annularDeterminateExample()
        case .determinateBar:
            barDeterminateExample()
        case .text:
            textExample()
        case .customView:
            customViewExample()
        case .actionButton:
            cancelationExample()
        case .modeSwitching:
            modeSwitchingExample()
        case .onWindow:
            windowExample()
        case .urlSession:
            networkingExample()
        case .determinateProgress:
            determinateProgressExample()
        case .dimBackground:
            dimBackgroundExample()
        case .colored:
            colorExample()
        }
    }
}
