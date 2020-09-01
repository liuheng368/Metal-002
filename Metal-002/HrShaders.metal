//
//  HrShaders.metal
//  Metal-002
//
//  Created by Henry on 2020/9/1.
//  Copyright © 2020 刘恒. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

#import "HrShaderType.h"

typedef struct {
    //处理空间的顶点信息
    //position是关键字，类似于GLSL中的gl_Position
    float4 clipSpacePosition [[position]];

    //颜色
    float4 color;
} RasterizerData;


/*
    vertex:函数限定符，限定该函数为顶点函数
    RasterizerData:函数返回值，会将该参数经过光栅化后传递到片元函数
    vertexShader:函数自定义名称
    uint vertexId [[vertex_id]]: uint变量类型：无符号32位整型; vertexId变量名;
                                [[vertex_id]]属性修饰符：代表顶点编号固定写法，开发者不得修改
    constant HRVertex *vertexs [[buffer(VertexInputIndexVertices)]]:
        constant变量限定符：存储在GPU的常量缓存区中; HRVertex:变量类型; vertexs：变量名;
        [[buffer(...)]]: 标示数据在缓存区中，位置编号（句柄）为：VertexInputIndexVertices
 */
vertex RasterizerData vertexShader(uint vertexId [[vertex_id]],
                                   constant HRVertex *vertexs [[buffer(VertexInputIndexVertices)]],
                                   constant vector_float2 *viewportSize [[buffer(VertexInputIndexViewPortSize)]]) {
    RasterizerData out;
    
    out.clipSpacePosition = vertexs[vertexId].position;
    //把我们输入的颜色直接赋值给输出颜色.通过这种方式将颜色数据桥接到片元着色器
    out.color = vertexs[vertexId].color;
    
    return out;
}

/*
    fragment函数限定符：片元函数
    float4:返回值
    fragmentShader:函数名
    RasterizerData in [[stage_in]]: RasterizerData变量类型; in变量名;
                                    [[stage_in]]属性修饰符:片元着色函数使用的单个片元输入数据是由顶点着色函数输出.然后经过光栅化生成的
 */
fragment float4 fragmentShader(RasterizerData in [[stage_in]]) {
    //返回该像素点的色值
    return in.color;
}
