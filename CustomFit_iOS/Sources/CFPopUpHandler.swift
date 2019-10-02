//
//  CFPopUpHandler.swift
//  CustomFit
//
//  Created by Bharath R on 28/08/19.
//  Copyright © 2019 Custom Fit. All rights reserved.
//

import UIKit

class CFPopUpHandler {
    
    private var application: UIApplication?
    
    init(app: UIApplication) {
        application = app
    }
    
    private func doInBackground(param: String?) {
        let alert = UIAlertController(title: param ?? "M", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        application?.topViewController()?.present(alert, animated: true, completion: nil)
    }

    private func onPostExecute(param: String?) {
        //Print Toast or open dialog
    }
}
