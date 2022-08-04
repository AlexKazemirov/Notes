//
//  ViewController.swift
//  Notes
//
//  Created by Алексей Каземиров on 19.07.2022.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    var notes: [MyNote] = []
    
    let tableView: UITableView = {
        let tableView = UITableView()
        return tableView
    }()
    
    public var completion: ((String) -> Void)?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<MyNote> = MyNote.fetchRequest()
        do {
            notes = try context.fetch(fetchRequest)
            tableView.reloadData()
            
        } catch {
            print(error.localizedDescription)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Заметки"
        navigationController?.navigationBar.prefersLargeTitles = true
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.initTableView()
        configureItems()
    }
    
    
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: {(contex) in
            self.initTableView()
        }, completion: nil)
    }
    
    private func initTableView() {
        
        self.view.addSubview(self.tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.register(TableViewCell.self, forCellReuseIdentifier: "TableViewCell")
        tableView.layer.cornerRadius = 5
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        tableView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
    }
    
    private func configureItems() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(createNewNote)
        )
    }
    
    @objc func createNewNote() {
        let vc = NoteViewController(selectedNote: "", navigationTitle: "Новая заметка")
        navigationController?.pushViewController(vc, animated: true)
        
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView {
        case self.tableView:
            return self.notes.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath) as! TableViewCell
        let note = self.notes[indexPath.row]
        cell.textLabel?.text = note.noteText
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        navigationController?.pushViewController(NoteViewController(selectedNote: notes[indexPath.row].noteText!, navigationTitle: "Редактирование"), animated: true)
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let noteToDelete = notes[indexPath.row]
        guard editingStyle == .delete else {return}
        
        context.delete(noteToDelete)
        
        do {
            notes.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            try context.save()
        } catch let error as NSError {
            print(error.userInfo)
        }
    }
}

class TableViewCell: UITableViewCell {
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
}
