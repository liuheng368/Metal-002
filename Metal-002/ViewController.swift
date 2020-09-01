//
//  ViewController.swift
//  Metal-002
//
//  Created by Henry on 2020/9/1.
//  Copyright © 2020 刘恒. All rights reserved.
//

import UIKit
import MetalKit

class ViewController: UIViewController {

    
    private var _view:MTKView!
    private var _render:HrRender?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //1.获取MTKView
        if let vv = self.view as? MTKView{
            _view = vv
            //2.创建设备（GPU）
            _view?.device = MTLCreateSystemDefaultDevice()
            
            //3.render工具类创建
            _render = HrRender(view: _view)
            
            //4.mtkview的代理设置
            _view?.delegate = _render
            
            //5.初始化视图大小
            //drawableSize当前view的可视区域
            _render?.mtkView(vv, drawableSizeWillChange: _view.drawableSize)
        }
    }


}

