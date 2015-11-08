

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
        ColorInfo(name: "white", color: AppUtility.colorWithHexString("ffffff")),
        ColorInfo(name: "black", color: AppUtility.colorWithHexString("000000")),
        ColorInfo(name: "dodger blue", color: AppUtility.colorWithHexString("1E90FF")),
        ColorInfo(name: "coral orange", color: AppUtility.colorWithHexString("ff7f50")),
        ColorInfo(name: "deep pink", color: AppUtility.colorWithHexString("FF1493")),
        ColorInfo(name: "salmon pink", color: AppUtility.colorWithHexString("FA8072")),
        ColorInfo(name: "medium seagreen", color: AppUtility.colorWithHexString("3CB371")),
        ColorInfo(name: "crimson red", color: AppUtility.colorWithHexString("DC143C")),
        ColorInfo(name: "navy", color: AppUtility.colorWithHexString("000080")),
        ColorInfo(name: "dark gray", color: AppUtility.colorWithHexString("a9a9a9")),
        ColorInfo(name: "gold", color: AppUtility.colorWithHexString("ffd700"))
    ]
    var tempColor: UIColor!
    
    // MARK:lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addText.delegate = self
        
        labelColorPicker.delegate = self
        labelColorPicker.dataSource = self
        self.view.addSubview(labelColorPicker)
        
        labelColorPicker.hidden = true
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
    
    
    @IBAction func tapAddTextBtn(sender: AnyObject) {
        println(__FUNCTION__)
        
        //ラベルが画面上にすでに載せられている場合
        if (self.stampLabel != nil) {
            setText.setTitle("paste", forState: UIControlState.Normal)
            let tempImage = self.drawText(mainImage.image!, addText: addText.text)
            mainImage.image = tempImage
            self.stampLabel.removeFromSuperview()
            self.stampLabel = nil
            //何度もラベルを画像に貼れるように画像にラベルをセットし終わったらtextFieldを空にする
            addText.text = nil
            labelColorPicker.hidden = true
            
        } else {
            self.stampLabel = UILabel(frame: CGRectMake(50, 50, 120, 20));
            self.stampLabel.text = addText.text
            self.stampLabel.textColor = UIColor.whiteColor()
            self.stampLabel.backgroundColor = UIColor.clearColor()
            self.mainImage.addSubview(stampLabel)
            setText.setTitle("set", forState: UIControlState.Normal)
            
            labelColorPicker.hidden = false
        }
    }
    
    //保存ボタンをタップするとライブラリに保存し、確認アラートを表示する
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
        addText.drawInRect(textRect, withAttributes: textFontAttributes)
        //コンテキストをイメージとして生成する
        self.newImage = UIGraphicsGetImageFromCurrentImageContext();
        //イメージ生成かんりょう
        UIGraphicsEndImageContext()
        
        return self.newImage
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

