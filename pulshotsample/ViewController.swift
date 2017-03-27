//
//  ViewController.swift
//  pulshotsample
//
//  Created by oshitahayato on 2017/03/27.
//  Copyright © 2017年 oshitahayato. All rights reserved.
//

import UIKit
import HealthKit


class ViewController: UIViewController, UITextFieldDelegate {

	//各インスタンスの生成
	var myHealthStore: HKHealthStore = HKHealthStore()
	
	var myReadHeartRateField: UITextField!
	var myWriteHeartRateField: UITextField!
	
	var myReadButton: UIButton!
	var myWriteButton: UIButton!
	
	

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		
		
		//入力フィールド設置
		myWriteHeartRateField = UITextField(frame: CGRect(x: 0, y:0, width:300, height:30))
		myWriteHeartRateField.placeholder = "心拍数を入力してください"
		myWriteHeartRateField.delegate = self
		myWriteHeartRateField.borderStyle = UITextBorderStyle.roundedRect
		myWriteHeartRateField.layer.position = CGPoint(x:self.view.bounds.width/2,y:200)
		self.view.addSubview(myWriteHeartRateField)
		
		//書き込みボタン設置
		myWriteButton = UIButton()
		myWriteButton.frame = CGRect(x: 0, y: 0, width: 300, height:40)
		myWriteButton.backgroundColor = UIColor.blue
		myWriteButton.layer.masksToBounds = true
		myWriteButton.setTitle("心拍書き込み", for: UIControlState.normal)
		myWriteButton.setTitleColor(UIColor.white, for: UIControlState.normal)
		myWriteButton.setTitleColor(UIColor.black, for: UIControlState.highlighted)
		myWriteButton.layer.cornerRadius = 20.0
		myWriteButton.layer.position = CGPoint(x:self.view.frame.width/2, y:250)
		myWriteButton.tag = 2
		myWriteButton.addTarget(self, action: #selector(ViewController.onClickMyButton(sender:)), for: .touchUpInside)
		self.view.addSubview(myWriteButton)
		
		
		//読み込み表示フィールド設置
		myReadHeartRateField = UITextField(frame: CGRect(x: 0, y: 0, width: 300, height: 40))
		myReadHeartRateField.placeholder = "前回登録の心拍数"
		myReadHeartRateField.isEnabled = false
		myReadHeartRateField.delegate = self
		myReadHeartRateField.borderStyle = UITextBorderStyle.roundedRect
		myReadHeartRateField.layer.position = CGPoint(x:self.view.bounds.width/2,y:350)
		myReadHeartRateField.isEnabled = false
		self.view.addSubview(myReadHeartRateField)
		
		//読み込みボタン設置
		myReadButton = UIButton()
		myReadButton.frame = CGRect(x:0,y:0,width:300,height:40)
		myReadButton.backgroundColor = UIColor.red
		myReadButton.layer.masksToBounds = true
		myReadButton.setTitle("心拍読み込み", for: UIControlState.normal)
		myReadButton.setTitleColor(UIColor.white, for: UIControlState.normal)
		myReadButton.setTitleColor(UIColor.black, for: UIControlState.highlighted)
		myReadButton.layer.cornerRadius = 20.0
		myReadButton.layer.position = CGPoint(x:self.view.frame.width/2, y:400)
		myReadButton.tag = 1
		myReadButton.addTarget(self, action: #selector(ViewController.onClickMyButton(sender:)), for: .touchUpInside)
		self.view.addSubview(myReadButton)
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		//Healthstoreから許可申請
		requestAuthorization()
	}
	
	
	//ボタンイベント
	func onClickMyButton(sender: UIButton){
		if(sender.tag == 1){
			readData()
		}else if(sender.tag == 2){
			
			if let val = Double(myWriteHeartRateField.text!){
				writeData(HeartRate: val)
			}
		}
	}
	
	
	//heakthデータへのアクセス申請関数
	private func requestAuthorization(){
	
		//読み込みを許可する型
		let type = Set(arrayLiteral: HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!)
		
		//Healthstoreアクセス承認を行う
		myHealthStore.requestAuthorization(toShare: type, read: type, completion: {(sucess,error)in
			if let e = error{
				print("Error:\(e.localizedDescription)")
			}
			print(sucess ? "Sucess" : "Failture")
		})
	}
	
	
	//データ読み出し関数
	private func readData(){
		var error: NSError!
		
		//取得したいデータのタイプを生成
		let typeOfHeartRate = HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)
		
		let calender = Calendar.init(identifier:Calendar.Identifier.gregorian)
		let now = Date()
		
		let startDate = calender.startOfDay(for: now)
		let endDate = calender.date(byAdding: Calendar.Component.day, value: 5, to: startDate)
		
		let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options:[])
		
		//データ取得時に登録された時間でそーとするためのdescription生成
		let mySortDescription = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
		//query生成
		let myquery = HKSampleQuery(sampleType: typeOfHeartRate!, predicate: predicate, limit: 1, sortDescriptors: [mySortDescription])
		{ (sampleQuery, results, error) -> Void in
		
		
			//一番最近に登録されたデータ取得
			guard let myRecentSample = results!.first as? HKQuantitySample else{
				print("error")
				self.myReadHeartRateField.text = "Data is not found"
				return
			}
			
			//取得したサンプルを単位に合わせる
			DispatchQueue.main.async {
				self.myReadHeartRateField.text = "\(myRecentSample.quantity)"

			}
		}
		
		//query発行
		self.myHealthStore.execute(myquery)
	}
	
	
	//データ書き込み関数
	private func writeData(HeartRate:Double){
		
	}
	

}

