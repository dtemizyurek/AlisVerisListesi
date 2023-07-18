//
//  DetailsViewController.swift
//  AlisVerisListesi
//
//  Created by Doğukan Temizyürek on 18.07.2023.
//

import UIKit
import CoreData

class DetailsViewController: UIViewController , UIImagePickerControllerDelegate , UINavigationControllerDelegate {
    @IBOutlet weak var kaydetButton: UIButton!
    @IBOutlet weak var İmageView: UIImageView!
    
    @IBOutlet weak var İsimTextField: UITextField!
    
    @IBOutlet weak var FiyatTextField: UITextField!
    
    
    @IBOutlet weak var BedenTextField: UITextField!
    
    var secilenUrunIsmi = ""
    var secilenUrunUUID : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if secilenUrunIsmi != ""
        {
            kaydetButton.isHidden = true
            //Core Data seçilen ürün bilgilerini gösterir
            if let uuidString = secilenUrunUUID?.uuidString
            {
                let appDelagate = UIApplication.shared.delegate as! AppDelegate
                let context = appDelagate.persistentContainer.viewContext
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Alisveris")
                fetchRequest.predicate = NSPredicate(format: "id = %@", uuidString)
                fetchRequest.returnsObjectsAsFaults = false
                
                do {
                    let sonuclar = try context.fetch(fetchRequest)
                    if sonuclar.count > 0
                    {
                        for sonuc in sonuclar as! [NSManagedObject]
                        {
                            if let isim = sonuc.value(forKey: "isim") as? String
                            {
                                İsimTextField.text=isim
                            }
                            if let fiyat = sonuc.value(forKey: "fiyat") as? Int
                            {
                                FiyatTextField.text=String(fiyat)
                            }
                            if let beden = sonuc.value(forKey: "beden") as? String
                            {
                                BedenTextField.text = beden
                            }
                            if let gorselData = sonuc.value(forKey: "gorsel") as? Data
                            {
                                let image = UIImage(data:gorselData)
                                İmageView.image = image
                            }
                            
                        }
                        
                        
                        
                    }
                    
                }catch{
                    print("hata var")
                }

            }
            
        }
        else
        {
            kaydetButton.isHidden = false
            kaydetButton.isEnabled = false
            İsimTextField.text = ""
            FiyatTextField.text = ""
            BedenTextField.text = ""
        }
        
        
        İmageView.isUserInteractionEnabled = true
        
        let İmageGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(gorselSec))
        İmageView.addGestureRecognizer(İmageGestureRecognizer)
    }
    
    @objc func gorselSec()
    {
     let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker , animated: true , completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        İmageView.image = info[.originalImage] as? UIImage

        kaydetButton.isEnabled = true
        self.dismiss(animated: true , completion: nil)
    }

    @IBAction func KaydetButonTiklandi(_ sender: Any) {
    
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let alisveris = NSEntityDescription.insertNewObject(forEntityName: "Alisveris", into: context)
        
        alisveris.setValue(İsimTextField.text, forKey: "isim")
        alisveris.setValue(BedenTextField.text, forKey: "beden")
        
        if let fiyat = Int(FiyatTextField.text!)
        {
            alisveris.setValue(fiyat, forKey: "fiyat")
            
        }
        alisveris.setValue(UUID(), forKey: "id")
        
        let data = İmageView.image!.jpegData(compressionQuality: 0.5)
        
        alisveris.setValue(data, forKey: "gorsel")
        do {
            try context.save()
            print("kayıt edildi")
        }catch{
            print("hata var")
            
        }
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "veriGirildi"), object: nil)
        self.navigationController?.popViewController(animated: true)
        
        
    }
    

}
