//
//  SettingsViewController.swift
//  amazon-ivs-optimizations-ios-demo
//
//  Created by Uldis on 27/05/2021.
//

import UIKit

class SettingsViewController: UIViewController {

    // MARK: IBOutlet

    @IBOutlet weak var customLiveStreamView: UIView!
    @IBOutlet weak var customStreamSwitch: UISwitch!
    @IBOutlet weak var customUrlTextField: URLTextField!
    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var errorViewBottomConstraint: NSLayoutConstraint!

    // MARK: View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)

        setupViews()

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    // MARK: View logic

    private func setupViews() {
        customLiveStreamView.layer.cornerRadius = 10
        errorView.layer.cornerRadius = 10
        customStreamSwitch.isOn = Settings.shared.customURLString != nil

        customUrlTextField.clearButtonMode = .always
        customUrlTextField.delegate = self
        customUrlTextField.layer.borderWidth = 2.0
        customUrlTextField.layer.cornerRadius = 10
        customUrlTextField.layer.borderColor = UIColor(hex: "F8991D").cgColor
        customUrlTextField.keyboardType = .URL
        customUrlTextField.isHidden = Settings.shared.customURLString == nil
        customUrlTextField.text = Settings.shared.customURLString

        customUrlTextField.attributedPlaceholder = NSAttributedString(
            string: "Paste your Playback URL...",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor(hex: "EBEBF5")]
        )

        processCustomUrlText()
    }

    @objc func keyboardWillShow(notification: Notification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        errorViewBottomConstraint.constant = keyboardSize.height - view.safeAreaInsets.bottom + 20
        UIView.animate(withDuration: 0.5){
            self.view.layoutIfNeeded()
        }
    }

    @objc func keyboardWillHide(notification: Notification){
        errorViewBottomConstraint.constant = 20
        UIView.animate(withDuration: 0.5){
            self.view.layoutIfNeeded()
        }
    }

    private func processCustomUrlText() {
        guard let urlString = customUrlTextField.text, !urlString.isEmpty else {
            Settings.shared.customURLString = nil
            toggleInvalidURLError(false)
            return
        }

        if let url = valid(urlString) {
            Settings.shared.customURLString = url
            toggleInvalidURLError(false)
        } else {
            toggleInvalidURLError(true)
        }
    }

    private func valid(_ urlString: String) -> String? {
        guard let url = URL(string: urlString),
            UIApplication.shared.canOpenURL(url) else {
            return nil
        }
        return url.absoluteString
    }

    func toggleInvalidURLError(_ to: Bool) {
        if customStreamSwitch.isOn {
            errorView.isHidden = !to
        } else {
            errorView.isHidden = true
        }
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    // MARK: IBAction

    @IBAction func didTapBack(_ sender: Any) {
        navigationController?.popToRootViewController(animated: true)
    }

    @IBAction func customStreamSwitchChanged(_ sender: Any) {
        customUrlTextField.isHidden = !customStreamSwitch.isOn
        if (!customStreamSwitch.isOn) {
            customUrlTextField.text = nil
            processCustomUrlText()
        }
    }
}

// MARK: - UITextField Delegate

extension SettingsViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard var text = textField.text,
              let range = Range(range, in: text)
        else { return false }
        text.replaceSubrange(range, with: string)
        textField.text = text
        processCustomUrlText()
        return false
    }

    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        processCustomUrlText()
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        processCustomUrlText()
        return false
    }
}

