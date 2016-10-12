//
//  motoRoutesOptions.swift
//  motoRoutes
//
//  Created by Peter Pohlmann on 10.05.16.
//  Copyright © 2016 Peter Pohlmann. All rights reserved.
//

import UIKit



class motoRouteOptions: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    
    //Picker 1 Data Stuff
    let pickerData = [
        ["1","2","3","4","5","8","10","25","50","80","100","150","250","500","750","1000","1250","1500","1800","2000","2500","3000","3500","4000","4500"],
        ["0.0001",  "0.0003",  "0.0005", "0.0007",  "0.0009", "0.001","0.003",  "0.005",  "0.007", "0.009", "0.01",  "0.03", "0.05", "0.07", "0.1", "0.3", "0.5", "0.7", "0.9","1.0","1.1","1.2","1.3","1.5","2","3","4","5"],
        ["1","2","3","4","5","8","10","25","50","80"]
    ]
    
    //vars to set from root controller
    var sliceAmount = 1
    var timeIntervalMarker = 0.001
    
    //picker outlet
    @IBOutlet var amountPicker: UIPickerView!
    
    
    //
    // override func super init
    //
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.amountPicker.dataSource = self;
        self.amountPicker.delegate = self;
    }
    
    //picker funcs
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return pickerData.count
    }
    
    //picker funcs
    func pickerView(
        _ pickerView: UIPickerView,
        numberOfRowsInComponent component: Int
        ) -> Int {
        return pickerData[component].count
    }
    
    //picker funcs
    func pickerView(
        _ pickerView: UIPickerView,
        titleForRow row: Int,
                    forComponent component: Int
        ) -> String? {
        return pickerData[component][row]
    }
    
    //picker funcs
    func pickerView( _ pickerView: UIPickerView,  didSelectRow row: Int, inComponent component: Int) {
        
            if let sliceAmountPicker = Int(pickerData[0][amountPicker.selectedRow(inComponent: 0)]) {
                sliceAmount = Int(sliceAmountPicker)
            }
        
            if let timeIntervalPicker = Double(pickerData[1][amountPicker.selectedRow(inComponent: 1)]) {
                timeIntervalMarker = timeIntervalPicker
            }
            
            if let arrayStepPicker = Double(pickerData[2][amountPicker.selectedRow(inComponent: 2)]){
                globalArrayStep.gArrayStep = Int(arrayStepPicker)
            }
    }
    
    
}
