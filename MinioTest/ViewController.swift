//
//  ViewController.swift
//  MinioTest
//
//  Created by Tony Li on 6/4/17.
//  Copyright © 2017 Tony Li. All rights reserved.
//

import UIKit
import AWSS3
import AWSCore

class ViewController: UIViewController {
    
    @IBOutlet weak var uploadButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBAction func uploadButtonAction(_ sender: Any) {
        uploadButton.isHidden = true
        activityIndicator.startAnimating()
        
        let accessKey = "XXXXXXX"
        let secretKey = "XXXXXXX"
        
        let credentialsProvider = AWSStaticCredentialsProvider(accessKey: accessKey, secretKey: secretKey)
        let configuration = AWSServiceConfiguration(region: .USEast1, endpoint: AWSEndpoint(region: .USEast1, service: .S3, url: URL(string:"XXXXXX")),credentialsProvider: credentialsProvider)
        
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        
        let S3BucketName = "images"
        let remoteName = "test.jpg"
        let fileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(remoteName)
        let image = UIImage(named: "test")
        let data = UIImageJPEGRepresentation(image!, 0.9)
        do {
            try data?.write(to: fileURL)
        }
        catch {}
        
        let uploadRequest = AWSS3TransferManagerUploadRequest()!
        uploadRequest.body = fileURL
        uploadRequest.key = remoteName
        uploadRequest.bucket = S3BucketName
        uploadRequest.contentType = "image/jpeg"
        uploadRequest.acl = .publicRead
        
        let transferManager = AWSS3TransferManager.default()
        
        transferManager.upload(uploadRequest).continueWith { (task: AWSTask<AnyObject>) -> Any? in
            print(task)
            
            DispatchQueue.main.async {
                self.uploadButton.isHidden = false
                self.activityIndicator.stopAnimating()
            }
            
            if let error = task.error {
                print("Upload failed with error: (\(error.localizedDescription))")
            }
            
            if task.result != nil {
                let url = AWSS3.default().configuration.endpoint.url
                let publicURL = url?.appendingPathComponent(uploadRequest.bucket!).appendingPathComponent(uploadRequest.key!)
                print("Uploaded to:\(String(describing: publicURL))")
            }
            
            return nil
        }
    }
    
}
