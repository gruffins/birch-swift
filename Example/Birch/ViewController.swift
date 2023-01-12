//
//  ViewController.swift
//  Birch
//
//  Created by Ryan Fung on 11/22/2022.
//  Copyright (c) 2022 Ryan Fung. All rights reserved.
//

import UIKit
import Birch
import Anchorage

class ViewController: UIViewController {

    let stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 4
        return view
    }()

    lazy var toggleDebugButton: UIButton = {
        createButton(title: "Toggle Debug", selector: #selector(self.toggleDebug))
    }()

    lazy var toggleLevelButton: UIButton = {
        createButton(title: "Toggle Level", selector: #selector(self.toggleLevel))
    }()

    lazy var toggleConsoleButton: UIButton = {
        createButton(title: "Toggle Console", selector: #selector(self.toggleConsole))
    }()

    lazy var toggleRemoteButton: UIButton = {
        createButton(title: "Toggle Remote", selector: #selector(self.toggleRemote))
    }()

    lazy var toggleSynchronousButton: UIButton = {
        createButton(title: "Toggle Synchronous", selector: #selector(self.toggleSynchronous))
    }()

    var isStressTesting = false

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(stackView)

        stackView.edgeAnchors == view.edgeAnchors

        [toggleDebugButton, toggleLevelButton, toggleConsoleButton, toggleConsoleButton, toggleRemoteButton, toggleSynchronousButton].forEach {
            stackView.addArrangedSubview($0)
        }

        stackView.addArrangedSubview(
            createButton(title: "Trace", selector: #selector(self.trace))
        )

        stackView.addArrangedSubview(
            createButton(title: "Debug", selector: #selector(self.debug))
        )

        stackView.addArrangedSubview(
            createButton(title: "Info", selector: #selector(self.info))
        )

        stackView.addArrangedSubview(
            createButton(title: "Warn", selector: #selector(self.warn))
        )

        stackView.addArrangedSubview(
            createButton(title: "Error", selector: #selector(self.error))
        )

        stackView.addArrangedSubview(
            createButton(title: "Stress Test", selector: #selector(self.stressTest))
        )

        setState()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

extension ViewController {
    @objc func toggleDebug() {
        Birch.debug = !Birch.debug
        setState()
    }

    @objc func toggleLevel() {
        if let level = Birch.level {
            switch level {
            case .none:
                Birch.level = nil
            case .trace:
                Birch.level = .debug
            case .debug:
                Birch.level = .info
            case .info:
                Birch.level = .warn
            case .warn:
                Birch.level = .error
            case .error:
                Birch.level = Level.none
            }
        } else {
            Birch.level = .trace
        }

        setState()
    }

    @objc func toggleConsole() {
        Birch.console = !Birch.console
        setState()
    }

    @objc func toggleRemote() {
        Birch.remote = !Birch.remote
        setState()
    }

    @objc func toggleSynchronous() {
        Birch.synchronous = !Birch.synchronous
        setState()
    }

    @objc func trace() {
        Birch.t { "trace message" }
    }

    @objc func debug() {
        Birch.d { "debug message" }
    }

    @objc func info() {
        Birch.i { "info message" }
    }

    @objc func warn() {
        Birch.w { "warn message" }
    }

    @objc func error() {
        Birch.e { "error message" }
    }

    @objc func stressTest() {
        guard !isStressTesting else {
            return
        }
        isStressTesting = true

        for idx in 1...20000 {
            DispatchQueue.global().async {
                Birch.d { "test \(idx)" }
            }
        }

        isStressTesting = false
    }
}

private extension ViewController {
    func createButton(title: String, selector: Selector) -> UIButton {
        let button = UIButton(type: .roundedRect)
        button.setTitle(title, for: .normal)
        button.addTarget(self, action: selector, for: .touchUpInside)
        return button
    }

    func setState() {
        toggleDebugButton.setTitle("Debug \(Birch.debug)", for: .normal)
        toggleLevelButton.setTitle("Level \(String(describing: Birch.level))", for: .normal)
        toggleConsoleButton.setTitle("Console \(Birch.console)", for: .normal)
        toggleRemoteButton.setTitle("Remote \(Birch.remote)", for: .normal)
        toggleSynchronousButton.setTitle("Synchronous \(Birch.synchronous)", for: .normal)
    }
}

