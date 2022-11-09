//
//  RowView.swift
//  Player
//
//  Created by user on 02.11.2022.
//

import UIKit

class RowView: UIView {
    private lazy var label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.backgroundColor = .black
        return label
    }()
    
    private lazy var togglingSwitch: UISwitch = {
        let togglingSwitch = UISwitch()
        togglingSwitch.translatesAutoresizingMaskIntoConstraints = false
        return togglingSwitch
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        label.text = "Gapless Playback"
        
        addSubview(label)
        addSubview(togglingSwitch)
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: self.topAnchor),
            label.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            
            togglingSwitch.topAnchor.constraint(equalTo: self.topAnchor),
            togglingSwitch.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 200, height: 31)
    }
}
