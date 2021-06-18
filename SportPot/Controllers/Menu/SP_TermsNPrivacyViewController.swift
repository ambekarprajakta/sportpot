//
//  SP_TermsNPrivacyViewController.swift
//  SportPot
//
//  Created by Prajakta Ambekar on 08/06/2021.
//  Copyright © 2021 Prajakta Ambekar. All rights reserved.
//

import UIKit

class SP_TermsNPrivacyViewController: UIViewController {
    
    @IBOutlet private weak var textView: UITextView!
    @IBOutlet private weak var titleLabel: UILabel!
    var vcType = ""
    private let privacyText = "Your privacy is important to us. It is Sportpot's policy to respect your privacy regarding any information we may collect from you across our website, www.sportpot.eu, and or app, sportpot, and other sites we own and operate. We only ask for personal information when we truly need it to provide a service to you. We collect it by fair and lawful means, with your knowledge and consent. We also let you know why we’re collecting it and how it will be used. We only retain collected information for as long as necessary to provide you with your requested service. What data we store, we’ll protect within commercially acceptable means to prevent loss and theft, as well as unauthorized access, disclosure, copying, use or modification. We don’t share any personally identifying information publicly or with third-parties, except when required to by law. Our website may link to external sites that are not operated by us. Please be aware that we have no control over the content and practices of these sites, and cannot accept responsibility or liability for their respective privacy policies. You are free to refuse our request for your personal information, with the understanding that we may be unable to provide you with some of your desired services. Your continued use of our website and app will be regarded as acceptance of our practices around privacy and personal information. If you have any questions about how we handle user data and personal information, feel free to contact us. This policy is effective as of 26 August 2020."
    
    private let tncText = "1. Terms By accessing the website at www.sportpot.eu, and app ,sportpot, you are agreeing to be bound by these terms of service, all applicable laws and regulations, and agree that you are responsible for compliance with any applicable local laws. If you do not agree with any of these terms, you are prohibited from using or accessing the website and/or app. The materials contained in this website and or app are protected by applicable copyright and trademark law.\n\n2. Use License Permission is granted to temporarily download one copy of the materials (information or software) on Sportpot's website for personal, non-commercial transitory viewing only. This is the grant of a license, not a transfer of title, and under this license you may not: modify or copy the materials; use the materials for any commercial purpose, or for any public display (commercial or non-commercial); attempt to decompile or reverse engineer any software contained on Sportpot's website; remove any copyright or other proprietary notations from the materials; or transfer the materials to another person or \"mirror\" the materials on any other server. This license shall automatically terminate if you violate any of these restrictions and may be terminated by Sportpot at any time. Upon terminating your viewing of these materials or upon the termination of this license, you must destroy any downloaded materials in your possession whether in electronic or printed format.\n\n3. Disclaimer The materials on Sportpot's website and /or app are provided on an 'as is' basis. Sportpot makes no warranties, expressed or implied, and hereby disclaims and negates all other warranties including, without limitation, implied warranties or conditions of merchantability, fitness for a particular purpose, or non-infringement of intellectual property or other violation of rights. Further, Sportpot does not warrant or make any representations concerning the accuracy, likely results, or reliability of the use of the materials on its website or otherwise relating to such materials or on any sites linked to this site.\n\n4. Limitations In no event shall Sportpot or its suppliers be liable for any damages (including, without limitation, damages for loss of data or profit, or due to business interruption) arising out of the use or inability to use the materials on Sportpot's website and/or app, even if Sportpot or a Sportpot authorized representative has been notified orally or in writing of the possibility of such damage. Because some jurisdictions do not allow limitations on implied warranties, or limitations of liability for consequential or incidental damages, these limitations may not apply to you.\n\n5. Accuracy of materials The materials appearing on Sportpot's website and/or app could include technical, typographical, or photographic errors. Sportpot does not warrant that any of the materials on its website and/or app are accurate, complete or current. Sportpot may make changes to the materials contained on its website and/or app at any time without notice. However Sportpot does not make any commitment to update the materials.\n\n6. Links Sportpot has not reviewed all of the sites linked to its website and is not responsible for the contents of any such linked site. The inclusion of any link does not imply endorsement by Sportpot of the site. Use of any such linked website is at the user's own risk.\n\n7. Modifications Sportpot may revise these terms of service for its website and/or app at any time without notice. By using this website and/or app you are agreeing to be bound by the then current version of these terms of service.\n\n8. Governing Law These terms and conditions are governed by and construed in accordance with the laws of European Union and you irrevocably submit to the exclusive jurisdiction of the courts in that State or location."
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initalizeView()
    }
    
    func initalizeView() {
        
        if vcType == "tnc" {
            titleLabel.text = "Terms and Conditions"
            textView.text = tncText
        } else {
            
        }
    }
    
    @IBAction func dismissAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
