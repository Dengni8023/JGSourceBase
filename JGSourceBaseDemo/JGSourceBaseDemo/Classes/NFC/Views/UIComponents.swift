import UIKit

// MARK: - 颜色常量

extension UIColor {
    static let bgPrimary   = UIColor(hex: "1A1A2E")
    static let bgSecondary = UIColor(hex: "16213E")
    static let bgTertiary  = UIColor(hex: "0F3460")
    static let accentPurple = UIColor(hex: "6C5CE7")
    static let accentBlue   = UIColor(hex: "0984E3")
    static let accentCyan   = UIColor(hex: "74B9FF")
    static let accentGreen  = UIColor(hex: "00B894")
    static let accentYellow = UIColor(hex: "FDCB6E")
    static let accentRed    = UIColor(hex: "FF7675")
    static let textPrimary   = UIColor(hex: "FFFFFF")
    static let textSecondary = UIColor(hex: "DFE6E9")
    static let textTertiary  = UIColor(hex: "B2BEC3")

    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}

// MARK: - 渐变工具

extension UIView {
    func applyGradient(colors: [UIColor], startPoint: CGPoint = CGPoint(x: 0, y: 0),
                       endPoint: CGPoint = CGPoint(x: 1, y: 1)) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint
        gradientLayer.frame = bounds
        layer.insertSublayer(gradientLayer, at: 0)
    }

    func applyGlassmorphism(cornerRadius: CGFloat = 16, opacity: Float = 0.15) {
        let blur = UIBlurEffect(style: .dark)
        let blurView = UIVisualEffectView(effect: blur)
        blurView.frame = bounds
        blurView.layer.cornerRadius = cornerRadius
        blurView.clipsToBounds = true
        blurView.alpha = CGFloat(opacity)
        insertSubview(blurView, at: 0)
    }
}

// MARK: - 脉冲动画视图

class PulseAnimationView: UIView {

    private let pulseLayer1 = CAShapeLayer()
    private let pulseLayer2 = CAShapeLayer()
    private let pulseLayer3 = CAShapeLayer()
    private let centerCircle = CAShapeLayer()
    private let nfcIconLabel = UILabel()

    var isAnimating = false {
        didSet { isAnimating ? startPulse() : stopPulse() }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayers()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayers()
    }

    private func setupLayers() {
        backgroundColor = .clear

        let pulseLayers: [CAShapeLayer] = [pulseLayer1, pulseLayer2, pulseLayer3]
        pulseLayers.forEach { layer in
            layer.fillColor = UIColor.accentPurple.withAlphaComponent(0.08).cgColor
            layer.strokeColor = UIColor.accentPurple.withAlphaComponent(0.3).cgColor
            layer.lineWidth = 1.5
            addLayer(layer)
        }

        // 中心圆
        centerCircle.fillColor = UIColor.accentPurple.withAlphaComponent(0.2).cgColor
        centerCircle.strokeColor = UIColor.accentCyan.cgColor
        centerCircle.lineWidth = 2
        addLayer(centerCircle)

        // NFC 图标文字
        nfcIconLabel.text = "NFC"
        nfcIconLabel.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        nfcIconLabel.textColor = .textPrimary
        nfcIconLabel.textAlignment = .center
        addSubview(nfcIconLabel)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let baseSize: CGFloat = min(bounds.width, bounds.height) * 0.25

        let pulseLayers: [CAShapeLayer] = [pulseLayer1, pulseLayer2, pulseLayer3]
        pulseLayers.enumerated().forEach { index, layer in
            let size = baseSize * CGFloat(1 + Double(index) * 0.5)
            layer.path = UIBezierPath(arcCenter: center, radius: size / 2,
                                       startAngle: 0, endAngle: .pi * 2, clockwise: true).cgPath
        }

        let centerSize = baseSize * 0.8
        centerCircle.path = UIBezierPath(arcCenter: center, radius: centerSize / 2,
                                          startAngle: 0, endAngle: .pi * 2, clockwise: true).cgPath

        nfcIconLabel.frame = CGRect(x: center.x - 30, y: center.y - 15, width: 60, height: 30)
    }

