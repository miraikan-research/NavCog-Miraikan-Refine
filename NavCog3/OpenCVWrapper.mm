//
//  OpenCVWrapper.mm
//  NavCogMiraikan
//
/*******************************************************************************
 * Copyright (c) 2023 © Miraikan - The National Museum of Emerging Science and Innovation
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *******************************************************************************/

#import <opencv2/opencv.hpp>
#import <opencv2/core.hpp>
#import <opencv2/imgcodecs/ios.h>
#import <opencv2/imgproc/imgproc.hpp>

#include "opencv2/aruco.hpp"

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <SceneKit/SceneKit.h>
#import <CoreVideo/CoreVideo.h>

#import "MarkerWorldTransform.h"
#import "OpenCVWrapper.h"

@implementation OpenCVWrapper

///
static cv::Mat rotateRodriques(cv::Mat &rotMat, cv::Vec3d &tvecs) {
    cv::Mat extrinsics(4, 4, CV_64F);
    
    for( int row = 0; row < rotMat.rows; row++) {
        for (int col = 0; col < rotMat.cols; col++) {
            extrinsics.at<double>(row,col) = rotMat.at<double>(row,col);
        }
        extrinsics.at<double>(row,3) = tvecs[row];
    }
    extrinsics.at<double>(3,3) = 1;

    // Convert Opencv coords to OpenGL coords
    extrinsics = [OpenCVWrapper getCVToGLMat]* extrinsics;
    return extrinsics;
}

static void detect(std::vector<std::vector<cv::Point2f> > &corners, std::vector<int> &ids, CVPixelBufferRef pixelBuffer) {
    cv::aruco::Dictionary dictionary = cv::aruco::getPredefinedDictionary(cv::aruco::DICT_7X7_1000);
    cv::Ptr<cv::aruco::Dictionary>ptrDictionary = cv::makePtr<cv::aruco::Dictionary>(dictionary);

    // grey scale channel at 0
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    void *baseaddress = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0);
    CGFloat width = CVPixelBufferGetWidth(pixelBuffer);
    CGFloat height = CVPixelBufferGetHeight(pixelBuffer);
    cv::Mat mat(height, width, CV_8UC1, baseaddress, 0); //CV_8UC1
    // マーカー検出
    cv::aruco::detectMarkers(mat, ptrDictionary, corners, ids);

    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
}

+ (cv::Mat)getCVToGLMat {
    cv::Mat cvToGL = cv::Mat::zeros(4, 4, CV_64F);
    cvToGL.at<double>(0,0) = 1.0f;
    cvToGL.at<double>(1,1) = -1.0f; //invert y
    cvToGL.at<double>(2,2) = -1.0f; //invert z
    cvToGL.at<double>(3,3) = 1.0f;
    return cvToGL;
}

+ (SCNMatrix4)transformToSceneKitMatrix:(cv::Mat&) openCVTransformation {
    
    SCNMatrix4 mat = SCNMatrix4Identity;
    openCVTransformation = openCVTransformation.t();
    
    mat.m11 = (float)openCVTransformation.at<double>(0, 0);
    mat.m12 = (float)openCVTransformation.at<double>(0, 1);
    mat.m13 = (float)openCVTransformation.at<double>(0, 2);
    mat.m14 = (float)openCVTransformation.at<double>(0, 3);
    
    mat.m21 = (float)openCVTransformation.at<double>(1, 0);
    mat.m22 = (float)openCVTransformation.at<double>(1, 1);
    mat.m23 = (float)openCVTransformation.at<double>(1, 2);
    mat.m24 = (float)openCVTransformation.at<double>(1, 3);
    
    mat.m31 = (float)openCVTransformation.at<double>(2, 0);
    mat.m32 = (float)openCVTransformation.at<double>(2, 1);
    mat.m33 = (float)openCVTransformation.at<double>(2, 2);
    mat.m34 = (float)openCVTransformation.at<double>(2, 3);
    
    mat.m41 = (float)openCVTransformation.at<double>(3, 0);
    mat.m42 = (float)openCVTransformation.at<double>(3, 1);
    mat.m43 = (float)openCVTransformation.at<double>(3, 2);
    mat.m44 = (float)openCVTransformation.at<double>(3, 3);
    
    return mat;
}

