//
//  SelectionViewController.swift
//  SwiftProject1
//
//  Created by Blue R&D on 2/14/17.
//  Copyright © 2017 Blue R&D. All rights reserved.
//

import UIKit

enum MenuAction : String {
    case singleChoice = "singleChoice"
    case multipleChoice = "multipleChoice"
    case about = "about"
    case settings = "settings"
    case rate = "rate"
    case share = "share"
}


class SelectionViewController: TableViewController<BaseModel> {
    
    //MARK: - Properties
    
    enum SelectionPresentType {
        case Push
        case Modal
    }
    
    var options = [SelectionItemProtocol]()
    var selectionType: MenuAction?
    var presentType: SelectionPresentType?
    var selectedIndexes = [Int]()
    var callback: ((_ selectedIndexes: [Int]) -> Void)?
    var headerView: UIView?
    var doneButton: UIButton?

    
    private init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        dismissViewController()
    }
    
    
    
    static func present(in controller: UIViewController, with options: [SelectionItemProtocol], selectionType: MenuAction, presentType: SelectionPresentType, callback: @escaping (_ selectedIndexes: [Int]) -> Void) {

        let selectionController = SelectionViewController()
        selectionController.options = options
        selectionController.selectionType = selectionType
        selectionController.presentType = presentType
        selectionController.callback = callback
        
        switch presentType {
        case .Push:
            controller.navigationController?.pushViewController(selectionController, animated: true)
        case .Modal:
            let nav = UINavigationController(rootViewController: selectionController)
            controller.addChildViewController(nav)
            controller.view.addSubview(nav.view)
            selectionController.didMove(toParentViewController: controller)
        }
    }
    
    //MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView?.mj_header.removeFromSuperview()
        tableView?.register(SelectionCell.self, forCellReuseIdentifier: SelectionCell.description())
        
        view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        
        
        setupHeaderTableView()
        
        var tableHeight = options.count * 60 + 50
        let limit = Int(UIScreen.main.bounds.size.height * 3.0/4)
        tableHeight = tableHeight > limit ? limit : tableHeight
        
        if presentType == .Modal {
            tableView?.snp.remakeConstraints({ (make) in
                make.left.equalTo(view)
                make.bottom.equalTo(view)
                make.right.equalTo(view)
                make.height.equalTo(tableHeight)
            })
        }
        
        guard let tableView = tableView else {
            return
        }
        
        tableView.frame = CGRect(x: 0, y: UIScreen.main.bounds.size.height, width: tableView.frame.size.width, height: tableView.frame.size.height)
        
        UIView.animate(withDuration: 0.5) {
            tableView.frame = CGRect(x: 0, y: CGFloat(tableHeight), width: tableView.frame.size.width, height: tableView.frame.size.height)
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView?.reloadData()
    }
    
    //MARK: - Setup views
    
    func setupHeaderTableView() {
        headerView = UIView(frame: CGRect(x: 0, y: 0, width: 400, height: 50))
        
        guard let headerView = headerView else {
            return
        }
        
        headerView.backgroundColor = UIColor.gray.withAlphaComponent(0.2)
        let title = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 40))
        title.text = "Select option"
        headerView.addSubview(title)
        title.snp.makeConstraints { (make) in
            make.center.equalTo(headerView)
        }

        
        doneButton = UIButton(type: .custom)
        
        guard let doneButton = doneButton else {
            return
        }
        
        doneButton.setTitle("Done", for: .normal)
        doneButton.setTitleColor(UIColor.blue, for: .normal)
        doneButton.addTarget(self, action: #selector(doneSelection), for: .touchUpInside)
        headerView.addSubview(doneButton)
        doneButton.snp.makeConstraints { (make) in
            make.right.equalTo(headerView).offset(-10)
            make.top.equalTo(headerView).offset(10)
            make.bottom.equalTo(headerView).offset(-10)
        }
        
    }

    //MARK: - Data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SelectionCell.description(), for: indexPath) as! SelectionCell
        let item = options[indexPath.row]
        cell.populateData(with: item)
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let selectionType = selectionType else {
            return nil
        }
        
        doneButton?.isHidden = selectionType == .singleChoice
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    //MARK: - Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let selectionType = selectionType else {
            return
        }
        
        switch selectionType {
        case .singleChoice:
            selectSingleChoice(at: indexPath)
        case .multipleChoice:
            selectMultipleChoice(at: indexPath)
        default:
            break
        }
    }
    
    
    //MARK: - Method
    
    
    func selectSingleChoice(at indexPath: IndexPath) {
        
        guard let callback = callback else {
            return
        }
        
        selectedIndexes = [Int]()
        selectedIndexes.append(indexPath.row)
        
        callback(selectedIndexes)
        endSelection()
    }
    
    func selectMultipleChoice(at indexPath: IndexPath) {
        let item = options[indexPath.row]
        item.setIsChosen(!item.isChosen())
        tableView?.reloadData()
    }
    
    func doneSelection() {
        guard let callback = callback else {
            return
        }
        
        selectedIndexes = [Int]()
        for i in 0..<options.count {
            if options[i].isChosen() {
                selectedIndexes.append(i)
            }
        }
        
        callback(selectedIndexes)
        endSelection()
    }
    
    
    func backToPreviousController () {
        let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController];
        navigationController!.popToViewController(viewControllers[viewControllers.count - 2], animated: true);
    }
    
    func dismissViewController() {
        
        guard let tableView = tableView else {
            return
        }

        UIView.animate(withDuration: 0.5, animations: { 
            tableView.frame = CGRect(x: 0, y: UIScreen.main.bounds.size.height, width: tableView.frame.size.width, height: tableView.frame.size.height)
        }) { (finish) in
            self.navigationController?.willMove(toParentViewController: nil)
            self.navigationController?.view.removeFromSuperview()
            self.navigationController?.removeFromParentViewController()
        }
    }
    
    func endSelection() {
        guard let presentType = presentType else {
            return
        }
        
        switch presentType {
        case .Push:
            backToPreviousController()
        case .Modal:
            dismissViewController()
        }
    }
    
    
    // MARK: - Selection Cell
    class SelectionCell : UITableViewCell {
        
        var icon : UIImageView?
        var title : UILabel?
        var hasIcon : Bool?
        
        
        override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            
            hasIcon = false
            
            icon = UIImageView()
            icon?.contentMode = .scaleAspectFill
            icon?.clipsToBounds = true
            if let newsImage = icon {
                contentView.addSubview(newsImage)
            }
            icon?.snp.makeConstraints({ (make) in
                make.left.equalTo(contentView).offset(10)
                make.top.equalTo(contentView).offset(10)
                make.height.equalTo(40)
                make.width.equalTo(40)
                make.bottom.equalTo(contentView).offset(-10)
            })
            
            title = UILabel()
            if let title = title {
                title.numberOfLines = 0
                title.font = UIFont.preferredFont(forTextStyle: .body)
                contentView.addSubview(title)
            }
            title?.snp.makeConstraints({ (make) in
                make.left.equalTo((icon?.snp.right)!).offset(10)
                make.top.equalTo(contentView).offset(10)
                make.right.equalTo(contentView).offset(-100)
                make.bottom.equalTo(contentView).offset(-10)
            })
        }
        
        override func updateConstraints() {
            super.updateConstraints()
            icon?.snp.makeConstraints({ (make) in
                make.height.equalTo(40)
                if hasIcon! {
                    make.width.equalTo(40)
                } else {
                    make.width.equalTo(0)
                }
            })
        }
        
        func populateData(with data: SelectionItemProtocol) {
            title?.text = data.title()?.localized()
            if let imageUrl = data.iconURL() {
                let url = URL(string: imageUrl)
                icon?.kf.setImage(with: url)
                hasIcon = true
            } else {
                hasIcon = false
            }
            
            accessoryType = data.isChosen() ? .checkmark : .none
            
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
