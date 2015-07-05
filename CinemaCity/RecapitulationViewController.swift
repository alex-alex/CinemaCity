//
//  RecapitulationViewController.swift
//  CinemaCity
//
//  Created by Alex Studnicka on 20/06/14.
//  Copyright (c) 2014 Alex Studnicka. All rights reserved.
//

import UIKit

class RecapitulationViewController: UIViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.view.backgroundColor = UIColor.blackColor()
		
		self.navigationItem.title = NSLocalizedString("RECAPITULATION", comment: "")
		self.navigationItem.backBarButtonItem = UIBarButtonItem(title: NSLocalizedString("BACK", comment: ""), style: .Bordered, target: nil, action: nil)
		
		let bgLogoImageView = UIImageView()
		bgLogoImageView.frame = CGRect(x: 0, y: 138+56, width: 320, height: 180)
		bgLogoImageView.image = UIImage(named: "bg_logo.png")
		bgLogoImageView.contentMode = .Center
		self.view.addSubview(bgLogoImageView)
		self.view.sendSubviewToBack(bgLogoImageView)
		
	}
	
	@IBAction func continueAction() {
	
	}

}
