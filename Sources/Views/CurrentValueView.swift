//
//  FastisCurrentValueView.swift
//  Fastis
//
//  Created by Ilya Kharlamov on 10.04.2020.
//  Copyright © 2020 DIGITAL RETAIL TECHNOLOGIES, S.L. All rights reserved.
//

import UIKit

final class CurrentValueView<Value: FastisValue>: UIView {

    // MARK: - Outlets

    private lazy var label: UILabel = {
        let label = UILabel()
        label.textColor = self.config.placeholderTextColor
        label.text = self.config.placeholderTextForRanges
        label.font = self.config.textFont
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // MARK: - Variables

    private let config: FastisConfig.CurrentValueView
    private let calendar: Calendar

    /// Clear button tap handler
    internal var onClear: (() -> Void)?

    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = self.calendar.locale
        formatter.dateFormat = self.config.format
        formatter.calendar = self.calendar
        return formatter
    }()

    internal var currentValue: Value? {
        didSet {
            self.updateStateForCurrentValue()
        }
    }

    // MARK: - Lifecycle

    internal init(config: FastisConfig.CurrentValueView, calendar: Calendar) {
        self.config = config
        self.calendar = calendar
        super.init(frame: .zero)
        self.configureUI()
        self.configureSubviews()
        self.configureConstraints()
        self.updateStateForCurrentValue()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration

    private func configureUI() {
        self.backgroundColor = .clear
    }

    private func configureSubviews() {
        self.containerView.addSubview(self.label)
        self.addSubview(self.containerView)
    }

    private func configureConstraints() {
        NSLayoutConstraint.activate([
            self.label.topAnchor.constraint(equalTo: self.containerView.topAnchor),
            self.label.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor),
            self.label.centerXAnchor.constraint(equalTo: self.containerView.centerXAnchor),
            self.label.rightAnchor.constraint(lessThanOrEqualTo: self.containerView.rightAnchor),
            self.label.leftAnchor.constraint(greaterThanOrEqualTo: self.containerView.leftAnchor)
        ])
        NSLayoutConstraint.activate([
            self.containerView.topAnchor.constraint(equalTo: self.topAnchor, constant: self.config.insets.top),
            self.containerView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: self.config.insets.left),
            self.containerView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -self.config.insets.right),
            self.containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -self.config.insets.bottom)
        ])
    }

    private func updateStateForCurrentValue() {

        if let value = self.currentValue as? Date {

            self.label.text = self.dateFormatter.string(from: value)
            self.label.textColor = self.config.textColor

        } else if let value = self.currentValue as? FastisRange {

            self.label.textColor = self.config.textColor

            if value.onSameDay {
                self.label.text = self.dateFormatter.string(from: value.fromDate)
            } else {
                self.label.text = self.dateFormatter.string(from: value.fromDate) + " – " + self.dateFormatter.string(from: value.toDate)
            }

        } else {

            self.label.textColor = self.config.placeholderTextColor

            switch Value.mode {
            case .range:
                self.label.text = self.config.placeholderTextForRanges

            case .single:
                self.label.text = self.config.placeholderTextForSingle

            }

        }

    }

    // MARK: - Actions

    @objc
    private func clear() {
        self.onClear?()
    }

}

public extension FastisConfig {

    /**
     Current value view appearance (clear button, date format, etc.)

     Configurable in FastisConfig.``FastisConfig/currentValueView-swift.property`` property
     */
    struct CurrentValueView {

        /**
         Placeholder text in .range mode

         Default value — `"Select date range"`
         */
        public var placeholderTextForRanges = "Select date range"

        /**
         Placeholder text in .single mode

         Default value — `"Select date"`
         */
        public var placeholderTextForSingle = "Select date"

        /**
         Color of the placeholder for value label

         Default value — `.tertiaryLabel`
         */
        public var placeholderTextColor: UIColor = .tertiaryLabel

        /**
         Color of the value label

         Default value — `.label`
         */
        public var textColor: UIColor = .label

        /**
         Font of the value label

         Default value — `.systemFont(ofSize: 17, weight: .regular)`
         */
        public var textFont: UIFont = .systemFont(ofSize: 17, weight: .regular)

        /**
         Insets of value view

         Default value — `UIEdgeInsets(top: 8, left: 0, bottom: 24, right: 0)`
         */
        public var insets = UIEdgeInsets(top: 8, left: 0, bottom: 24, right: 0)

        /**
         Format of current value

         Default value — `"d MMMM"`
         */
        public var format = "d MMMM"

        /**
         Locale of formatter

         Default value — `Locale.autoupdatingCurrent`
         */
        @available(*, unavailable, message: "Use locale in FastisConfig.calendar.locale")
        public var locale: Locale {
            .autoupdatingCurrent
        }
    }
}
