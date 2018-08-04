
import UIKit
import DropDown

class TaskCreateViewController: BaseViewController {

    var task: TaskModel?
    
	var postModel: PostModel? {
		didSet {
			postID = postModel?.postID
		}
	}
	var postID: String!

    @IBOutlet weak var lbPhoneTitle: UILabel! {
        didSet {
            lbPhoneTitle.text = "Phone".localized()
        }
    }
    @IBOutlet weak var lbPhone: UILabel!

    @IBOutlet weak var lbJob: UILabel! {
        didSet {
            lbJob.text = "Job".localized()
        }
    }
    @IBOutlet weak var jobLB: UILabel! {
        didSet {
            jobLB.text = "SelectJob".localized()
        }
    }
    
    @IBOutlet weak var lbSalary: UILabel! {
        didSet {
            lbSalary.text = "Salary".localized()
        }
    }
    @IBOutlet weak var salaryTF: UITextField! {
        didSet {
            salaryTF.placeholder = "InputSalary".localized()
        }
    }

    @IBOutlet weak var lbStartTime: UILabel! {
        didSet {
            lbStartTime.text = "Start".localized()
        }
    }

    @IBOutlet weak var startBtn: UIButton!
    @IBOutlet weak var startImage: UIImageView!
    @IBOutlet weak var startLB: UILabel! {
        didSet {
            startLB.text = "StartDate".localized()
        }
    }
    
    @IBOutlet weak var lbEndTime: UILabel! {
        didSet {
            lbEndTime.text = "End".localized()
        }
    }
    @IBOutlet weak var endBtn: UIButton!
    @IBOutlet weak var endImage: UIImageView!
    @IBOutlet weak var endLB: UILabel! {
        didSet {
            endLB.text = "EndDate".localized()
        }
    }
    
    @IBOutlet weak var descriptionView: UIView!
    
    @IBOutlet weak var lbDescription: UILabel! {
        didSet {
            lbDescription.text = "Description".localized()
        }
    }
    @IBOutlet weak var descriptionTF: UITextView!

    @IBOutlet weak var lbStartHour: UILabel!
    @IBOutlet weak var btnStartHour: UIButton! {
        didSet {
            btnStartHour.layer.cornerRadius = btnStartHour.frame.height/2.0
            btnStartHour.layer.borderWidth = 1
            btnStartHour.layer.borderColor = backGroundColor?.cgColor
        }
    }

    @IBOutlet weak var lbEndHour: UILabel!
    @IBOutlet weak var btnEndHour: UIButton! {
        didSet {
            btnEndHour.layer.cornerRadius = btnEndHour.frame.height/2.0
            btnEndHour.layer.borderWidth = 1
            btnEndHour.layer.borderColor = backGroundColor?.cgColor
        }
    }

    @IBOutlet weak var doneBtn: UIButton!  {
        didSet {
            doneBtn.setTitle("Done".localized().uppercased(), for: .normal)
        }
    }

    var backGroundColor = UIColor(hexString: "#33CCFF")

    private let pickerView = UIPickerView()
    private let datePickerView = UIDatePicker()
    private let contentPickerView = UIView()
    private let overLapView = UIView()
    fileprivate var typePicker: Int = 5 // 2: date start, 3: date end, 4: Period, 5: start hour, 6: end hour

    fileprivate var startDate: Date?
    fileprivate var endDate: Date?
    private var jobDescription: String?
    let dateFormatter = DateFormatter()

    var isModifying = false
    let datePickerStart = UIDatePicker()
    let datePickerEnd = UIDatePicker()

