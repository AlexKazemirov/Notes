//
//  NoteViewController.swift
//  Notes
//
//  Created by Алексей Каземиров on 29.07.2022.
//

import UIKit
import CoreData

class NoteViewController: UIViewController {
    
    var data: [MyNote] = []
        
    var textView: UITextView = {
        let textView = UITextView()
        return textView
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configureItems()
        
    }
    
    private let selectedNote: String
    private let navigationTitle: String
    
    init(selectedNote: String, navigationTitle: String) {
        self.selectedNote = selectedNote
        self.navigationTitle = navigationTitle

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.title = "Новая заметка"
        initTextView()
        
        let vc = ViewController()
        vc.completion = { [weak self] text in
            DispatchQueue.main.async {
                self?.textView.text = text
            }
        }
        
        textView.text = selectedNote
        navigationItem.title = navigationTitle
    }
    
    private func configureItems() {
        if textView.text == "" {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(
                barButtonSystemItem: .save,
                target: self,
                action: #selector(createNewNote)
            )
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                barButtonSystemItem: .done,
                target: self,
                action: #selector(updateCoreData)
            )
        }
        
        navigationController?.hidesBarsOnSwipe = true
    }
    
    @objc private func createNewNote() {
        guard let firstVC = navigationController?.viewControllers[0] as? ViewController else {return}
        saveNote(note: textView.text)
        
        firstVC.tableView.reloadData()
        
        navigationController?.popViewController(animated: true)
    }
    @objc private func updateCoreData() {
        
    }
    
    private func initTextView() {
        self.view.addSubview(textView)
        
        textView.font = UIFont.systemFont(ofSize: 22)
        textView.autocorrectionType = UITextAutocorrectionType.yes
        textView.keyboardType = .default
        textView.returnKeyType = UIReturnKeyType.done
        textView.becomeFirstResponder()
    
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        textView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        textView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        textView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    private func saveNote(note: String) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "MyNote", in: context)
        let noteObject = NSManagedObject(entity: entity!, insertInto: context) as! MyNote
        noteObject.noteText = note
        
        do {
            try context.save()
            data.append(noteObject)
        } catch {
            print(error.localizedDescription)
        }
        
    }
}