    private func addLayer(_ layer: CAShapeLayer) {
        layer.position = .zero
        self.layer.addSublayer(layer)
    }

    func startPulse() {
        [pulseLayer1, pulseLayer2, pulseLayer3].enumerated().forEach { index, layer in
            let animation = CABasicAnimation(keyPath: "transform.scale")
            animation.fromValue = 1.0
            animation.toValue = 1.8
            animation.duration = 2.0
            animation.beginTime = CACurrentMediaTime() + Double(index) * 0.4
            animation.repeatCount = .infinity
            animation.autoreverses = true
            animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            layer.add(animation, forKey: "pulse_\(index)")

            let opacityAnim = CABasicAnimation(keyPath: "opacity")
            opacityAnim.fromValue = 1.0
            opacityAnim.toValue = 0.2
            opacityAnim.duration = 2.0
            opacityAnim.beginTime = CACurrentMediaTime() + Double(index) * 0.4
            opacityAnim.repeatCount = .infinity
            opacityAnim.autoreverses = true
            opacityAnim.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            layer.add(opacityAnim, forKey: "pulse_opacity_\(index)")
        }

        // 中心圆发光动画
        let glowAnimation = CABasicAnimation(keyPath: "shadowOpacity")
        glowAnimation.fromValue = 0.3
        glowAnimation.toValue = 0.8
        glowAnimation.duration = 1.5
        glowAnimation.repeatCount = .infinity
        glowAnimation.autoreverses = true
        centerCircle.shadowColor = UIColor.accentCyan.cgColor
        centerCircle.shadowRadius = 15
        centerCircle.add(glowAnimation, forKey: "glow")
    }

    func stopPulse() {
        [pulseLayer1, pulseLayer2, pulseLayer3].enumerated().forEach { index, layer in
            layer.removeAllAnimations()
        }
        centerCircle.removeAllAnimations()
    }
}

// MARK: - 协议标签视图

class ProtocolTagView: UIView {

    let protocolType: NFCProtocolType
    let toggleButton = UIButton()

    var isSelected = true {
        didSet { updateAppearance() }
    }

    var onToggle: ((Bool) -> Void)?

    init(protocolType: NFCProtocolType) {
        self.protocolType = protocolType
        super.init(frame: .zero)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        backgroundColor = UIColor(hex: protocolType.color).withAlphaComponent(0.2)
        layer.cornerRadius = 16
        layer.borderWidth = 1
        layer.borderColor = UIColor(hex: protocolType.color).withAlphaComponent(0.5).cgColor

        toggleButton.setTitle("\(protocolType.icon) \(protocolType.displayName)", for: .normal)
        toggleButton.titleLabel?.font = UIFont.systemFont(ofSize: 10, weight: .medium)
        toggleButton.setTitleColor(.textPrimary, for: .normal)
        toggleButton.setTitleColor(.textTertiary, for: .normal)
        toggleButton.contentEdgeInsets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
        toggleButton.addTarget(self, action: #selector(didToggle), for: .touchUpInside)

        addSubview(toggleButton)
        toggleButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            toggleButton.topAnchor.constraint(equalTo: topAnchor),
            toggleButton.bottomAnchor.constraint(equalTo: bottomAnchor),
            toggleButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            toggleButton.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])

        updateAppearance()
    }

    @objc private func didToggle() {
        isSelected.toggle()
        onToggle?(isSelected)
    }

    private func updateAppearance() {
        if isSelected {
            backgroundColor = UIColor(hex: protocolType.color).withAlphaComponent(0.25)
            layer.borderColor = UIColor(hex: protocolType.color).cgColor
            toggleButton.setTitleColor(.textPrimary, for: .normal)
            alpha = 1.0
        } else {
            backgroundColor = UIColor.bgSecondary.withAlphaComponent(0.3)
            layer.borderColor = UIColor.textTertiary.withAlphaComponent(0.2).cgColor
            toggleButton.setTitleColor(.textTertiary, for: .normal)
            alpha = 0.5
        }
    }
}
