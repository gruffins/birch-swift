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

    var isStressTesting = false

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(stackView)

        stackView.edgeAnchors == view.edgeAnchors

        stackView.addArrangedSubview(
            createButton(title: "Toggle Debug", selector: #selector(self.toggleDebug))
        )

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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

extension ViewController {
    @objc func toggleDebug() {
        Birch.debug = !Birch.debug
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
}

