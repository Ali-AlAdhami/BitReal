//
//  HabitViewModel.swift
//  BitReal
//
//  Created by Don Nguyen on 3/23/23.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift
import SwiftUI

class HabitViewModel: ObservableObject {
    
    @Published var list = [HabitModel]()
    private var listener: ListenerRegistration?
    
<<<<<<< HEAD
    func addData(uid: String, name: String, description: String, frequency: Int, alarm: Date, privacy: Bool, streak: Int) {
=======
    init() {
        getData { success in
            self.checkProgress()
        }
    }
    
    deinit {
        listener?.remove()
    }
    
    func addData(uid: String, name: String, description: String, frequency: Int, alarm: String, privacy: Bool, streak: Int, progress: [Bool]) {
>>>>>>> dev
        let db = Firestore.firestore()
        let data = ["uid": uid,
                    "name": name,
                    "description": description,
                    "frequency": frequency,
                    "alarm": alarm,
                    "privacy": privacy,
                    "streak": streak,
                    "progress": progress,
                    "timestamp": Timestamp(date: Date()),
                    "nextSundayDate": nextSunday(),
                    "lastUpdate": Timestamp(date: Date()),
                    "skipDays": 7 - frequency] as [String : Any]
        db.collection("habits").addDocument(data: data) { error in
            
            if error == nil {
                print("Successfully added habit to Firestore")
            }
            else {
                // error handling to be added
            }
        }
    }
    
    func getData(completion: @escaping(Bool) -> Void) {
        let db = Firestore.firestore()

        // Set up a snapshot listener
        listener = db.collection("habits").whereField("uid", isEqualTo: Auth.auth().currentUser!.uid).addSnapshotListener { (snapshot, error) in
            if error == nil {
                if let snapshot = snapshot {
<<<<<<< HEAD
                    
                    self.list = snapshot.documents.map { d in
                        
                        return HabitModel(id: d.documentID,
                                          uid: d["uid"] as? String ?? "",
                                          name: d["name"] as? String ?? "",
                                          description: d["description"] as? String ?? "",
                                          frequency: d["frequency"] as? Int ?? 0,
                                          alarm: d["alarm"] as? Date ?? Date(),
                                          privacy: d["privacy"] as? Bool ?? false,
                                          streak: d["streak"] as? Int ?? 0)
                        
                    }
=======
                    self.list = snapshot.documents.compactMap({ try? $0.data(as: HabitModel.self) })
                    self.list = self.list.sorted(by: { $0.timestamp.dateValue() > $1.timestamp.dateValue() })
                    completion(true)
>>>>>>> dev
                }
            } else {
                // handle error
            }
        }
    }
    
    func updateHabitProgress(habitID: String, dayIndex: Int, completed: Bool) {
        let db = Firestore.firestore()
        let habitRef = db.collection("habits").document(habitID)
        
        habitRef.getDocument { (documentSnapshot, error) in
            if let error = error {
                print("Error fetching habit document: \(error.localizedDescription)")
                return
            }
            
            guard let document = documentSnapshot else {
                print("Habit document not found")
                return
            }
            
            guard var progress = document.get("progress") as? [Bool] else {
                print("Error retrieving progress array")
                return
            }
            let originalValue = progress[dayIndex]
            progress[dayIndex] = completed
            
            guard var streak = document.get("streak") as? Int else {
                print("Error retrieving streak count")
                return
            }
            
            guard var skipDays = document.get("skipDays") as? Int else {
                print("Error retrieving skipDays")
                return
            }
            
            guard let lastUpdated = document.get("lastUpdate") as? Timestamp else {
                print("Error retrieving last updated date")
                return
            }
            let daysSinceLastUpdate = Calendar.current.dateComponents([.day], from: lastUpdated.dateValue(), to: Date()).day ?? 0
            var updatedStreak = streak
            
            
            if daysSinceLastUpdate > skipDays {
                updatedStreak = 0
            } else {
                // prevents double logging as complete
                if (originalValue == false) {
                    skipDays -= daysSinceLastUpdate
                    updatedStreak += 1
                }
            }
            habitRef.updateData(["progress": progress,
                                 "streak": updatedStreak,
                                 "skipDays": skipDays,
                                 "lastUpdate": Timestamp(date: Date())]) { error in
                if let error = error {
                    print("Error updating habit progress: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func resetHabitProgress(habitID: String) {
        let db = Firestore.firestore()
        let habitRef = db.collection("habits").document(habitID)
        
        habitRef.getDocument { (documentSnapshot, error) in
            if let error = error {
                print("Error fetching habit document: \(error.localizedDescription)")
                return
            }
            
            guard let document = documentSnapshot else {
                print("Habit document not found")
                return
            }
            
            guard var progress = document.get("progress") as? [Bool] else {
                print("Error retrieving progress array")
                return
            }
            
            // create a new progress array and overwrite the old one
            progress = Array(repeating: false, count: 7)
            habitRef.updateData(["progress": progress]) { error in
                if let error = error {
                    print("Error updating habit progress: \(error.localizedDescription)")
                } else {
//                    print("Habit progress updated successfully")
                }
            }
            
        }
    }
    
    func nextSunday() -> Timestamp {
        let calendar = Calendar.current
        let today = Date()
        let components = DateComponents(weekday: 1)
        guard let sunday = calendar.nextDate(after: today, matching: components, matchingPolicy: .nextTime) else {
            fatalError("Could not calculate next Sunday")
        }
        return Timestamp(date: sunday)
    }
    
    func assignNewSunday(habitID: String) {
        let db = Firestore.firestore()
        let habitRef = db.collection("habits").document(habitID)
        let newTimestamp = nextSunday()
        
        habitRef.updateData([
            "nextSundayDate": newTimestamp
        ]) { err in
            if let err = err {
                print("Error updating habit timestamp: \(err)")
            } else {
//                print("Habit timestamp updated successfully")
            }
        }
    }
    
    func getHabitNextSunday(habitID: String, completion: @escaping(Timestamp) -> Void) {
        let db = Firestore.firestore()
        let habitRef = db.collection("habits").document(habitID)
        habitRef.getDocument { (documentSnapshot, error) in
            if let error = error {
                print("Error fetching habit document: \(error.localizedDescription)")
                return
            }
            
            guard let document = documentSnapshot else {
                print("Habit document not found")
                return
                
            }
            let nextSundayDate = document.get("nextSundayDate") as? Timestamp
            completion(nextSundayDate!)
        }
    }
    
    func resetSkipDays(habitID: String) {
        let db = Firestore.firestore()
        let habitRef = db.collection("habits").document(habitID)
        habitRef.getDocument { (documentSnapshot, error) in
            if let error = error {
                print("Error fetching habit document: \(error.localizedDescription)")
                return
            }
            
            guard let document = documentSnapshot else {
                print("Habit document not found")
                return
                
            }
            
            guard let freq = document.get("frequency") as? Int else {
                print("Error fetching habit frequency")
                return
            }
            
            habitRef.updateData(["skipDays": 7 - freq])
        }
    }
    
    func checkProgress() {
        let currentDate = Timestamp(date: Date())
        for i in 0 ..< self.list.count {
            getHabitNextSunday(habitID: list[i].id ?? "") { nextSundayDate in
                if currentDate.dateValue() > nextSundayDate.dateValue() {
                    self.resetHabitProgress(habitID: self.list[i].id ?? "")
                    self.assignNewSunday(habitID: self.list[i].id ?? "")
                    self.resetSkipDays(habitID: self.list[i].id ?? "")
                }
            }
        }
    }

}

