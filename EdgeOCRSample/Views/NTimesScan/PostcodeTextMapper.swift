//
//  PostcodeTextMapper.swift
//  EdgeOCRSample
//
//  Created by kikemori on 2024/04/16.
//
//
import EdgeOCRSwift
import Foundation

class PostcodeTextMapper: TextMapper {
    // 郵便番号に一致する正規表現を作成する
    let regex = /^\D*(\d{3})-(\d{4})\D*$/

    override func map(_ text: Text) -> String {
        var t = text.getText()
        t = t.replacingOccurrences(of: "A", with: "4")
        t = t.replacingOccurrences(of: "B", with: "8")
        t = t.replacingOccurrences(of: "b", with: "6")
        t = t.replacingOccurrences(of: "C", with: "0")
        t = t.replacingOccurrences(of: "D", with: "0")
        t = t.replacingOccurrences(of: "G", with: "6")
        t = t.replacingOccurrences(of: "g", with: "9")
        t = t.replacingOccurrences(of: "I", with: "1")
        t = t.replacingOccurrences(of: "i", with: "1")
        t = t.replacingOccurrences(of: "l", with: "1")
        t = t.replacingOccurrences(of: "O", with: "0")
        t = t.replacingOccurrences(of: "o", with: "0")
        t = t.replacingOccurrences(of: "Q", with: "0")
        t = t.replacingOccurrences(of: "q", with: "9")
        t = t.replacingOccurrences(of: "S", with: "5")
        t = t.replacingOccurrences(of: "s", with: "5")
        t = t.replacingOccurrences(of: "U", with: "0")
        t = t.replacingOccurrences(of: "Z", with: "2")
        t = t.replacingOccurrences(of: "z", with: "2")
        t = t.replacingOccurrences(of: "/", with: "1")

        if let match = t.wholeMatch(of: regex) {
            t = String(match.1) + "-" + String(match.2)
        }
        return t
    }
}
