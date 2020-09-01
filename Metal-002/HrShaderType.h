//
//  HrShaderType.h
//  Metal-002
//
//  Created by Henry on 2020/9/1.
//  Copyright © 2020 刘恒. All rights reserved.
//

#ifndef HrShaderType_h
#define HrShaderType_h

//定义了基本的向量、矩阵、四元数，该头文件同时存在于Metal Shader / swift | Objc中，方便相互传递数据
#include <simd/simd.h>

//该文件作用：通过文件引入的方式，将一些自定义的类型声明既传递到swift文件，同时也传递到metal文件中
typedef struct {
    vector_float4 position;
    vector_float4 color;
} HRVertex;

typedef enum {
    //顶点数据
    VertexInputIndexVertices = 0,
    //视图大小
    VertexInputIndexViewPortSize = 1,
}VertexInputIndex;

#endif /* HrShaderType_h */
