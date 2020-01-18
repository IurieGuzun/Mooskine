//
//  NotesListViewController.swift
//  Mooskine
//
//  Created by Josh Svatek on 2017-05-31.
//  Copyright © 2017 Udacity. All rights reserved.
//

import UIKit
import CoreData

class NotesListViewController: UIViewController, UITableViewDataSource {
    /// A table view that displays a list of notes for a notebook
    @IBOutlet weak var tableView: UITableView!

    /// The notebook whose notes are being displayed
    var notebook: Notebook!

 //   var notes:[Note] = []
    
    var dataController: DataController!
    
    // 1
    var fetchedResultController:NSFetchedResultsController<Note>!
    
    /// A date formatter for date text in note cells
    let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .medium
        return df
    }()

    fileprivate func setupFetchResultsController() {
        let fetchRequest:NSFetchRequest<Note> = Note.fetchRequest()
        let predicate = NSPredicate(format: "notebook == %@", notebook)
        fetchRequest.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        
        // cache name should vary based on the notebook (use string interpolation toinclude the notebook name somewhere in the cache name)
        
        fetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "notebooks")
        
        fetchedResultController.delegate = self

        do {
            try fetchedResultController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
 //       tableView.reloadData() // Added by Iurie
  //      updateEditButtonState()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = notebook.name
        navigationItem.rightBarButtonItem = editButtonItem
        
        setupFetchResultsController()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
         setupFetchResultsController()
        
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: false)
            tableView.reloadRows(at: [indexPath], with: .fade)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultController = nil
    }
    // -------------------------------------------------------------------------
    // MARK: - Actions

    @IBAction func addTapped(sender: Any) {
        addNote()
    }

    // -------------------------------------------------------------------------
    // MARK: - Editing

    // Adds a new `Note` to the end of the `notebook`'s `notes` array
    func addNote() {
        let note = Note(context: dataController.viewContext)
        note.text = "New note"
        note.creationDate = Date()
        note.notebook = notebook
        try? dataController.viewContext.save()
  //      notes.insert(note, at: 0)
        tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .fade)
   //     updateEditButtonState()
    }

    // Deletes the `Note` at the specified index path
    func deleteNote(at indexPath: IndexPath) {
        let noteToDelete = fetchedResultController.object(at: indexPath)
        dataController.viewContext.delete(noteToDelete)
        do {
        try dataController.viewContext.save()
          print("Delete succeded!")
        }
        catch {
            print("Delete error : \(error.localizedDescription)")
        }
    }
    func updateEditButtonState() {
        
        if let sections = fetchedResultController.sections {
            navigationItem.rightBarButtonItem?.isEnabled = sections[0].numberOfObjects > 0
        }
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: animated)
    }

    // -------------------------------------------------------------------------
    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultController.sections?.count ?? 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultController.sections?[section].numberOfObjects ?? 0

    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let aNote = fetchedResultController.object(at: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: NoteCell.defaultReuseIdentifier, for: indexPath) as! NoteCell

        // Configure cell
        cell.textPreviewLabel.text = aNote.text
        if let creationDate = aNote.creationDate {
        cell.dateLabel.text = dateFormatter.string(from: creationDate)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete: deleteNote(at: indexPath)
        default: () // Unsupported
        }
    }

    // -------------------------------------------------------------------------
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // If this is a NoteDetailsViewController, we'll configure its `Note`
        // and its delete action
        if let vc = segue.destination as? NoteDetailsViewController {
            if let indexPath = tableView.indexPathForSelectedRow {
                vc.note = fetchedResultController.object(at: indexPath)
                vc.dataController = dataController
                vc.onDelete = { [weak self] in
                    if let indexPath = self?.tableView.indexPathForSelectedRow {
                        self?.deleteNote(at: indexPath)
                        self?.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }
    }
}
extension NotesListViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
}
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
            break
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
            break
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .fade)
        case .move:
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }

}
