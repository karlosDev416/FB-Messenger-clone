//
//  ViewController.swift
//  facebook-messenger
//
//  Created by Karlos Aguirre on 10/24/18.
//  Copyright © 2018 Karlos Aguirre. All rights reserved.
//

import UIKit
import CoreData

private let cellIdentifier = "cellIdentifier"

class FriendsController: UICollectionViewController, UICollectionViewDelegateFlowLayout, NSFetchedResultsControllerDelegate {
    
    lazy var fetchedResultsController:NSFetchedResultsController<NSFetchRequestResult> = {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Friend")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "lastMessage.date", ascending: false)]
        fetchRequest.predicate = NSPredicate(format: "lastMessage != nil")
        let delegate = UIApplication.shared.delegate as? AppDelegate
        if let managedContext = delegate?.persistentContainer.viewContext {
            let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedContext, sectionNameKeyPath: nil, cacheName: nil)
            return frc
        }
        return NSFetchedResultsController()
    }()
    
    var blockOperations = [BlockOperation]()
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        if type == .insert {
            blockOperations.append(BlockOperation(block: {
                self.collectionView.insertItems(at: [newIndexPath!])
            }))
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        collectionView.performBatchUpdates({
            for operation in blockOperations {
                operation.start()
            }
        }) { (completed) in
            let lastItem = self.fetchedResultsController.sections![0].numberOfObjects - 1
            let indexPath = IndexPath(item: lastItem, section: 0)
            self.collectionView.scrollToItem(at: indexPath, at: .bottom, animated: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        tabBarController?.tabBar.isHidden = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Recent"
        
        fetchedResultsController.delegate = self
        
        collectionView.backgroundColor = .white
        collectionView.register(MessageCell.self, forCellWithReuseIdentifier: cellIdentifier)
        
        setupData()
        
        do {
            try fetchedResultsController.performFetch()
        } catch let err {
            print(err)
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add Tupac", style: .plain, target: self, action: #selector(addTupac))
    }
    
    @IBAction func addTupac() {
        let delegate = UIApplication.shared.delegate as? AppDelegate
        if let managedContext = delegate?.persistentContainer.viewContext {
            let tupac = NSEntityDescription.insertNewObject(forEntityName: "Friend", into: managedContext) as! Friend
            tupac.name = "Tupac Shakur"
            tupac.profileImageName = "tupac"
            
            FriendsController.createMessage(with: "Hello my name is Tupac, nice to meet you... ", friend: tupac, minsAgo: 0, context: managedContext)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let count = fetchedResultsController.sections?[section].numberOfObjects {
            return count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 100)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! MessageCell
        
        if let friend = fetchedResultsController.object(at: indexPath) as? Friend {
            cell.message = friend.lastMessage
        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let layout = UICollectionViewFlowLayout()
        let controller = ChatLogController(collectionViewLayout: layout)
        if let friend = fetchedResultsController.object(at: indexPath) as? Friend {
            controller.friend = friend
        }
        navigationController?.pushViewController(controller, animated: true)
    }
}

class MessageCell: BaseCell {
    
    override var isHighlighted: Bool {
        didSet {
            
            backgroundColor = isHighlighted ? UIColor(red: 0, green: 134/255, blue: 240/255, alpha: 1) : UIColor.white
            
            nameLbl.textColor = isHighlighted ? UIColor.white : UIColor.black
            timeLbl.textColor = isHighlighted ? UIColor.white : UIColor.black
            messageLbl.textColor = isHighlighted ? UIColor.white : UIColor.black
        }
    }
    
    var message: Message? {
        didSet {
            nameLbl.text = message?.friend?.name
            if let profileImageName = message?.friend?.profileImageName {
                profileImageView.image = UIImage(named: profileImageName)
                hasReadImageView.image = UIImage(named: profileImageName)
            }
            messageLbl.text = message?.text
            
            if let date = message?.date {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "h:mm a"
                
                let elapsedTimeInSeconds = NSDate().timeIntervalSince(date)
                let secondsInDays:TimeInterval = 60*60*24
                if elapsedTimeInSeconds > 7 * secondsInDays {
                    dateFormatter.dateFormat = "MM/dd/yy"
                } else if elapsedTimeInSeconds > secondsInDays {
                    dateFormatter.dateFormat = "EEE"
                }
                timeLbl.text = dateFormatter.string(from: date)
            }
        }
    }
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 34
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    let dividerLineView: UIView = {
        let line = UIView()
        line.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
        return line
    }()
    
    let nameLbl: UILabel = {
        let lbl = UILabel()
        lbl.text = "Tupac Shakur"
        lbl.font = UIFont.systemFont(ofSize: 18)
        return lbl
    }()
    
    let messageLbl: UILabel = {
        let lbl = UILabel()
        lbl.text = "Your friend's message and something else..."
        lbl.textColor = UIColor.darkGray
        lbl.font = UIFont.systemFont(ofSize: 14)
        return lbl
    }()
    
    let timeLbl: UILabel = {
        let lbl = UILabel()
        lbl.text = "11:22 pm"
        lbl.font = UIFont.systemFont(ofSize: 18)
        return lbl
    }()
    
    let hasReadImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 10
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    override func setupViews() {
        
        addSubview(profileImageView)
        addSubview(dividerLineView)
        
        setupContainerView()
        
        profileImageView.image = UIImage(named: "tupac")
        hasReadImageView.image = UIImage(named: "tupac")
        
        addoConstraintWithFormat("H:|-12-[v0(68)]", views:profileImageView)
        addoConstraintWithFormat("V:[v0(68)]", views:profileImageView)
        
        addConstraint(NSLayoutConstraint(item: profileImageView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0))
        
        addoConstraintWithFormat("H:|-82-[v0]|", views:dividerLineView)
        addoConstraintWithFormat("V:[v0(1)]|", views:dividerLineView)
    }
    
    private func setupContainerView() {
        let containerView = UIView()
        addSubview(containerView)
        
        addoConstraintWithFormat("H:|-90-[v0]|", views: containerView)
        addoConstraintWithFormat("V:[v0(60)]", views: containerView)
        
        addConstraint(NSLayoutConstraint(item: containerView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0))
        
        containerView.addSubview(nameLbl)
        containerView.addSubview(messageLbl)
        containerView.addSubview(timeLbl)
        containerView.addSubview(hasReadImageView)
        
        containerView.addoConstraintWithFormat("H:|[v0][v1(80)]-12-|", views: nameLbl, timeLbl)
        containerView.addoConstraintWithFormat("V:|[v0][v1(24)]|", views: nameLbl, messageLbl)
        containerView.addoConstraintWithFormat("H:|[v0]-8-[v1(20)]-12-|", views: messageLbl, hasReadImageView)
        containerView.addoConstraintWithFormat("V:|[v0(24)]|", views: timeLbl)
        containerView.addoConstraintWithFormat("V:[v0(20)]|", views: hasReadImageView)
    }
}

extension UIView {
    
    func addoConstraintWithFormat(_ format:String, views:UIView...) {
        var viewsDictionary = [String:UIView]()
        for (index, view) in views.enumerated() {
            let key = "v\(index)"
            viewsDictionary[key] = view
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: viewsDictionary))
    }
}

class BaseCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() { }
}
    
