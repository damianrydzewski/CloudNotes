//
//  ContentView.swift
//  Notes
//
//  Created by Damian on 07/11/2022.
//ł

import SwiftUI

struct Home: View {
    
    @State private var notes = [Note]()
    @State private var showAdd = false
    @State private var showAlert = false
    @State private var deleteItem: Note?
    @State private var isEditMode: EditMode = .inactive
    @State private var updateNote = ""
    @State private var updateNoteID = ""
    
    var alert: Alert {
        Alert(title: Text("Delete"), message: Text("Are you sure to delete this note?"), primaryButton: .destructive(Text("Delete"), action: deleteNote), secondaryButton: .cancel())
    }
    
    var body: some View {

        NavigationView {
            List(notes) { note in
                if isEditMode == .inactive {
                    Text(note.note)
                        .onLongPressGesture {
                            self.showAlert.toggle()
                            deleteItem = note
                        }
                } else {
                    HStack {
                        Image(systemName: "pencil.circle")
                            .foregroundColor(.yellow)
                        Text(note.note)
                            .onLongPressGesture {
                                self.showAlert.toggle()
                                deleteItem = note
                            }
                    }
                    .onTapGesture {
                        self.updateNote = note.note
                        self.updateNoteID = note._id
                        self.showAdd.toggle()
                    }
                }
            }
            .alert(isPresented: $showAlert, content: {
                alert
            })
            .sheet(isPresented: $showAdd, onDismiss: fetchNotes) {
                if self.isEditMode == .inactive {
                    AddNoteView()
                } else {
                    UpdateNoteView(text: $updateNote, noteID: $updateNoteID)
                }
            }
            .navigationTitle("☁️ Cloud Notes")
            .onAppear {
                fetchNotes()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add note"){showAdd.toggle()}
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        if isEditMode == .inactive {
                            isEditMode = .active
                        } else {
                            isEditMode = .inactive
                        }
                    }, label: {
                        if isEditMode == .inactive {
                            Text("Edit")
                        } else {
                            Text("Done ")
                        }
                    })
                }
            }
        }
    }
    
    func fetchNotes() {
        let url = URL(string: "http://localhost:3000/notes")!
        let task = URLSession.shared.dataTask(with: url) { data, res, err in
            guard let data else {return}
            
            do {
                let fecthedNotes = try JSONDecoder().decode([Note].self, from: data)
                self.notes = fecthedNotes
                print(fecthedNotes)
            }
            catch {
                print(error)
            }
        }
        
        task.resume()
        
        if isEditMode == .active {
            self.isEditMode = .inactive
        }
    }
    
    func deleteNote() {
        guard let id = deleteItem?._id else {return}
        
        let url = URL(string: "http://localhost:3000/notes/\(id)")!
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        let task = URLSession.shared.dataTask(with: request) { data, res, err in
            guard err == nil else {return}
            guard let data = data else {return}
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:Any]{
                    print(json)
                }
            }
            catch let err {
                print(err)
            }
        }
        task.resume()
        fetchNotes()
    }
    
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}
