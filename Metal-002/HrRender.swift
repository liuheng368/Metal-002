//
//  HrRender.swift
//  Metal-002
//
//  Created by Henry on 2020/9/1.
//  Copyright © 2020 刘恒. All rights reserved.
//

import UIKit
import MetalKit
class HrRender: NSObject,MTKViewDelegate {
    
    private var _device : MTLDevice?
    private var commandQueue : MTLCommandQueue?
    private var pielineState : MTLRenderPipelineState!
    private var viewPortSize : vector_uint2 = vector_uint2(x: 0, y: 0)
    
    private var vertexBuffer : MTLBuffer?
    
    // 顶点数据/颜色数据
    let triangleVertices = [
        HRVertex(position: vector_float4(x: 0.5, y: -0.25, z: 0, w: 1.0),
                 color: vector_float4(x: 1, y: 0, z: 0, w: 1.0)),
        HRVertex(position: vector_float4(x: -0.5, y: -0.25, z: 0, w: 1.0),
                 color: vector_float4(x: 0, y: 1, z: 0, w: 1.0)),
        HRVertex(position: vector_float4(x: 0, y: 0.25, z: 0, w: 1.0),
                 color: vector_float4(x: 0, y: 0, z: 1, w: 1.0))
    ]
    
    init(view: MTKView) {
        super.init()
        _device = view.device
        
        //1. 通过device创建commandQueue
        commandQueue = _device?.makeCommandQueue()
        
        //2. 加载metal文件
        //2.1 makeDefaultLibrary:加载项目中所有.metal文件，当然也可以使用其他API来指定metal文件
        let library = _device?.makeDefaultLibrary()
        //2.2 从库中加载顶点函数、片元函数
        let vertexShader = library?.makeFunction(name: "vertexShader")
        let fragShader = library?.makeFunction(name: "fragmentShader")
        
        //3. 创建渲染管道描述符
        //3.1
        let pielineDes = MTLRenderPipelineDescriptor()
        //3.2 管道名称：可用于调试
        pielineDes.label = "MyMTLRenderPipelineDescriptor"
        //3.2 可编程函数，用于处理渲染过程中每个顶点、片元
        pielineDes.vertexFunction = vertexShader
        pielineDes.fragmentFunction = fragShader
        //3.3 确定渲染管线中颜色附着点0的颜色组件；使用当前view颜色组件
        pielineDes.colorAttachments[0].pixelFormat = view.colorPixelFormat
        
        //4 创建渲染管线状态
        do {
            try pielineState = _device?.makeRenderPipelineState(descriptor: pielineDes)
        } catch {
            //如果我们没有正确设置管道描述符，则管道状态创建可能失败
            print("pielineState failed \(error)")
        }
        
        
        // 将数据放入buffer中， 但是buffer是有大小上限：4KB
        vertexBuffer = _device?.makeBuffer(bytes: triangleVertices,
                                         length: triangleVertices.count * MemoryLayout<HRVertex>.size,
                                         options: .storageModeShared)
        
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        viewPortSize.x = uint(size.width)
        viewPortSize.y = uint(size.height)
    }
    
    func draw(in view: MTKView) {
        
        //设置view的clearColor
        view.clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 1.0)
        
        //5. 为每一次渲染创建一个新的命令缓冲区
        let commandBuffer = commandQueue?.makeCommandBuffer()
        commandBuffer?.label = "MyCommandBuffer"
        
        //6. 用于保存渲染过程中的一组结果，渲染命令编码器描述符
        if let des = view.currentRenderPassDescriptor {
            //7. 创建渲染命令编码器,通过它来进行渲染的配置
            let encoder = commandBuffer?.makeRenderCommandEncoder(descriptor: des)
            encoder?.label = "MyCommandEncoder"
            
            //8. 设置视口
            encoder?.setViewport(MTLViewport(originX: 0, originY: 0,
                                             width: Double(viewPortSize.x),
                                             height: Double(viewPortSize.y),
                                             znear: -1.0, zfar: 1.0))
            //9. 设置当前渲染管道状态对象
            encoder?.setRenderPipelineState(pielineState)
            
            //10. 载入顶点数据
            //通过VertexInputIndexVertices将数据传递到顶点函数的对应buffer中
//            encoder?.setVertexBytes(triangleVertices,
//                                    length: triangleVertices.count * MemoryLayout<HRVertex>.size,
//                                    index: Int(VertexInputIndexVertices.rawValue))
            
            encoder?.setVertexBytes(&viewPortSize,
                                    length: MemoryLayout<vector_uint2>.size,
                                    index: Int(VertexInputIndexViewPortSize.rawValue))
            
            //10. 通过buffer的方式载入顶点数据
            encoder?.setVertexBuffer(vertexBuffer,
                                     offset: 0,
                                     index: Int(VertexInputIndexVertices.rawValue))
            
            
            //11. 绘制动作
            /*
                type: 设置图元链接方式
                    case point = 0
                    case line = 1
                    case lineStrip = 2  //线环
                    case triangle = 3   //三角形
                    case triangleStrip = 4  //三角形扇
             */
            encoder?.drawPrimitives(type: .triangle,
                                    vertexStart: 0,
                                    vertexCount: triangleVertices.count)
            
            //12. 结束编码
            encoder?.endEncoding()
            
            //13. 锁定缓存区， 等待缓冲区处理完成后绘制
            if let currentDrawable = view.currentDrawable{
                commandBuffer?.present(currentDrawable)
            }
        }
        
        //14. 将命令缓存区提交给GPU
        commandBuffer?.commit()
    }
}
