//
//  ViewController.swift
//  RealmStudy_iOS
//
//  Created by 오킹 on 5/12/24.
//

import UIKit
import RealmSwift

class ViewController: UIViewController {
    
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Realm이 저장되는 위치
        print(Realm.Configuration.defaultConfiguration.fileURL!)
        
        saveImageToDocumentDirectory(imageName: "imageName", image: UIImage(systemName: "plus")!)
    }

    // Create
    func save(data: SomeData) throws {
        try realm.write {
            realm.add(data)
        }
    }
    
    // Read
    func getAll() -> Results<SomeData> {
        let results = realm.objects(SomeData.self)
        print(results, "result")
        return results
    }

    func getData(withId id: String) -> Results<SomeData> {
        let object = realm.objects(SomeData.self)
        let predicateQuery = NSPredicate(format: "id = %@", "\(id)") // 쿼리
        let results = object.filter(predicateQuery)
        print("results: ", results)
        
        for i in results {
            print("result: ", i)
        }

        return results
    }
    
    func saveImageToDocumentDirectory(imageName: String, image: UIImage) {
        
        // 저장할 폴더 경로
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {return}
        
        // 저장할 이미지 경로
        let imageURL = documentDirectory.appendingPathComponent(imageName)
        
        guard let data = image.jpegData(compressionQuality: 0.5) else {
            print("압축이 실패했습니다.")
            return
        }
        
        
        // 이미지 경로가 중복된다면 삭제
        if FileManager.default.fileExists(atPath: imageURL.path) {
            // 4-2. 이미지가 존재한다면 기존 경로에 있는 이미지 삭제
            do {
                try FileManager.default.removeItem(at: imageURL)
                print("이미지 삭제 완료")
            } catch {
                print("이미지를 삭제하지 못했습니다.")
            }
        }
        
        // 이미지를 파일에 저장
        do {
            try data.write(to: imageURL)
            print("FileManager 이미지 저장 완료")
            
            let someData = SomeData(id: 0, date: Date(), message: "test message", imageURL: imageURL.absoluteString)
            try save(data: someData)
            print("Realm에 데이터 저장 완료")
            
        } catch {
            print("이미지를 저장하지 못했습니다.")
        }
    }
    
    // Delete
    func realmDeleteAll() {
        do {
            try realm.write {
                
                realm.deleteAll()

            }
        } catch {
            print("deleteAll fail")
        }
    }
}

final class SomeData: Object {
    
    @Persisted var id = 0 // 기본키
    @Persisted var date = Date()
    @Persisted var message = "test"
    @Persisted var imageURL: String = ""
    
    @Persisted(primaryKey: true) var objectID: ObjectId
    
    convenience init(id: Int, date: Date, message: String, imageURL: String) {
        self.init()
        self.id = id
        self.date = date
        self.message = message
        self.imageURL = imageURL
    }
}
