//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing,
//  software distributed under the License is distributed on an
//  "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
//  KIND, either express or implied.  See the License for the
//  specific language governing permissions and limitations
//  under the License.

import UIKit



class EditorViewController: UIView {
    var editor: RichHTMLEditorView!
    var toolbarButtons = [UIView]()
    
    var toolbarCurrentColorPicker: ToolbarAction?

    // Initialize the view
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    // Setup the editor and toolbar
    func setupView() {
        setupEditor()
        setupToolbar()
    }

    func setupEditor() {
        createEditor()
    }

    func createEditor() {
        editor = RichHTMLEditorView()
        if let cssURL = Bundle.main.url(forResource: "editor", withExtension: "css"), let css = try? String(contentsOf: cssURL) {
            editor.injectAdditionalCSS(css)
        }
        editor.isScrollEnabled = true
        editor.webView.scrollView.keyboardDismissMode = .interactive
        editor.translatesAutoresizingMaskIntoConstraints = false
        addSubview(editor) // Adding the editor view to the custom view
        editor.delegate = self
        // Set up layout constraints
        NSLayoutConstraint.activate([
            editor.topAnchor.constraint(equalTo: topAnchor),
            editor.leadingAnchor.constraint(equalTo: leadingAnchor),
            editor.trailingAnchor.constraint(equalTo: trailingAnchor),
            editor.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