// 画像データからマーカー認識、認識マーカーデータ返却
+ (NSMutableArray *) estimatePose:(CVPixelBufferRef)pixelBuffer withIntrinsics:(matrix_float3x3)intrinsics andMarkerSize:(float)markerSize {
    std::vector<int> ids;
    std::vector<std::vector<cv::Point2f>> corners;
    detect(corners, ids, pixelBuffer);
    
    NSMutableArray *arrayMatrix = [NSMutableArray new];
    if(ids.size() == 0) {
        return arrayMatrix;
    }

    cv::Mat intrinMat(3, 3, CV_64F);
    intrinMat.at<double>(0,0) = intrinsics.columns[0][0];
    intrinMat.at<double>(0,1) = intrinsics.columns[1][0];
    intrinMat.at<double>(0,2) = intrinsics.columns[2][0];
    intrinMat.at<double>(1,0) = intrinsics.columns[0][1];
    intrinMat.at<double>(1,1) = intrinsics.columns[1][1];
    intrinMat.at<double>(1,2) = intrinsics.columns[2][1];
    intrinMat.at<double>(2,0) = intrinsics.columns[0][2];
    intrinMat.at<double>(2,1) = intrinsics.columns[1][2];
    intrinMat.at<double>(2,2) = intrinsics.columns[2][2];
    
//    NSLog(@"intrinsics -------------------- カメラの内部構造");
//    // カメラの内部構造。行列の内容は以下の通り：
//    //      fx 0 px
//    //      0 fy py
//    //      0 0 1
//    //      fx と fy はピクセル単位の焦点距離。
//    //      px と py はピクセル単位の主点座標。
//    //      原点は左上のピクセルの中心である。
//    for (int i = 0; i < 3; i++) {
//        NSLog(@"%.6f,  %.6f,  %.6f", intrinsics.columns[i][0], intrinsics.columns[i][1], intrinsics.columns[i][2]);
//    }
//
//    // 右上が(0, 0)
//    NSLog(@"corners --------------------");
//    for (int i = 0; i < corners.size(); i++) {
//        for (int j = 0; j < corners[i].size(); j++) {
//            NSLog(@"(%f,  %f)", corners[i][j].x, corners[i][j].y);
//        }
//    }

    std::vector<cv::Vec3d> rvecs, tvecs;
    cv::Mat distCoeffs = cv::Mat::zeros(8, 1, CV_64F);

    // マーカーの姿勢推定
    // corners: 配列の入力配列
    // markerSize: マーカーの長さ(m)(float型)
    // intrinMat: カメラマトリックス(3x3)(入力配列)
    // distCoeffs: 歪係数、レンズの歪(入力配列)
    // rvecs: 回転ベクトル(出力配列)
    // tvecs: 並進ベクトル(出力配列)
    cv::aruco::estimatePoseSingleMarkers(corners, markerSize, intrinMat, distCoeffs, rvecs, tvecs);
    
//    NSLog(@"rvecs -------------------- 回転ベクトル");
//    for (int i = 0; i < rvecs.size(); i++) {
//        NSLog(@"(%f, %f, %f)", rvecs[i].val[0], rvecs[i].val[1], rvecs[i].val[2]);
//    }
//
//    NSLog(@"tvecs -------------------- 並進ベクトル");
//    for (int i = 0; i < tvecs.size(); i++) {
//        NSLog(@"(%f, %f, %f)", tvecs[i].val[0], tvecs[i].val[1], tvecs[i].val[2]);
//    }

    cv::Mat rotMat;
    for (int i = 0; i < rvecs.size(); i++) {
        cv::Rodrigues(rvecs[i], rotMat);
        cv::Mat extrinsics = rotateRodriques(rotMat, tvecs[i]);
        SCNMatrix4 scnMatrix = [OpenCVWrapper transformToSceneKitMatrix:extrinsics];
//        NSLog(@"%d, %f, %f, %f", i, rvecs[i][0], rvecs[i][1], rvecs[i][2]);
//        NSLog(@"scnMatrix -------------------- 座標空間変換");
//        NSLog(@"(%f, %f, %f, %f)", scnMatrix.m11, scnMatrix.m12, scnMatrix.m13, scnMatrix.m14);
//        NSLog(@"(%f, %f, %f, %f)", scnMatrix.m21, scnMatrix.m22, scnMatrix.m23, scnMatrix.m24);
//        NSLog(@"(%f, %f, %f, %f)", scnMatrix.m31, scnMatrix.m32, scnMatrix.m33, scnMatrix.m34);
//        NSLog(@"(%f, %f, %f, %f)", scnMatrix.m41, scnMatrix.m42, scnMatrix.m43, scnMatrix.m44);

        MarkerWorldTransform *transform = [MarkerWorldTransform new];
        transform.arucoId = ids[i];
        transform.transform = scnMatrix;
        transform.roll = atan2((float)-extrinsics.at<double>(2, 1), (float)extrinsics.at<double>(2, 2)) * 180.0 / M_PI;
        transform.pitch = asin((float)extrinsics.at<double>(2, 0)) * 180.0 / M_PI;
        transform.yaw = atan2((float)-extrinsics.at<double>(1, 0), (float)extrinsics.at<double>(0, 0)) * 180.0 / M_PI;

        cv::Mat cameraPose = -rotMat.t() * (cv::Mat)tvecs[i];
        double x = cameraPose.at<double>(0,0);
        double y = cameraPose.at<double>(0,1);
        double z = cameraPose.at<double>(0,2);
        float distance = float(sqrt(x * x + y * y + z * z));
        float horizontalDistance = float(sqrt(x * x + y * y));

        transform.x = x;
        transform.y = y;
        transform.z = z;
        transform.distance = distance;
        transform.horizontalDistance = horizontalDistance;
        
        NSMutableArray* corner = [[NSMutableArray alloc] initWithCapacity:corners[i].size()];
        for (auto point: corners[i]) {
            [corner addObject:[NSValue valueWithCGPoint:CGPointMake(point.x, point.y)]];
        }
        transform.points = corner;

        // マーカー中心点
        CGPoint a1 = [[corner objectAtIndex:0] CGPointValue];
        CGPoint b1 = [[corner objectAtIndex:1] CGPointValue];
        CGPoint a2 = [[corner objectAtIndex:2] CGPointValue];
        CGPoint b2 = [[corner objectAtIndex:3] CGPointValue];

        double s1 = ((b2.x - b1.x) * (a1.y - b1.y) - (b2.y - b1.y) * (a1.x - b1.x)) / 2.0;
        double s2 = ((b2.x - b1.x) * (b1.y - a2.y) - (b2.y - b1.y) * (b1.x - a2.x)) / 2.0;

        CGPoint c1 = CGPointMake(a1.x + (a2.x - a1.x) * s1 / (s1 + s2), a1.y + (a2.y - a1.y) * s1 / (s1 + s2));
        
        transform.intersection = c1;

        [arrayMatrix addObject:transform];
    }

    return arrayMatrix;
}

