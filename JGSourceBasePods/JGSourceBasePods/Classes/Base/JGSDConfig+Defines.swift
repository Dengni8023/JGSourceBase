//
//  JGSDConfig+Defines.swift
//  JGSourceBaseDemo
//
//  Created by Mei JiGao on 2026/6/17.
//  Copyright © 2026 ByMountains. All rights reserved.
//

import UIKit

let JGSDTitleTextAttributes: [NSAttributedString.Key: Any] = {
    let style = NSMutableParagraphStyle()
    style.lineBreakMode = .byTruncatingTail
    style.alignment = .center
    
    return [
        .font: UIFont.boldSystemFont(ofSize: UIFont.buttonFontSize),
        .foregroundColor: UIColor.white,
        .paragraphStyle: style,
    ]
}()

let JGSDSubTitleTextAttributes: [NSAttributedString.Key: Any] = {
    let style = NSMutableParagraphStyle()
    style.lineBreakMode = .byTruncatingTail
    style.alignment = .center
    
    return [
        .font: UIFont.systemFont(ofSize: UIFont.smallSystemFontSize),
        .foregroundColor: UIColor.white,
        .paragraphStyle: style,
    ]
}()

struct JGSDTableCellData {
    
    /// cell 展示标题
    let title: String
    
    /// cell 点击的 target-action 响应
    /// - target: 响应接收者
    /// - action: 接收者的具体响应方法，需要 @objc 标记；接受一个 IndexPath 参数，对应 cell 的 indexPath；返回 void
    let selector: (target: AnyObject, selector: Selector)?
    
    /// cell 点击的 block 响应，接受一个 IndexPath 参数，对应 cell 的 indexPath
    let action: ((_ indexPath: IndexPath) -> Void)?
    
    init(title: String, selector: (target: AnyObject, selector: Selector)? = nil, action: ((_: IndexPath) -> Void)? = nil) {
        self.title = title
        self.selector = selector
        self.action = action
    }
}
