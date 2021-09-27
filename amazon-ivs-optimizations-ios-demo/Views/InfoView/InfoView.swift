//
//  InfoView.swift
//  amazon-ivs-optimizations-ios-demo
//
//  Created by Uldis on 05/05/2021.
//

import UIKit

class InfoView: UIView {

    @IBOutlet weak var pillView: UIView?
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var valueLabel: UILabel?
    @IBOutlet weak var titleLabelWidthConstraint: NSLayoutConstraint!

    class func fromNib() -> InfoView {
        return Bundle.main.loadNibNamed(String(describing: self), owner: nil, options: nil)!.first as! InfoView
    }

    func fill(with title: String,
              value: String,
              backgroundColor: UIColor = UIColor(hex: "#545B64"),
              isLatencyPill: Bool = false,
              prefferedTitleWidth: CGFloat? = nil
    ) {
        pillView?.backgroundColor = backgroundColor
        pillView?.layer.cornerRadius = 20

        if isLatencyPill {
            titleLabel?.textColor = UIColor.black
            valueLabel?.textColor = UIColor.black
            titleLabel?.font = UIFont(name: "System", size: 17)
            valueLabel?.font = UIFont(name: "System", size: 19)
        }

        if let titleWidth = prefferedTitleWidth {
            titleLabelWidthConstraint.constant = titleWidth
        }

        DispatchQueue.main.async {
            self.titleLabel?.text = title
            self.titleLabel?.isHidden = false
            self.valueLabel?.text = value
            self.valueLabel?.isHidden = false
        }
    }
}