// デバッグ用, idに対応したマーカー画像を生成
+ (UIImage *)createARMarker:(int)markerId {
    cv::Mat markerImage;
    cv::aruco::Dictionary dictionary = cv::aruco::getPredefinedDictionary(cv::aruco::DICT_7X7_1000);
    cv::aruco::generateImageMarker(dictionary, markerId, 200, markerImage, 1);
    UIImage * output_img = MatToUIImage(markerImage);
    return output_img;
}

// デバッグ用, 静止画の画像にマーカーの認識を描画した画像データを生成する, openCV上でのARマーカーの認識状態の確認。
+ (UIImage *)detectARMarker:(UIImage *)inputImg {
    cv::Mat mat;
    UIImageToMat(inputImg, mat);
    cvtColor(mat, mat, cv::COLOR_RGBA2RGB);

    std::vector<int> ids;
    std::vector<std::vector<cv::Point2f>> corners;

    cv::Ptr<cv::aruco::Dictionary>dictionary = cv::makePtr<cv::aruco::Dictionary>(cv::aruco::getPredefinedDictionary(cv::aruco::DICT_7X7_1000));
    // マーカー検出
    cv::aruco::detectMarkers(mat, dictionary, corners, ids);

    if (ids.size() > 0) {
        cv::aruco::drawDetectedMarkers(mat, corners, ids); // draw bounding boxes.
    }

    UIImage* output_img = MatToUIImage(mat);

    // for deta check
//    NSMutableDictionary *mutableDict =  [@{} mutableCopy];
//    for (int i = 0; i < ids.size(); i++) {
//        auto id = ids[i];
//        NSNumber* markerId = [NSNumber numberWithInt:id];
//        NSMutableArray* corner = [[NSMutableArray alloc] initWithCapacity:corners[i].size()];
//        for (auto point: corners[i]) {
//            [corner addObject:[NSValue valueWithCGPoint:CGPointMake(point.x, point.y)]];
//        }
//        mutableDict[markerId] = corner;
//    }
//    _markerDict = mutableDict;

    return output_img;
}

@end
