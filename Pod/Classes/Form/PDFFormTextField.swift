//
//  PDFFormTextField.swift
//  Pods
//
//  Created by Chris Anderson on 5/26/16.
//
//

import UIKit

open class PDFFormTextField: PDFFormField {
    let multiline: Bool
    let textEntryBox: UIView
    let baseFontSize: CGFloat
    let currentFontSize: CGFloat
    let alignment: NSTextAlignment
    
    var text: String {
        get {
            if let textField = textEntryBox as? UITextField {
                return textField.text ?? ""
            }
            if let textView = textEntryBox as? UITextView {
                return textView.text ?? ""
            }
            return ""
        }
        set(updatedText) {
            if let textField = textEntryBox as? UITextField {
                textField.text = updatedText
            }
            if let textView = textEntryBox as? UITextView {
                textView.text = updatedText
            }
        }
    }
    
    init(frame: CGRect, multiline: Bool, alignment: NSTextAlignment) {
        let rect = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
        
        textEntryBox = multiline
            ? UITextView(frame: rect)
            : UITextField(frame: rect)
        self.multiline = multiline
        baseFontSize = 12.0
        currentFontSize = baseFontSize
        self.alignment = alignment
        
        super.init(frame: frame)
        
        setupUI()
    }
    
    func setupUI() {
        backgroundColor = UIColor(red: 0.7, green: 0.85, blue: 1.0, alpha: 0.7)
        if multiline {
            if let textView = textEntryBox as? UITextView {
                textView.textAlignment = alignment
                textView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                textView.delegate = self
                textView.isScrollEnabled = true
                textView.textContainerInset = UIEdgeInsets.init(top: 4, left: 4, bottom: 4, right: 4)
                let fontSize = fontSizeForRect(frame) < 13.0 ? fontSizeForRect(frame) : 13.0
                textView.font = UIFont.systemFont(ofSize: fontSize)
            }
        }
        else {
            if let textField = textEntryBox as? UITextField {
                textField.textAlignment = alignment
                textField.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                textField.delegate = self
                textField.adjustsFontSizeToFitWidth = true
                textField.minimumFontSize = 6.0
                textField.font = UIFont.systemFont(ofSize: fontSizeForRect(self.frame))
                textField.addTarget(self, action: #selector(PDFFormTextField.textChanged), for: .editingChanged)
            }
            
            layer.cornerRadius = frame.size.height / 6
        }
        
        textEntryBox.isOpaque = false
        textEntryBox.backgroundColor = UIColor.clear
        
        addSubview(textEntryBox)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func refresh() {
        setNeedsDisplay()
        textEntryBox.setNeedsDisplay()
    }
    
    override func didSetValue(_ value: AnyObject?) {
        if let value = value as? String {
            text = value
        }
    }
    
    func fontSizeForRect(_ rect: CGRect) -> CGFloat {
        return rect.size.height * 0.7
    }
    
    override func renderInContext(_ context: CGContext) {
        let text: String
        let font: UIFont
        if let textField = textEntryBox as? UITextField {
            text = textField.text ?? ""
            font = textField.font!
        }
        else if let textView = textEntryBox as? UITextView {
            text = textView.text
            font = textView.font!
        }
        else {
            fatalError()
        }
        
        (text as NSString).draw(in: frame, withAttributes: convertToOptionalNSAttributedStringKeyDictionary([
            convertFromNSAttributedStringKey(NSAttributedString.Key.font): font
            ]))
    }
}

extension PDFFormTextField: UITextFieldDelegate {
    @objc func textChanged() {
        value = text as AnyObject?
        delegate?.formFieldValueChanged(self)
    }
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        delegate?.formFieldEntered(self)
    }
}

extension PDFFormTextField: UITextViewDelegate {
    public func textViewDidBeginEditing(_ textView: UITextView) {
        delegate?.formFieldEntered(self)
    }
    
    public func textViewDidChange(_ textView: UITextView) {
        delegate?.formFieldValueChanged(self)
    }
    
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newString = (textView.text! as NSString).replacingCharacters(in: range, with: text)
        value = newString as AnyObject?

        delegate?.formFieldValueChanged(self)
        return false
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
	return input.rawValue
}
