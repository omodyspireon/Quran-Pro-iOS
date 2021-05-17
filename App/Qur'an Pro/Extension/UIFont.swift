//
//  UIFont.swift
//  Qur'an Pro
//
//  Created by Adil Ben Moussa on 10/27/15.
//  Copyright © 2015 https://github.com/adilbenmoussa All rights reserved.
//  GNU GENERAL PUBLIC LICENSE https://raw.githubusercontent.com/adilbenmoussa/Quran-Pro-iOS/master/LICENSE
//

import Foundation

extension UIFont {
    
    //get the arabic font
    @objc class func latin() ->UIFont {
        if dollar.fontLevel == FontSizeType.large {
            return kLatinFontLarge
        }
        else if dollar.fontLevel == FontSizeType.extraLarge {
            return kLatinFontLarge
        }
        else{
            return kLatinFont
        }
    }
    
    @objc class func arabicFont() -> UIFont {
        if dollar.fontLevel == FontSizeType.large {
            if dollar.arabicFont == ArabicFontType.useMEQuranicFont {
                return kMEQuranicArabicFontLarge
            }
            else if dollar.arabicFont == ArabicFontType.usePDMSQuranicFont {
                return kPDMSQuranicArabicFontLarge
            }
            else{
                return kArabicFontLarge
            }
        }
        else if dollar.fontLevel == FontSizeType.extraLarge {
            if dollar.arabicFont == ArabicFontType.useMEQuranicFont {
                return kMEQuranicArabicFontExtraLarge
            }
            else if dollar.arabicFont == ArabicFontType.usePDMSQuranicFont {
                return kPDMSQuranicArabicFontExtraLarge
            }
            else{
                return kArabicFontExtraLarge
            }
        }
        else{
            if dollar.arabicFont == ArabicFontType.useMEQuranicFont {
                return kMEQuranicArabicFont
            }
            else if dollar.arabicFont == ArabicFontType.usePDMSQuranicFont {
                return kPDMSQuranicArabicFont
            }
            else{
                return kArabicFont
            }
        }
    }
}
