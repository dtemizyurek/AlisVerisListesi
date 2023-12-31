//
//  ViewController.swift
//  AlisVerisListesi
//
//  Created by Doğukan Temizyürek on 18.07.2023.
//

import UIKit
import CoreData

class ViewController: UIViewController , UITableViewDelegate, UITableViewDataSource{

    @IBOutlet weak var tableView: UITableView!
    
    var İsimDizisi = [String]()
    var idDizisi = [UUID]()
    var secilenIsim = ""
    var secilenUUID : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate=self
        tableView.dataSource=self
        
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action:#selector(EklemeButonuTiklandi))
    
        verileriAl()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(verileriAl), name: NSNotification.Name(rawValue: "veriGirildi"), object: nil)
    }
    
    @objc func verileriAl()
    {
        İsimDizisi.removeAll(keepingCapacity: false)
        idDizisi.removeAll(keepingCapacity: false)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Alisveris")
        
        fetchRequest.returnsObjectsAsFaults = false
        
        
        do {
             let sonuclar = try context.fetch(fetchRequest)
            if sonuclar.count > 0
            {
                for sonuc in sonuclar as! [NSManagedObject]
                  {
                    if  let isim = sonuc.value(forKey: "isim") as? String {
                        İsimDizisi.append(isim)
                  }
                    if let id = sonuc.value(forKey:"id") as? UUID
                                          {
                            idDizisi.append(id)
                  }
                          
                          
            }
            
         
                    
           }
            tableView.reloadData()
            
        }catch
        {
            print("hata var")
        }
        
    }

    @objc func EklemeButonuTiklandi()
    {
        performSegue(withIdentifier: "toDetailsVC" , sender: nil)
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return İsimDizisi.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text=İsimDizisi[indexPath.row]
        return cell
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailsVC"
        {
            let destinationVC = segue.destination as! DetailsViewController
            destinationVC.secilenUrunIsmi = secilenIsim
            destinationVC.secilenUrunUUID = secilenUUID
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        secilenIsim = İsimDizisi[indexPath.row]
        secilenUUID = idDizisi[indexPath.row]
        
        performSegue(withIdentifier: "toDetailsVC", sender: nil)
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete
        {
            let appDelagate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelagate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Alisveris")
            let uuidString = idDizisi[indexPath.row].uuidString
            
            fetchRequest.predicate = NSPredicate(format: "id = %@", uuidString)
            fetchRequest.returnsObjectsAsFaults = false
            
            do {
                let sonuclar = try context.fetch(fetchRequest)
                if sonuclar.count > 0
                {
                    for sonuc in sonuclar as! [NSManagedObject]
                    {
                        if let id = sonuc.value(forKey: "id") as? UUID
                        {
                            if id == idDizisi[indexPath.row]
                            {
                                context.delete(sonuc)
                                İsimDizisi.remove(at: indexPath.row)
                                idDizisi.remove(at: indexPath.row)
                                
                                self.tableView.reloadData()
                                do{
                                    try context.save()
                                }catch
                                {
                                    
                                }
                            break
                                    
                            }
                        }
                    }
                }
            }catch{
                print("hata")
            }
        }
    }

}

