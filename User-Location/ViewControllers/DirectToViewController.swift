//
//  DirectToViewController.swift
//  Glider Tool
//
//  Created by sonic on 21.05.19.
//  Copyright © 2019 Denis Leupold. All rights reserved.
//

import UIKit

class DirectToViewController: UIViewController {

    private let dataSource = ["APJK",
                              "BHWR",
                              "BPDP",
                              "BZFD",
                              "CDUR",
                              "CJCW",
                              "CUNA",
                              "CWYD",
                              "DKPN",
                              "DNQQ",
                              "DPBL",
                              "DVKL",
                              "EQDG",
                              "ETPF",
                              "FBNY",
                              "FELG",
                              "FMAP",
                              "FVEU",
                              "FZUR",
                              "GHHK",
                              "GHVU",
                              "GMSZ",
                              "GVKN",
                              "HBMN",
                              "HQEB",
                              "JBJY",
                              "JDBE",
                              "JDSE",
                              "JHEX",
                              "JSCA",
                              "JTCA",
                              "KHJF",
                              "KHKP",
                              "KRKJ",
                              "KTYT",
                              "KUPW",
                              "LNGG",
                              "MCWE",
                              "MDCS",
                              "MNAS",
                              "MNEP",
                              "MUTD",
                              "MZMC",
                              "NECG",
                              "NKFX",
                              "NKKP",
                              "NPRZ",
                              "NUWE",
                              "PFEN",
                              "PSUX",
                              "PSWA",
                              "PTNC",
                              "PVJJ",
                              "QDAU",
                              "QKGC",
                              "QMVL",
                              "QSQX",
                              "RFRE",
                              "RHEY",
                              "RKJQ",
                              "RMHR",
                              "RMJX",
                              "RQNR",
                              "RXQU",
                              "SBDA",
                              "SBVJ",
                              "SKZZ",
                              "SVPH",
                              "SXWT",
                              "TDQS",
                              "TDTY",
                              "TGRF",
                              "TVSL",
                              "TYWB",
                              "UFZA",
                              "UHVY",
                              "UMLZ",
                              "UQMU",
                              "UUGL",
                              "UXZN",
                              "UZJY",
                              "VARF",
                              "VCDW",
                              "VJZN",
                              "VUSE",
                              "WDJZ",
                              "WSKR",
                              "XAZX",
                              "XNQB",
                              "XPJM",
                              "XRHS",
                              "XRSZ",
                              "YDNZ",
                              "YPSC",
                              "YWVM",
                              "ZFJP",
                              "ZGMF",
                              "ZMRU",
                              "ZTRS",
                              "ZZJG"]
    

    
    
    
    @IBOutlet weak var detailLabel: UILabel!

    
    @IBOutlet weak var pickerView: UIPickerView!
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pickerView.dataSource = self
        pickerView.delegate = self
        // Do any additional setup after loading the view, typically from a nib.
    }
}

extension DirectToViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dataSource.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        detailLabel.text = dataSource[row]
        print(detailLabel.text!)
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return dataSource[row]
    }
}
