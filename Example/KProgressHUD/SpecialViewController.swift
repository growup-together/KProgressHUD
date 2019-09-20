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
        
        guard let rootView = navigationController?.view else { return }
        
        let example = examples[indexPath.row]
        switch example {
        case .progress:
            print("Indeterminate mode")
            rootView.showProgress()
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
                rootView.removeProgress()
            }
        case .progressLabel:
            print("Indeterminate with label")
            rootView.showProgress("Loading", delay: 2)
        case .shortText:
            print("Short text")
            rootView.showLabel("short")
        case .longText:
            rootView.showLabel("北京时间9月19日20点，华为Mate 30系列将会在德国慕尼黑举行发布会。在发布会前夕，关于华为Mate 30系列新机的信息有很多。而近日，就有人放出了华为Mate 30、Mate 30 Pro的配色渲染图。关于这次爆料的图片，华为Mate 30、Mate 30 Pro一共有四种配色，分别是紫色、黑色、翡翠以及星河银全新配色。")
            print("Long text")
        case .customView:
            print("Custom view")
            
            let contentView: UIView = {
                let view = UIView()
                view.backgroundColor = UIColor.white
                view.layer.cornerRadius = 8
                return view
            }()
            
            let image = #imageLiteral(resourceName: "toast_successd")
            let imageView = UIImageView(image: image)
            let label: UILabel = {
                let label = UILabel()
                label.text = "Cheers!"
                label.textColor = UIColor.black
                label.font = UIFont.systemFont(ofSize: 20, weight: .medium)
                return label
            }()
            
            contentView.addSubview(imageView)
            contentView.addSubview(label)
            
            var frame = contentView.bounds
            frame.size.width = image.size.width + 49 * 2
            contentView.bounds = frame
            
            imageView.snp.makeConstraints { (make) in
                make.centerX.equalToSuperview()
                make.top.equalToSuperview().offset(12)
            }
            label.snp.makeConstraints { (make) in
                make.centerX.equalToSuperview()
                make.top.equalTo(imageView.snp.bottom).offset(13)
                make.bottom.equalToSuperview().offset(-20)
            }
            
            print("contentView \(contentView.frame)")
            rootView.showCustomView(contentView, delay: 1, backColor: UIColor.clear, completion: {
                DispatchQueue.main.async {
                    print("showCustomView succeed! \(contentView.frame)")
                }
            })
        }
    }
}
