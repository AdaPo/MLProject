//
//  ImageUtils.swift
//  MachineLearningProject
//
//  Created by Adam Poustka on 15.06.2025.
//

import Foundation
import UIKit
import Accelerate

struct ImageUtils {
  
  // Create pixel buffer from UIImage
  static func pixelBufferCreate(image: UIImage) -> CVPixelBuffer? {
    var pixelBuffer: CVPixelBuffer?
    let status = CVPixelBufferCreate(
      kCFAllocatorDefault, // allocator
      Int(image.size.width), // width
      Int(image.size.height), // height
      kCVPixelFormatType_32BGRA, // pixel format
      [
        kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
        kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue
      ] as CFDictionary, // buffer attribs
      &pixelBuffer // buffer
    )
    guard let pixelBuffer, status == kCVReturnSuccess else {
      print("Unable to create pixel buffer")
      return nil
    }
    
    CVPixelBufferLockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
    defer {
      CVPixelBufferUnlockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
    }
    
    guard let pixelData =  CVPixelBufferGetBaseAddress(pixelBuffer) else {
      print("Unable to get pixel data")
      return nil
    }
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    
    let context = CGContext(
      data: pixelData,
      width: Int(image.size.width),
      height: Int(image.size.height),
      bitsPerComponent: 8,
      bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer),
      space: colorSpace,
      bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
    )
    guard let context else {
      print("Unable to create context")
      return nil
    }
    
    // Core Graphics origin is bottom-left while UIKit origin is top-left
    context.translateBy(x: 0, y: image.size.height)
    context.scaleBy(x: 1, y: -1)
    
    UIGraphicsPushContext(context)
    image.draw(in: CGRect(origin: .zero, size: image.size))
    UIGraphicsPopContext()
        
    return pixelBuffer
  }
  
  // Create resized pixel buffer
  static func pixelBufferCreateWith(pixelBuffer: CVPixelBuffer, resizedTo size: CGSize) -> CVPixelBuffer? {
    let imageChannels = 4
    let bufferWidth = CVPixelBufferGetWidth(pixelBuffer)
    let bufferHeight = CVPixelBufferGetHeight(pixelBuffer)
    let inputBytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)

    CVPixelBufferLockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
    defer {
      CVPixelBufferUnlockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
    }

    guard let inputBaseAddress = CVPixelBufferGetBaseAddress(pixelBuffer) else {
      print("Unable to get base pointer")
      return nil
    }
    
    // find the biggest square within source image
    var inputFrame = CGRect.zero
    if bufferWidth > bufferHeight {
      inputFrame.origin.x = CGFloat(bufferWidth - bufferHeight) * 0.5
    }
    else if bufferHeight > bufferWidth {
      inputFrame.origin.y = CGFloat(bufferHeight - bufferWidth) * 0.5
    }
    inputFrame.size.width = CGFloat(min(bufferWidth, bufferHeight))
    inputFrame.size.height = inputFrame.size.width

    let inputData = inputBaseAddress.advanced(
      by: (Int(inputFrame.origin.y) * inputBytesPerRow) + (Int(inputFrame.origin.x) * imageChannels)
    )

    var inputImageBuffer = vImage_Buffer(
        data: inputData,
        height: UInt(inputFrame.width),
        width: UInt(inputFrame.height),
        rowBytes: inputBytesPerRow
    )

    let outputBytesPerRow = Int(size.width) * imageChannels
    let outputData = UnsafeMutableRawPointer.allocate(byteCount: Int(size.height) * outputBytesPerRow, alignment: 1)
    var outputImageBuffer = vImage_Buffer(
      data: outputData,
      height: UInt(size.height),
      width: UInt(size.width),
      rowBytes: outputBytesPerRow
    )

    // Performs the scale operation on input image buffer and stores it in output image buffer.
    let scaleError = vImageScale_ARGB8888(
      &inputImageBuffer, // src
      &outputImageBuffer, // dst
      nil, // tmp
      vImage_Flags(0) // flags
    )

    guard scaleError == kvImageNoError else {
      outputData.deallocate()
      return nil
    }

    let releaseCallBack: CVPixelBufferReleaseBytesCallback = { _, baseAddr in
      guard let baseAddr = baseAddr else { return }
      baseAddr.deallocate()
    }

    var outputPixelBuffer: CVPixelBuffer?
    let result = CVPixelBufferCreateWithBytes(
        nil, // allocator
        Int(size.width), // width
        Int(size.height), // height
        kCVPixelFormatType_32BGRA, // pixel format
        outputData, // base address
        outputBytesPerRow, // bytes per row
        releaseCallBack, // release callback
        nil, // user data
        nil, // pixel buffer attribs
        &outputPixelBuffer // pixel buffer out
    )

    guard result == kCVReturnSuccess else {
      outputData.deallocate()
      return nil
    }

    return outputPixelBuffer
  }
  
  // Create RGB color data from a pixel buffer
  static func pixelBufferCreateRGBData(pixelBuffer: CVPixelBuffer, byteCount: Int) -> Data? {
    CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)
    defer { CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly) }
    guard let baseAddr = CVPixelBufferGetBaseAddress(pixelBuffer) else {
      return nil
    }
    let count = CVPixelBufferGetDataSize(pixelBuffer)
    let bufferData = Data(bytesNoCopy: baseAddr, count: count, deallocator: .none)
    var rgbData: [Float] = Array(repeating: 0, count: byteCount)
    var index = 0
    for (offset, element) in bufferData.enumerated() {
      let isAlphaComponent = (offset % 4) == 3
      if isAlphaComponent { continue }
      rgbData[index] = Float(element) / 255.0
      index += 1
    }
    
    return rgbData.withUnsafeBufferPointer { ptr in
      Data(buffer: ptr)
    }
  }
}
