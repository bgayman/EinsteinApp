//
//  Einstein.swift
//  FaceAR_SDK_IOS_OpenFace_RunFull
//
//  Created by B Gay on 8/12/17.
//  Copyright © 2017 Keegan Ren. All rights reserved.
//
import UIKit
import CoreImage
import Vision

protocol EyeMath
{
    var leftEyeCenter: CGPoint { get }
    var rightEyeCenter: CGPoint { get }
}

extension EyeMath
{
    var eyeDistance: CGFloat
    {
        return sqrt(pow(rightEyeCenter.x - leftEyeCenter.x, 2) + pow(rightEyeCenter.y - leftEyeCenter.y, 2))
    }
    
    var eyeAngle: CGFloat
    {
        return atan((rightEyeCenter.y - leftEyeCenter.y) / (rightEyeCenter.x - leftEyeCenter.x))
    }
}

struct Face: EyeMath
{
    let leftEyeCenter: CGPoint
    let rightEyeCenter: CGPoint
    
    static let modelFace = Face(leftEyeCenter: CGPoint(x: 506,y: 984), rightEyeCenter: CGPoint(x: 1102, y: 956))
}

struct Einstein: EyeMath
{
    let image: UIImage
    let leftEyeCenter: CGPoint
    let rightEyeCenter: CGPoint
    let isLookingLeft: Bool
    static let einstein1 = Einstein(image: #imageLiteral(resourceName: "eistein1"), leftEyeCenter: CGPoint(x: 149, y: 222), rightEyeCenter: CGPoint(x: 254, y: 222), isLookingLeft: true)
    static let einstein2 = Einstein(image: #imageLiteral(resourceName: "einstein2"), leftEyeCenter: CGPoint(x: 87, y: 138), rightEyeCenter: CGPoint(x: 158, y: 142), isLookingLeft: true)
    static let einstein3 = Einstein(image: #imageLiteral(resourceName: "einstein3"), leftEyeCenter: CGPoint(x: 224, y: 271), rightEyeCenter: CGPoint(x: 318, y: 273), isLookingLeft: false)
    static let einstein4 = Einstein(image: #imageLiteral(resourceName: "einstein4"), leftEyeCenter: CGPoint(x: 237, y: 217), rightEyeCenter: CGPoint(x: 334, y: 225), isLookingLeft: false)
    static let einstein5 = Einstein(image: #imageLiteral(resourceName: "einstein5"), leftEyeCenter: CGPoint(x: 128, y: 288), rightEyeCenter: CGPoint(x: 255, y: 286), isLookingLeft: true)
    static let einstein6 = Einstein(image: #imageLiteral(resourceName: "einstein6"), leftEyeCenter: CGPoint(x: 854, y: 1037), rightEyeCenter: CGPoint(x: 1198, y: 1041), isLookingLeft: false)
    static let einstein7 = Einstein(image: #imageLiteral(resourceName: "einstein7"), leftEyeCenter: CGPoint(x: 70, y: 151), rightEyeCenter: CGPoint(x: 127, y: 144), isLookingLeft: true)
    static let einstein8 = Einstein(image: #imageLiteral(resourceName: "einstein8"), leftEyeCenter: CGPoint(x: 150, y: 140), rightEyeCenter: CGPoint(x: 232, y: 144), isLookingLeft: false)
    
    static let all: [Einstein] = [.einstein1, .einstein2, .einstein3, .einstein4, .einstein5, .einstein6, .einstein7, .einstein8]
    
    var ciImage: CIImage
    {
        return CIImage(image: image)!
    }
    
    func ciImageCoordinates(point: CGPoint) -> CGPoint
    {
        return CGPoint(x: point.x, y: image.size.height - point.y)
    }
    
    var verticalDiff: CGFloat
    {
        return (ciImageCoordinates(point: rightEyeCenter).y - ciImageCoordinates(point: leftEyeCenter).y)
    }
    
    var horizontalDiff: CGFloat
    {
        return (rightEyeCenter.x - leftEyeCenter.x)
    }
    
    var eyeAngle: CGFloat
    {
        return atan(verticalDiff / horizontalDiff)
    }
    
    func horizontalRotationOffset(rotation: CGFloat, scale: CGFloat) -> CGFloat
    {
        return cos(rotation) * leftEyeCenter.x * scale
    }
    
    func verticalRotationOffset(rotation: CGFloat, scale: CGFloat) -> CGFloat
    {
        return sin(rotation) * leftEyeCenter.x * scale
    }
}

extension Einstein: Equatable
{
    static func ==(lhs: Einstein, rhs: Einstein) -> Bool
    {
        return lhs.leftEyeCenter == rhs.leftEyeCenter && lhs.rightEyeCenter == rhs.rightEyeCenter
    }
}

struct VisionFace
{
    let rect: CGRect
    let landmarks: [Landmark]
}

struct Landmark
{
    let type: LandmarkType
    let points: [CGPoint]
    
    enum LandmarkType: String
    {
        case faceContour
        case leftEye
        case rightEye
        case leftEyebrow
        case rightEyebrow
        case nose
        case noseCrest
        case medianLine
        case outerLips
        case innerLips
        case leftPupil
        case rightPupil
    }
}

extension VNFaceLandmarks2D
{
    
    var landmarkRegions: [VNFaceLandmarkRegion2D]
    {
        var landmarkRegions = [VNFaceLandmarkRegion2D]()
        if let faceContour = faceContour
        {
            landmarkRegions.append(faceContour)
        }
        if let leftEye = leftEye
        {
            landmarkRegions.append(leftEye)
        }
        if let rightEye = rightEye
        {
            landmarkRegions.append(rightEye)
        }
        if let nose = nose
        {
            landmarkRegions.append(nose)
        }
        if let outerLips = outerLips
        {
            landmarkRegions.append(outerLips)
        }
        return landmarkRegions
    }
}

extension VNFaceLandmarkRegion2D {
    
    var cgPoints: [CGPoint]
    {
        return (0..<pointCount).map
            { index in
                let point = self.point(at: index)
                return CGPoint(x: CGFloat(point.x), y: CGFloat(point.y))
        }
    }
}

final class LandmarksService
{
    
    enum Results
    {
        case success([VisionFace]), error(Swift.Error)
    }
    
    enum Error: Swift.Error
    {
        case emptyResults
    }
    
    func landmarks(forImage image: CIImage, completion: @escaping (Results) -> ())
    {
        let request = VNDetectFaceLandmarksRequest
        { [unowned self] request, error in
            if let error = error
            {
                completion(.error(error))
                return
            }
            self.handle(request, image: image, completion: completion)
        }
        let handler = VNImageRequestHandler(ciImage: image, options: [:])
        do
        {
            try handler.perform([request])
        }
        catch
        {
            completion(.error(error))
        }
    }
    
    func landmarks(forImage image: UIImage, completion: @escaping (Results) -> ())
    {
        let request = VNDetectFaceLandmarksRequest
        { [unowned self] request, error in
            if let error = error
            {
                completion(.error(error))
                return
            }
            self.handle(request, image: image, completion: completion)
        }
        let handler = VNImageRequestHandler(cgImage: image.cgImage!, options: [:])
        do
        {
            try handler.perform([request])
        }
        catch
        {
            completion(.error(error))
        }
    }
    
    private func handle(_ request: VNRequest, image: CIImage, completion: (Results) -> Void)
    {
        guard let observations = request.results as? [VNFaceObservation] else
        {
            completion(.error(Error.emptyResults))
            return
        }
        
        let faces: [VisionFace] = observations.map { observation in
            var finalLandmarks = [Landmark]()
            if let landmarks = observation.landmarks
            {
                finalLandmarks.append(contentsOf: convert(landmarks: landmarks))
            }
            
            let faceRect = observation.boundingBox
            let convertedFaceRect = CGRect(x: image.extent.width * faceRect.origin.x,
                                           y: image.extent.height * (1 - faceRect.origin.y - faceRect.height),
                                           width: image.extent.width * faceRect.width,
                                           height: image.extent.height * faceRect.height)
            return VisionFace(rect: convertedFaceRect, landmarks: finalLandmarks)
        }
        completion(.success(faces))
    }
    
    private func handle(_ request: VNRequest, image: UIImage, completion: (Results) -> Void)
    {
        guard let observations = request.results as? [VNFaceObservation] else
        {
            completion(.error(Error.emptyResults))
            return
        }
        
        let faces: [VisionFace] = observations.map { observation in
            var finalLandmarks = [Landmark]()
            if let landmarks = observation.landmarks
            {
                finalLandmarks.append(contentsOf: convert(landmarks: landmarks))
            }
            
            let faceRect = observation.boundingBox
            let convertedFaceRect = CGRect(x: image.size.width * faceRect.origin.x,
                                           y: image.size.height * (1 - faceRect.origin.y - faceRect.height),
                                           width: image.size.width * faceRect.width,
                                           height: image.size.height * faceRect.height)
            return VisionFace(rect: convertedFaceRect, landmarks: finalLandmarks)
        }
        completion(.success(faces))
    }
    
    private func convert(landmarks: VNFaceLandmarks2D) -> [Landmark]
    {
        var finalLandmarks = [Landmark]()
        if let faceContour = landmarks.faceContour
        {
            finalLandmarks.append(Landmark(type: .faceContour, points: faceContour.cgPoints))
        }
        if let leftEye = landmarks.leftEye
        {
            finalLandmarks.append(Landmark(type: .leftEye, points: leftEye.cgPoints))
        }
        if let rightEye = landmarks.rightEye
        {
            finalLandmarks.append(Landmark(type: .rightEye, points: rightEye.cgPoints))
        }
        if let nose = landmarks.nose
        {
            finalLandmarks.append(Landmark(type: .nose, points: nose.cgPoints))
        }
        if let outerLips = landmarks.outerLips
        {
            finalLandmarks.append(Landmark(type: .outerLips, points: outerLips.cgPoints))
        }
        return finalLandmarks
    }
}
