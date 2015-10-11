

import UIKit

class ViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    // MARK:lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = true
    }
    
    // MARK:IBAction
    @IBAction func tapLibraryButton(sender: AnyObject) {
        println(__FUNCTION__)
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
            let controller = UIImagePickerController()
            controller.delegate = self
            //ライブラリから選択後、正方形にトリミングする
            controller.allowsEditing = true
            controller.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            self.presentViewController(controller, animated: true, completion: nil)
        }
    }
    
    @IBAction func tapCameraButton(sender: AnyObject) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            let controller = UIImagePickerController()
            controller.delegate = self
            //カメラで写真を撮った後、正方形にトリミングする
            controller.allowsEditing = true
            controller.sourceType = UIImagePickerControllerSourceType.Camera
            self.presentViewController(controller, animated: true, completion: nil)
        }
    }
    
    // 写真を選択した時に呼ばれる
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        
        // 遷移するViewを定義する.
        let drawViewController:DrawViewController = DrawViewController(nibName: "DrawViewController", bundle: NSBundle.mainBundle())
        //選択時トリミングした画像を使用する
        if info[UIImagePickerControllerEditedImage] != nil {
            let image = info[UIImagePickerControllerEditedImage] as! UIImage
            drawViewController.tempImage = image
            println(image)
        }
        picker.dismissViewControllerAnimated(true, completion: nil)
        
        self.navigationController?.pushViewController(drawViewController, animated: true)

    }
}


