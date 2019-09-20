//
//  SpecialViewController.swift
//  KProgressHUD_Example
//
//  Created by raniys on 9/20/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit

class SpecialViewController: UIViewController {

    enum HUDType {
        case progress, progressLabel
        case shortText, longText
        case customView
        
        var title: String {
            switch self {
            case .progress:
                return "Indeterminate mode"
            case .progressLabel:
                return "Indeterminate with label"
            case .shortText:
                return "Short text"
            case .longText:
                return "Long text"
            case .customView:
                return "Custom view"
            }
        }
    }
    
    let examples: [HUDType] = [.progress, .progressLabel, .shortText, .longText, .customView]
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        title = "SpecialKProgressHUD"
    }
    
    
}


// MARK: - UITableViewDataSource

extension SpecialViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return examples.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let example = examples[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = example.title
        cell.textLabel?.textAlignment = .center
        return cell
    }
}

// MARK: - UITableViewDelegate

extension SpecialViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let example = examples[indexPath.row]
        
        switch example {
        case .progress:
            print("Indeterminate mode")
            view.showProgress()
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
                self.view.removeProgress()
            }
        case .progressLabel:
            print("Indeterminate with label")
            view.showProgress("Loading", delay: 2)
        case .shortText:
            print("Short text")
            view.showLabel("short")
        case .longText:
            view.showLabel("在各种沟通场合发现：行业专家在了解了我们“灵感库”在做的是什么后，对于这个名称都说不好或者感到奇怪，原因是“灵感库”会让他们浮想联翩，觉得里面会有很多教学活动的灵感，但是其实我们只提供了发布给家长的各种内容参考模板，他们觉得内容和名称很对应不上。")
            print("Long text")
        case .customView:
            print("Custom view")
        }
    }
}