    override func viewDidLoad() {
        super.viewDidLoad()

        configNavigaton()
        

        lbPhone.text = postModel?.userModel?.phone
        jobLB.text = postModel?.category_title

        salaryTF.layer.cornerRadius = salaryTF.frame.height/2.0
        salaryTF.clipsToBounds = true
        salaryTF.layer.borderWidth = 1
        salaryTF.layer.borderColor = backGroundColor?.cgColor
        let salaryTFPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: salaryTF.frame.height))
        salaryTF.leftView = salaryTFPaddingView
        salaryTF.leftViewMode = .always
        salaryTF.keyboardType = .numberPad

        startBtn.layer.cornerRadius = startBtn.frame.height/2.0
        startBtn.clipsToBounds = true
        startBtn.layer.borderWidth = 1
        startBtn.layer.borderColor = backGroundColor?.cgColor
        startImage.image = startImage.image?.withRenderingMode(.alwaysTemplate)
        startImage.tintColor = backGroundColor
        
        endBtn.layer.cornerRadius = endBtn.frame.height/2.0
        endBtn.clipsToBounds = true
        endBtn.layer.borderWidth = 1
        endBtn.layer.borderColor = backGroundColor?.cgColor
        endImage.image = endImage.image?.withRenderingMode(.alwaysTemplate)
        endImage.tintColor = backGroundColor
        
        descriptionView.layer.cornerRadius = 5
        descriptionView.clipsToBounds = true
        descriptionView.layer.borderWidth = 1
        descriptionView.layer.borderColor = backGroundColor?.cgColor
        
        doneBtn.layer.cornerRadius = doneBtn.frame.height/2.0
        doneBtn.clipsToBounds = true
        
        // For PickerView
        let pickerHeight = CGFloat(120)
        overLapView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        overLapView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        
        contentPickerView.frame = CGRect(x: 0, y:  UIScreen.main.bounds.size.height - 20 - pickerHeight , width: UIScreen.main.bounds.size.width, height: pickerHeight + 20)
        contentPickerView.backgroundColor = backGroundColor
        
        pickerView.frame = CGRect(x: 0, y:  20 , width: UIScreen.main.bounds.size.width, height: pickerHeight)
        contentPickerView.addSubview(pickerView)
        pickerView.dataSource = self
        pickerView.delegate = self
        pickerView.selectRow(0, inComponent: 0, animated: false)
        pickerView.backgroundColor = UIColor.clear
        pickerView.isHidden = true
        
        datePickerView.frame = CGRect(x: 0, y:  20 , width: UIScreen.main.bounds.size.width, height: pickerHeight)
        datePickerView.datePickerMode = .date
        datePickerView.addTarget(self, action: #selector(datePickerChanged(datePicker:)), for: UIControlEvents.valueChanged)
        datePickerView.isHidden = true
        datePickerView.setValue(UIColor.white, forKeyPath: "textColor")
        contentPickerView.addSubview(datePickerView)
        
        let pickerDoneBtn = UIButton(frame: CGRect(x: UIScreen.main.bounds.size.width - 70, y: 5, width: 50, height: 15))
        pickerDoneBtn.setTitle("Done", for: .normal)
        pickerDoneBtn.setTitleColor(UIColor.white, for: .normal)
        pickerDoneBtn.backgroundColor = UIColor.clear
        pickerDoneBtn.addTarget(self, action: #selector(onBtnPickerDone), for: .touchUpInside)
        contentPickerView.addSubview(pickerDoneBtn)
        
        overLapView.addSubview(contentPickerView)
        
        navigationController?.view.addSubview(overLapView)
        overLapView.isHidden = true
        dateFormatter.dateFormat = "yyyy-MM-dd"
        if let postModel = postModel {
            setUpWithPostModel(postModel: postModel)
        }
        
        let tapViewOut = UITapGestureRecognizer(target:self,action:#selector(tapView))
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(tapViewOut)

}

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // check authen

        if let session = Authenticator.shareInstance.getAuthSession(), let user = session.user {
            if user.verified {

            }
            else {
                showDialog(title: "Hune".localized(), message: "NeedVerified".localized(), buttonTitle: "Cancel", handler: { (action) in
                    self.navigationController?.popViewController(animated: true)
                }, rightButtonTitle: "OK") { (action) in
                    (UIApplication.shared.delegate as? AppDelegate)?.makeCenterView()
                }
            }
        }
        else {
            showDialog(title: "Hune".localized(), message: "NeedAuthentication".localized(), buttonTitle: "Cancel", handler: { (action) in
                self.navigationController?.popViewController(animated: true)
            }, rightButtonTitle: "OK") { (action) in
                (UIApplication.shared.delegate as? AppDelegate)?.makeCenterView()
            }
        }
    }

    func configNavigaton()  {
        
        // Add left bar button
        let leftButton = UIButton.init(type: .custom)
        leftButton.setImage(UIImage(named: "ic_back")?.withRenderingMode(.alwaysTemplate), for: .normal)
        leftButton.addTarget(self, action:#selector(cancelPost), for: UIControlEvents.touchUpInside)
        leftButton.frame = CGRect.init(x: 0, y: 0, width: 10, height: 20)
        leftButton.tintColor = .white
        leftButton.backgroundColor = .clear
        let leftBarButton = UIBarButtonItem.init(customView: leftButton)
        self.navigationItem.leftBarButtonItem = leftBarButton

        title = "CreateTask".localized()

        self.navigationController?.navigationBar.titleTextAttributes =
            [NSForegroundColorAttributeName: UIColor.white,
             NSFontAttributeName: UIFont(name: "Lato-Regular", size: 15)!]
    }
    
    func setUpWithPostModel(postModel: PostModel) {
        salaryTF.text = postModel.salaryWithoutPeriod
        startLB.text = postModel.start_date
        endLB.text = postModel.end_date

        if let startDateString = postModel.start_date {
            self.startDate = dateFormatter.date(from: startDateString)
        }
        if let endDateString = postModel.end_date {
            self.endDate = dateFormatter.date(from: endDateString)
        }
    }

    func datePickerChanged(datePicker:UIDatePicker){
        print(datePicker.date)
        let date = datePicker.date
        let dateString = dateFormatter.string(from: date) //pass Date here
        if typePicker == 2 {
            startDate = date
            startLB.text = dateString
        }
        else if (typePicker == 3) {
            endDate = date
            endLB.text = dateString
        }
    }
    
    
    //MARK: - Handle user action
    
    func displayNotification() {
        print("displayNotification")
        let notificationVC = MMYNotificationViewController(nibName: "MMYNotificationViewController", bundle: nil)
        self.navigationController?.pushViewController(notificationVC, animated: true)
    }


    @IBAction func handleBtnStartHourTouched(_ sender: Any) {
        typePicker = 5
//        self.overLapView.isHidden = false
//        pickerView.isHidden = false
//        pickerView.reloadAllComponents()
//
//        if let index = Int(lbStartHour.text ?? "0") {
//            pickerView.selectRow(index, inComponent: 0, animated: false)
//        }
//        else {
//            lbStartHour.text = "0"
//        }
        lbStartHour.text = "11:34"
        datePickerStart.isHidden = false
        datePickerEnd.isHidden = true
        self.createTimePickerStart()

        datePickerView.isHidden = true
        view.endEditing(true)
    }

    @IBAction func handleBtnEndHourTouched(_ sender: Any) {
        typePicker = 6
//        self.overLapView.isHidden = false
//        pickerView.isHidden = false
//        pickerView.reloadAllComponents()
//        if let index = Int(lbEndHour.text ?? "0") {
//            pickerView.selectRow(index, inComponent: 0, animated: false)
//        }
//        else {
//            lbEndHour.text = "0"
//        }
        lbEndHour.text = "11:34"
        datePickerEnd.isHidden = false
        datePickerStart.isHidden = true
        self.createTimePickerEnd()
        datePickerView.isHidden = true
        view.endEditing(true)
    }

    @IBAction func onBtnStart(_ sender: Any) {
        typePicker = 2
        self.overLapView.isHidden = false
        pickerView.isHidden = true
        datePickerView.isHidden = false
        if let startDate = startDate {
            datePickerView.setDate(startDate, animated: true)
        }
        else {
            self.startDate = Date()
            datePickerView.setDate(self.startDate!, animated: true)
        }
        view.endEditing(true)
    }
    
    @IBAction func onBtnEnd(_ sender: Any) {
        typePicker = 3
        self.overLapView.isHidden = false
        pickerView.isHidden = true
        datePickerView.isHidden = false
        if let endDate = endDate {
            datePickerView.setDate(endDate, animated: true)
        }
        else {
            self.endDate = Date()
            datePickerView.setDate(self.endDate!, animated: true)
        }
        view.endEditing(true)
    }
    
    func onBtnPickerDone() {
        self.overLapView.isHidden = true
        let date = datePickerView.date
        let dateString = dateFormatter.string(from: date) //pass Date here
        if typePicker == 2 {
            startDate = date
            startLB.text = dateString
        }
        else if (typePicker == 3) {
            endDate = date
            endLB.text = dateString
        }
    }
    @IBAction func onBtnDone(_ sender: Any) {

        if salaryTF.text?.count == 0 {
            showDialog(title: "Empty Field".localized(), message: "Salary".localized(), handler: nil)
        }
        else if lbStartHour.text == nil {
            showDialog(title: "Empty Field".localized(), message: "StartHour".localized(), handler: nil)
        }
        else if lbEndHour.text == nil {
            showDialog(title: "Empty Field".localized(), message: "EndHour".localized(), handler: nil)
        }
        else if startDate == nil {
            showDialog(title: "Empty Field".localized(), message: "Ngày bắt đầu", handler: nil)
        }
        else if endDate == nil {
            showDialog(title: "Empty Field".localized(), message: "Ngày kết thúc", handler: nil)
        }
        else {
            if let _ = task {
                editTask()
            }
            else {
                createTask()
            }
        }
    }
    
    func createTimePickerStart() {
       datePickerStart.frame = CGRect(x: 0.0 , y: self.view.frame.height - 100, width: self.view.bounds.size.width, height: 100.0)
        datePickerStart.backgroundColor = backGroundColor
        datePickerStart.datePickerMode = .time
        datePickerStart.addTarget(self, action: #selector(timePickerStart(sender:)), for: .valueChanged)
        self.view.addSubview(datePickerStart)
    }
    
    func timePickerStart(sender: UIDatePicker) {
        let time = sender.countDownDuration
        let hour = (time/3600).rounded(.down)
        let minute = (((time/3600) - hour)*60).rounded(.down)
        lbStartHour.text = "\( Int(hour)):\(Int(minute))"
    }
    
    func createTimePickerEnd() {
        datePickerEnd.frame = CGRect(x: 0.0 , y: self.view.frame.height - 100, width: self.view.bounds.size.width, height: 100.0)
        datePickerEnd.backgroundColor = backGroundColor
        datePickerEnd.datePickerMode = .time
        datePickerEnd.addTarget(self, action: #selector(timePickerEnd(sender:)), for: .valueChanged)
        self.view.addSubview(datePickerEnd)
    }
    
    func timePickerEnd(sender: UIDatePicker) {
        let time = sender.countDownDuration
        let hour = (time/3600).rounded(.down)
        let minute = (((time/3600) - hour)*60).rounded(.down)
        lbEndHour.text = "\(Int(hour)):\(Int(minute))"
    }
    
    func tapView() {
        datePickerStart.isHidden = true
        datePickerEnd.isHidden = true
    }

    func createTask() {
        let amount = salaryTF.text!

        var startHour = "7:00:00"
        if let str = lbStartHour.text {
            startHour = "\(str):00"
        }
        let startDate = startLB.text!
        var endHour = "18:00:00"
        if let str = lbEndHour.text {
            endHour = "\(str):00"
        }
        let endDate = endLB.text!

        activityIndicator?.startAnimating()
        ServiceManager.taskService.create(post_id: postID, amount: amount, startHour: startHour, startDate: startDate, endHour: endHour, endDate: endDate, note: descriptionTF.text) { (result) in
            switch result {
            case .failure(let error):
                self.showDialog(title: "", message: error.errorMessage, handler: nil)
            case .success(_):
                self.showDialog(title: "", message: "Successful".localized()) { (action) in
                    self.navigationController?.popViewController(animated: true)
                }
            }
            self.activityIndicator?.stopAnimating()
        }
    }
    
    func editTask() {

    }
    
    func cancelPost() {
        backToPreviousController()
    }
    
    func backToPreviousController () {
        _ = navigationController?.popViewController(animated: true)
    }

    func showDialog(title: String, message: String, buttonTitle: String = "OK", handler: ((_ alertAction: UIAlertAction) -> Void)?,  rightButtonTitle: String? = nil, rightHandler: ((_ alertAction: UIAlertAction) -> Void)? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: buttonTitle.localized(), style: UIAlertActionStyle.default,handler: handler))
        if let rightButtonTitle = rightButtonTitle {
            alertController.addAction(UIAlertAction(title: rightButtonTitle.localized(), style: UIAlertActionStyle.default,handler: rightHandler))
        }
        present(alertController, animated: true, completion: nil)
    }
}

extension TaskCreateViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        var numberOfRowsInComponent = 0
        if typePicker == 5 || typePicker == 6 {
            numberOfRowsInComponent = 24
        }
        return numberOfRowsInComponent
    }
}

extension TaskCreateViewController: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        var string = ""
        if typePicker == 5 || typePicker == 6 {
            string = "\(row)"
        }
        
        let attString = NSAttributedString(string: string, attributes: [NSForegroundColorAttributeName:UIColor.white])
        return attString
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if (typePicker == 5) {
            lbStartHour.text = "\(row)"
        }
        else if (typePicker == 6) {
            lbEndHour.text = "\(row)"
        }
    }
}

