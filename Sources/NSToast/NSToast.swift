import Cocoa
import NSMaterialButton

public final class NSToast: NSView {
    enum `Type` {
        case info, success, warning, error
        static let dict: [Type: NSColor] = [.error: .systemRed, .info: .systemGray, .success: .systemGreen, .warning: .systemOrange]

        var color: NSColor { Self.dict[self]! }
    }

    private static var viewStack = NSStackView()
    public static var timeInterval: TimeInterval = 4
    private var closeButton: NSButton!

    public override var wantsUpdateLayer: Bool { true }

    private init(type: Type, title: String, detail: String? = nil) {
        super.init(frame: .zero)
        self.widthAnchor.constraint(lessThanOrEqualToConstant: 500).isActive = true
        self.layer?.backgroundColor = NSColor.textBackgroundColor.cgColor

        let messageTypeIndicatorBar = NSView(frame: .zero)
        messageTypeIndicatorBar.wantsLayer = true
        messageTypeIndicatorBar.layer?.backgroundColor = type.color.cgColor
        self.addSubview(messageTypeIndicatorBar)
        messageTypeIndicatorBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            messageTypeIndicatorBar.topAnchor.constraint(equalTo: topAnchor),
            messageTypeIndicatorBar.leftAnchor.constraint(equalTo: leftAnchor),
            messageTypeIndicatorBar.bottomAnchor.constraint(equalTo: bottomAnchor),
            messageTypeIndicatorBar.widthAnchor.constraint(equalToConstant: 2)
        ])

        let titleTextField = NSTextField(string: title)
        titleTextField.isBordered = false
        titleTextField.backgroundColor = .clear
        titleTextField.isEditable = false
        let stack = NSStackView(views: [titleTextField])
        stack.alignment = .leading
        stack.orientation = .vertical

        if let detail = detail {
            let detTextField = NSTextField(string: detail)
            detTextField.isBordered = false
            detTextField.backgroundColor = .clear
            detTextField.isEditable = false
            detTextField.textColor = .secondaryLabelColor
            detTextField.controlSize = .small
            detTextField.maximumNumberOfLines = 3
            detTextField.lineBreakMode = .byWordWrapping
            stack.addArrangedSubview(detTextField)
            detTextField.leadingAnchor.constraint(equalTo: stack.leadingAnchor).isActive = true
            detTextField.trailingAnchor.constraint(equalTo: stack.trailingAnchor).isActive = true
        }

        addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            stack.rightAnchor.constraint(equalTo: rightAnchor, constant: -22),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5),
            stack.leftAnchor.constraint(equalTo: leftAnchor, constant: 5)
        ])

        closeButton = NSMaterialButton(image: #imageLiteral(resourceName: "Close"), target: self, action: #selector(self.closeButtonTap))
        closeButton.bezelStyle = .regularSquare
        closeButton.isTransparent = true
        addSubview(closeButton)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.topAnchor.constraint(equalTo: topAnchor).isActive = true
        closeButton.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
    }

    required init?(coder decoder: NSCoder) {
        fatalError()
    }


    @objc private func closeButtonTap(_ sender: NSButton) {
        removeFromSuperview()
    }

    public static func info(_ title: String, detail: String? = nil) {
        show(type: .info, title: title, detail: detail)
    }
    public static func success(_ title: String, detail: String? = nil) {
        show(type: .success, title: title, detail: detail)
    }
    public static func warning(_ title: String, detail: String? = nil) {
        show(type: .warning, title: title, detail: detail)
    }
    public static func error(_ title: String, detail: String? = nil) {
        show(type: .error, title: title, detail: detail)
    }

    private static func show(type: Type, title: String, detail: String? = nil) {
        if viewStack.superview == nil {
            if let contentView = NSApplication.shared.keyWindow?.contentView {
                contentView.addSubview(viewStack)
                viewStack.orientation = .vertical
                viewStack.translatesAutoresizingMaskIntoConstraints = false
                viewStack.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -10).isActive = true
                viewStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10).isActive = true
            }
        }
        let toast = NSToast(type: type, title: title, detail: detail)

        viewStack.addArrangedSubview(toast)

        Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: false) { _ in
            toast.removeFromSuperview()
        }
    }
}
