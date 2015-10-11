

import UIKit

struct ColorInfo {
    var name: String?
    var color: UIColor?
}

class DrawViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIPickerViewDelegate,UIPickerViewDataSource {
    
    @IBOutlet weak var mainImage: UIImageView!
    
    var tempImage: UIImage!
    
    @IBOutlet weak var setText: UIButton!
    @IBOutlet weak var newImage: UIImage!
    
    @IBOutlet weak var addText: UITextField!
    
    var stampLabel: UILabel!
    var inputText: String!
    var saveButton: UIBarButtonItem!
    
    @IBOutlet weak var labelColorPicker: UIPickerView!
    var pickColorArr: [ColorInfo] = [
        ColorInfo(name: "white", color: UIColor.whiteColor()),
        ColorInfo(name: "black", color: UIColor.blackColor()),
        ColorInfo(name: "blue", color: UIColor.blueColor()),
        ColorInfo(name: "orange", color: UIColor.redColor()),
        ColorInfo(name: "pink", color: UIColor.blueColor()),
        ColorInfo(name: "green", color: UIColor.greenColor()),
        ColorInfo(name: "red", color: UIColor.redColor()),
        ColorInfo(name: "navy", color: UIColor.blueColor()),
        ColorInfo(name: "gray", color: UIColor.grayColor()),
        ColorInfo(name: "yellow", color: UIColor.yellowColor())
    ]
    var tempColor: UIColor!
    
    // MARK:lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addText.delegate = self
        
        labelColorPicker.delegate = self
        labelColorPicker.dataSource = self
        self.view.addSubview(labelColorPicker)
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = false
    }

    override func viewDidAppear(animated: Bool) {
        // ライブラリで選択した画像をimageViewのimageにセット
        mainImage.image = tempImage
        
        saveButton = UIBarButtonItem(title: "save", style: .Plain, target: self, action: "tappedSaveButton:")
        self.navigationItem.rightBarButtonItem = saveButton
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK:IBAction
    
    @IBAction func tapLibBtn(sender: AnyObject) {
        println(__FUNCTION__)
        self.pickImageFromLibrary()
    }
    
    @IBAction func tapAddTextBtn(sender: AnyObject) {
        println(__FUNCTION__)
        
        //ラベルが画面上にすでに載せられている場合
        if (self.stampLabel != nil) {
            setText.setTitle("のせる", forState: UIControlState.Normal)
            let tempImage = self.drawText(mainImage.image!, addText: addText.text)
            mainImage.image = tempImage
            self.stampLabel.removeFromSuperview()
            self.stampLabel = nil
            //何度もラベルを画像に貼れるように画像にラベルをセットし終わったらtextFieldを空にする
            addText.text = nil
            
        } else {
            self.stampLabel = UILabel(frame: CGRectMake(50, 50, 120, 20));
            self.stampLabel.text = addText.text
            self.stampLabel.textColor = UIColor.whiteColor()
            self.stampLabel.backgroundColor = UIColor.clearColor()
            self.mainImage.addSubview(stampLabel)
            setText.setTitle("画像にラベル保存", forState: UIControlState.Normal)
        }
    }
    
    //保存ボタンを押す
    func tappedSaveButton(sender: UIButton) {
        println(__FUNCTION__)
        UIImageWriteToSavedPhotosAlbum(mainImage.image, nil, nil, nil)
        
        let saveAlert = UIAlertController(title: nil, message: "画像を保存しました", preferredStyle: .Alert)
        self.presentViewController(saveAlert, animated: true, completion: { () -> Void in
            let delay = 3.0 * Double(NSEC_PER_SEC)
            let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
            //別スレッドで3秒間遅延させている間アラートを表示する。3秒後にアラートを閉じる
            dispatch_after(time, dispatch_get_main_queue(),{
                self.dismissViewControllerAnimated(true, completion: nil)
                //保存が終わったらメインスレッドで作成したimageViewを消す
                NSOperationQueue.mainQueue().addOperationWithBlock({
                    self.navigationController?.popViewControllerAnimated(true)
                    
                })
            })
        })
    }
    
    // ライブラリから写真を選択する
    func pickImageFromLibrary() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
            let controller = UIImagePickerController()
            controller.delegate = self
            //ライブラリから選択後、正方形にトリミングする
            controller.allowsEditing = true
            controller.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            self.presentViewController(controller, animated: true, completion: nil)
        }
    }
    
    // 写真を選択した時に呼ばれる
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        //選択時トリミングした画像を使用する
        if info[UIImagePickerControllerEditedImage] != nil {
            let image = info[UIImagePickerControllerEditedImage] as! UIImage
            mainImage.image = image
            println(image)
        }
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //表示列
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    //表示するpickerViewの列数
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickColorArr.count
    }
    
    //表示内容
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String {
        return pickColorArr[row].name!
    }
    
    //ピッカー選択時
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if(self.stampLabel != nil){
            self.stampLabel.textColor = pickColorArr[row].color
            tempColor = self.stampLabel.textColor
        }
    }
    
}

extension DrawViewController {
    func drawText(image:UIImage, addText:String) -> UIImage{
        self.inputText = addText
        let font = UIFont.boldSystemFontOfSize(50)
        
        let imageRect = CGRectMake(0,0,image.size.width,image.size.height)
        //空のコンテキスト（保存するための画像）を選択した画像と同じサイズで設定
        UIGraphicsBeginImageContext(image.size);
        //そこに描画することを設定
        image.drawInRect(imageRect)
        
        //ラベルの描画領域を設定する
        let textRect  = CGRectMake((self.stampLabel.frame.origin.x * image.size.width) / mainImage.frame.width, (self.stampLabel.frame.origin.y * image.size.height) / mainImage.frame.height, image.size.width - 5, image.size.height - 5)
        
        //プロパティつくる
        let textDrawView = UIImageView()
        
        let textStyle = NSMutableParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle
        let textFontAttributes = [
            NSFontAttributeName: font,
            NSForegroundColorAttributeName: tempColor,
            NSParagraphStyleAttributeName: textStyle
        ]
        //varの中には何度も入れなおせるが、letには一度きりしか値を入れられない
        addText.drawInRect(textRect, withAttributes: textFontAttributes)
        //コンテキストをイメージとして生成する
        self.newImage = UIGraphicsGetImageFromCurrentImageContext();
        //イメージ生成かんりょう
        UIGraphicsEndImageContext()
        
        return self.newImage
    }
    
    //TODO: 修正中
    //ピッカーの選択したカラーネームに合わせて色を選択する
    func getDrawColor(colorName: String) -> UIColor{
        let textColor: UIColor!
        if(colorName == "white"){
            textColor = UIColor.whiteColor()
        }else if(colorName == "black"){
            textColor = UIColor.blackColor()
        }else if(colorName == "blue"){
            textColor = UIColor(red: 65, green: 105, blue: 225, alpha: 1.0)
        }else{
            textColor = UIColor.blueColor()
        }
        return textColor
    }
    
    //ドラッグしたときによばれる
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        super.touchesMoved(touches, withEvent: event)
        
        for touch: AnyObject in touches{
            
            let touchLocation = touch.locationInView(view)
            
            self.stampLabel.transform = CGAffineTransformMakeTranslation(touchLocation.x - self.stampLabel.center.x, touchLocation.y - self.stampLabel.center.y)
            
        }
    }
}


extension DrawViewController:UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}

