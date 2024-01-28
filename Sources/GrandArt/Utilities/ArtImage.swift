import CoreGraphics
import Foundation

/// Structure containing the inputs that require recalcuating each block
struct ArtImageShapeInputs {
  let imageHeight: Int
  let imageWidth: Int
  let iterationsMax: Double
  let scale: Double
  let xCenter: Double
  let yCenter: Double
  let theta: Double
  let dFIterMin: Double
  let rSqLimit: Double
}

/// Structure containing the inputs that require (only) recoloring
struct ArtImageColorInputs {
  let nBlocks: Int
  let nColors: Int
  let spacingColorFar: Double
  let spacingColorNear: Double
  let yY_input: Double
}

/// Global array to hold iteration values for Mandelbrot calculations.
var fIterGlobal = [[Double]]()

/// `ArtImage` is a struct responsible for generating the Mandelbrot art images.
@available(macOS 12.0, *)
struct ArtImage {
  // Only in GrandArt
  let grandPowerReal = ArtInputs.grandPowerReal
  let grandPowerImaginary = ArtInputs.grandPowerImaginary

  // In all
  let shapeInputs: ArtImageShapeInputs
  let colorInputs: ArtImageColorInputs

  init(picdef: PictureDefinition) {
    shapeInputs = ArtImageShapeInputs(
      imageHeight: picdef.imageHeight,
      imageWidth: picdef.imageWidth,
      iterationsMax: picdef.iterationsMax,
      scale: picdef.scale,
      xCenter: picdef.xCenter,
      yCenter: picdef.yCenter,
      theta: -picdef.theta, // negative
      dFIterMin: picdef.dFIterMin,
      rSqLimit: picdef.rSqLimit
    )
    colorInputs = ArtImageColorInputs(
      nBlocks: picdef.nBlocks,
      nColors: picdef.hues.count,
      spacingColorFar: picdef.spacingColorFar,
      spacingColorNear: picdef.spacingColorNear,
      yY_input: picdef.yY
    )
  }

  func isMandArt() -> Bool {
    return grandPowerImaginary == 0 && grandPowerReal == 2.0
  }

  func isMandArt3() -> Bool {
    return grandPowerImaginary == 0 && grandPowerReal == 3.0
  }

  // only in GrandA
  func complexPow(baseX: Double, baseY: Double, powerReal: Float, powerImaginary: Float = 0.0) -> (Double, Double) {
    if isMandArt() {
      // Special case for Mandelbrot set (power of 2)
      let xTemp = baseX * baseX - baseY * baseY
      let newY = 2.0 * baseX * baseY
      return (xTemp, newY)
    } else if isMandArt3() {
      // Special case for power of 3
      let xSquared = baseX * baseX
      let ySquared = baseY * baseY

      let xTemp = (xSquared - 3.0 * ySquared) * baseX
      let newY = (3.0 * xSquared - ySquared) * baseY
      return (xTemp, newY)
    } else if grandPowerImaginary == 0.0 {
      // Case for real powers
      let r = sqrt(baseX * baseX + baseY * baseY)
      let theta = atan2(baseY, baseX)
      let newR = pow(r, Double(powerReal))
      let newTheta = Double(powerReal) * theta

      let newX = newR * cos(newTheta)
      let newY = newR * sin(newTheta)
      return (newX, newY)
    } else {
      // General case for complex powers (real + imaginary)
      let r = sqrt(baseX * baseX + baseY * baseY)
      let theta = atan2(baseY, baseX)
      let newR = pow(r, Double(powerReal)) * exp(-Double(powerImaginary) * theta)
      let newTheta = Double(powerReal) * theta + Double(powerImaginary) * log(r)

      let newX = newR * cos(newTheta)
      let newY = newR * sin(newTheta)
      return (newX, newY)
    }
  }

  /**
   Function to create and return a user-created GrandArt bitmap

   - Parameters:
   - colors: array of colors

   - Returns: optional CGImage with the bitmap or nil
   */
  func getGrandArtFullPictureImage(colors: inout [[Double]]) -> CGImage? {
    let imageWidth = shapeInputs.imageWidth
    let imageHeight = shapeInputs.imageHeight

    // Resize for both width and height
    if fIterGlobal.count < imageHeight {
      fIterGlobal = Array(repeating: Array(repeating: 0.0, count: imageWidth), count: imageHeight)
    } else {
      for i in 0 ..< fIterGlobal.count {
        if fIterGlobal[i].count < imageWidth {
          fIterGlobal[i] = Array(repeating: 0.0, count: imageWidth)
        }
      }
    }

    let iterationsMax = shapeInputs.iterationsMax
    let scale = shapeInputs.scale
    let xCenter = shapeInputs.xCenter
    let yCenter = shapeInputs.yCenter

    let pi = 3.14159
    let thetaR: Double = pi * shapeInputs.theta / 180.0 // R for Radians
    var rSq = 0.0
    var rSqMax = 0.0
    var x0 = 0.0
    var y0 = 0.0
    var dX = 0.0
    var dY = 0.0
    var xx = 0.0
    var yy = 0.0
    var xTemp = 0.0
    var iter = 0.0
    var dIter = 0.0
    var gGML = 0.0
    var gGL = 0.0
    var fIter = [[Double]](repeating: [Double](repeating: 0.0, count: imageHeight), count: imageWidth)
    var fIterMinLeft = 0.0
    var fIterMinRight = 0.0
    var fIterBottom = [Double](repeating: 0.0, count: imageWidth)
    var fIterTop = [Double](repeating: 0.0, count: imageWidth)
    var fIterMinBottom = 0.0
    var fIterMinTop = 0.0
    var fIterMins = [Double](repeating: 0.0, count: 4)
    var fIterMin = 0.0
    var p = 0.0
    var test1 = 0.0
    var test2 = 0.0

    let rSqLimit = shapeInputs.rSqLimit
    rSqMax = 1.01 * (rSqLimit + 2) * (rSqLimit + 2)
    gGML = log(log(rSqMax)) - log(log(rSqLimit))
    gGL = log(log(rSqLimit))

    for u in 0 ... imageWidth - 1 {
      for v in 0 ... imageHeight - 1 {
        dX = (Double(u) - Double(imageWidth / 2)) / scale
        dY = (Double(v) - Double(imageHeight / 2)) / scale

        x0 = xCenter + dX * cos(thetaR) - dY * sin(thetaR)
        y0 = yCenter + dX * sin(thetaR) + dY * cos(thetaR)

        xx = x0
        yy = y0
        rSq = xx * xx + yy * yy
        iter = 0.0

        if isMandArt() {
          p = sqrt((xx - 0.25) * (xx - 0.25) + yy * yy)
          test1 = p - 2.0 * p * p + 0.25
          test2 = (xx + 1.0) * (xx + 1.0) + yy * yy

          if xx < test1 || test2 < 0.0625 {
            fIter[u][v] = iterationsMax // black
            iter = iterationsMax // black
          } else {
            for i in 1 ... Int(iterationsMax) {
              if rSq >= rSqLimit {
                break
              }

              xTemp = xx * xx - yy * yy + x0
              yy = 2 * xx * yy + y0
              xx = xTemp
              rSq = xx * xx + yy * yy
              iter = Double(i)
            }
          } // end else
        } else if isMandArt3() {
          for i in 1 ... Int(iterationsMax) {
            if rSq >= rSqLimit {
              break
            }

            xTemp = xx * xx * xx - 3 * xx * yy * yy + x0
            yy = 3 * xx * xx * yy - yy * yy * yy + y0
            xx = xTemp

            rSq = pow(xx, 2) + pow(yy, 2)
            iter = Double(i)
          }
        } else {
          for i in 1 ... Int(iterationsMax) {
            if rSq >= rSqLimit {
              break
            }
            // New grandPower exponent code .....
            let (newX, newY) = complexPow(
              baseX: xx,
              baseY: yy,
              powerReal: ArtInputs.grandPowerReal,
              powerImaginary: ArtInputs.grandPowerImaginary
            )
            xx = newX + x0
            yy = newY + y0
            rSq = xx * xx + yy * yy
            iter = Double(i)
          }
        } // end exponent differences

        if iter < iterationsMax {
          dIter = Double(-(log(log(rSq)) - gGL) / gGML)

          fIter[u][v] = iter + dIter
        } // end if

        else {
          fIter[u][v] = iter
        } // end else
      } // end first for v
    } // end first for u

    fIterGlobal = fIter

    for u in 0 ... imageWidth - 1 {
      fIterBottom[u] = fIter[u][0]
      fIterTop[u] = fIter[u][imageHeight - 1]
    } // end second for u

    fIterMinLeft = fIter[0].min()!
    fIterMinRight = fIter[imageWidth - 1].min()!
    fIterMinBottom = fIterBottom.min()!
    fIterMinTop = fIterTop.min()!
    fIterMins = [fIterMinLeft, fIterMinRight, fIterMinBottom, fIterMinTop]
    fIterMin = fIterMins.min()!

    fIterMin = fIterMin - shapeInputs.dFIterMin

    // Now we need to generate a bitmap image.

    let yY_input = colorInputs.yY_input
    var yY: Double = yY_input

    if yY_input == 1.0 {
      yY = yY_input - 1.0e-10
    }

    var spacingColorMid = 0.0
    var fNBlocks = 0.0
    var color = 0.0
    var block0 = 0
    var block1 = 0

    let nBlocks = colorInputs.nBlocks
    let spacingColorFar = colorInputs.spacingColorFar
    let spacingColorNear = colorInputs.spacingColorNear

    fNBlocks = Double(nBlocks)

    spacingColorMid = (iterationsMax - fIterMin - fNBlocks * spacingColorFar) / pow(fNBlocks, spacingColorNear)

    var blockBound = [Double](repeating: 0.0, count: nBlocks + 1)

    var h = 0.0
    var xX = 0.0

    for i in 0 ... nBlocks {
      blockBound[i] = spacingColorFar * Double(i) + spacingColorMid * pow(Double(i), spacingColorNear)
    }

    // set up CG parameters
    let bitsPerComponent = 8 // for UInt8
    let componentsPerPixel = 4 // RGBA = 4 components
    let bytesPerPixel: Int = (bitsPerComponent * componentsPerPixel) / 8 // 32/8 = 4
    let bytesPerRow: Int = imageWidth * bytesPerPixel
    let rasterBufferSize: Int = imageWidth * imageHeight * bytesPerPixel

    // Allocate data for the raster buffer.  Use UInt8 to
    // address individual RGBA components easily.
    let rasterBufferPtr = UnsafeMutablePointer<UInt8>.allocate(capacity: rasterBufferSize)

    // Create CGBitmapContext for drawing and converting into image for display
    let context =
      CGContext(
        data: rasterBufferPtr,
        width: imageWidth,
        height: imageHeight,
        bitsPerComponent: bitsPerComponent,
        bytesPerRow: bytesPerRow,
        space: CGColorSpace(name: CGColorSpace.sRGB)!,
        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
      )!

    // use CG to draw into the context
    // you can use any of the CG drawing routines for drawing into this context
    // here we will just erase the contents of the CGBitmapContext as the
    // raster buffer just contains random uninitialized data at this point.
    context.setFillColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0) // white
    context.addRect(CGRect(x: 0.0, y: 0.0, width: Double(imageWidth), height: Double(imageHeight)))
    context.fillPath()

    // Use any CG drawing routines, or draw yourself
    // by accessing individual pixels in the raster image.
    // here we'll draw a square one pixel at a time.
    let xStarting = 0
    let yStarting = 0
    let width: Int = imageWidth
    let height: Int = imageHeight

    // iterate over all of the rows for the entire height of the square
    for v in 0 ... (height - 1) {
      // calculate the offset to the row of pixels in the raster buffer
      // assume the origin is at the bottom left corner of the raster image.
      // note, you could also use the top left, but GC uses the bottom left
      // so this method keeps your drawing and CG in sync in case you wanted
      // to use the CG methods for drawing too.
      //
      // note, you could do this calculation all together inside of the xoffset
      // loop, but it's a small optimization to pull this part out and do it here
      // instead of every time through.
      let pixel_vertical_offset: Int = rasterBufferSize - (bytesPerRow * (Int(yStarting) + v + 1))

      // iterate over all of the pixels in this row
      for u in 0 ... (width - 1) {
        // calculate the horizontal offset to the pixel in the row
        let pixel_horizontal_offset: Int = ((Int(xStarting) + u) * bytesPerPixel)

        // sum the horixontal and vertical offsets to get the pixel offset
        let pixel_offset = pixel_vertical_offset + pixel_horizontal_offset

        // calculate the offset of the pixel
        let pixelAddress: UnsafeMutablePointer<UInt8> = rasterBufferPtr + pixel_offset

        if fIter[u][v] >= iterationsMax { // black
          pixelAddress.pointee = UInt8(0) // red
          (pixelAddress + 1).pointee = UInt8(0) // green
          (pixelAddress + 2).pointee = UInt8(0) // blue
          (pixelAddress + 3).pointee = UInt8(255) // alpha
        } // end if

        else {
          h = fIter[u][v] - fIterMin

          for block in 0 ... nBlocks {
            block0 = block

            if h >= blockBound[block], h < blockBound[block + 1] {
              if (h - blockBound[block]) / (blockBound[block + 1] - blockBound[block]) <= yY {
                h = blockBound[block]
              } else {
                h = blockBound[block] +
                  ((h - blockBound[block]) - yY * (blockBound[block + 1] - blockBound[block])) /
                  (1 - yY)
              }

              xX = (h - blockBound[block]) / (blockBound[block + 1] - blockBound[block])

              let nColors = colorInputs.nColors

              while block0 > nColors - 1 {
                block0 = block0 - nColors
              }

              block1 = block0 + 1

              if block1 == nColors {
                block1 = block1 - nColors
              }

              color = colors[block0][0] + xX * (colors[block1][0] - colors[block0][0])
              pixelAddress.pointee = UInt8(color) // R

              color = colors[block0][1] + xX * (colors[block1][1] - colors[block0][1])
              (pixelAddress + 1).pointee = UInt8(color) // G

              color = colors[block0][2] + xX * (colors[block1][2] - colors[block0][2])
              (pixelAddress + 2).pointee = UInt8(color) // B

              (pixelAddress + 3).pointee = UInt8(255) // alpha
            }
          }

          // IMPORTANT:
          // no type checking - make sure
          // address indexes do not go beyond memory allocated for buffer
        } // end else
      } // end for u
    } // end for v

    let contextImage = context.makeImage()!
    rasterBufferPtr.deallocate()
    contextImageGlobal = contextImage
    return contextImage
  }

  /**
   Function to create and return a user-colored GrandArt bitmap

   - Parameters:
   - colors: array of colors

   - Returns: optional CGImage with the colored bitmap or nil
   */
  func getNewlyColoredImage(colors: inout [[Double]]) -> CGImage? {
    if fIterGlobal.isEmpty {
      print("Error: fIterGlobal is empty")
      return nil
    }

    // Check if any inner array of fIterGlobal is empty
    for innerArray in fIterGlobal {
      if innerArray.isEmpty {
        print("Error: An inner array of fIterGlobal is empty")
        return nil
      }
    }

    let imageHeight: Int = shapeInputs.imageHeight
    let imageWidth: Int = shapeInputs.imageWidth

    let iterationsMax: Double = shapeInputs.iterationsMax
    let dFIterMin: Double = shapeInputs.dFIterMin
    let nBlocks: Int = colorInputs.nBlocks

    let nColors: Int = colorInputs.nColors
    let spacingColorFar: Double = colorInputs.spacingColorFar
    let spacingColorNear: Double = colorInputs.spacingColorNear

    let yY_input = colorInputs.yY_input
    var yY: Double = yY_input

    if yY_input == 1.0 {
      yY = yY_input - 1.0e-10
    }

    var contextImage: CGImage
    var fIterMinLeft = 0.0
    var fIterMinRight = 0.0
    var fIterBottom = [Double](repeating: 0.0, count: imageWidth)
    var fIterTop = [Double](repeating: 0.0, count: imageWidth)
    var fIterMinBottom = 0.0
    var fIterMinTop = 0.0
    var fIterMins = [Double](repeating: 0.0, count: 4)
    var fIterMin = 0.0

    for u in 0 ... imageWidth - 1 {
      fIterBottom[u] = fIterGlobal[u][0]
      fIterTop[u] = fIterGlobal[u][imageHeight - 1]
    } // end second for u

    fIterMinLeft = fIterGlobal[0].min()!
    fIterMinRight = fIterGlobal[imageWidth - 1].min()!
    fIterMinBottom = fIterBottom.min()!
    fIterMinTop = fIterTop.min()!
    fIterMins = [fIterMinLeft, fIterMinRight, fIterMinBottom, fIterMinTop]
    fIterMin = fIterMins.min()!

    fIterMin = fIterMin - dFIterMin

    // Now we need to generate a bitmap image.

    var spacingColorMid = 0.0
    var fNBlocks = 0.0
    var color = 0.0
    var block0 = 0
    var block1 = 0

    fNBlocks = Double(nBlocks)

    spacingColorMid = (iterationsMax - fIterMin - fNBlocks * spacingColorFar) / pow(fNBlocks, spacingColorNear)

    var blockBound = [Double](repeating: 0.0, count: nBlocks + 1)

    var h = 0.0
    var xX = 0.0

    for i in 0 ... nBlocks {
      blockBound[i] = spacingColorFar * Double(i) + spacingColorMid * pow(Double(i), spacingColorNear)
    }

    // set up CG parameters
    let bitsPerComponent = 8 // for UInt8
    let componentsPerPixel = 4 // RGBA = 4 components
    let bytesPerPixel: Int = (bitsPerComponent * componentsPerPixel) / 8 // = 4
    let bytesPerRow: Int = imageWidth * bytesPerPixel
    let rasterBufferSize: Int = imageWidth * imageHeight * bytesPerPixel

    // Allocate data for the raster buffer.  Using UInt8 so that I can
    // address individual RGBA components easily.
    let rasterBufferPtr = UnsafeMutablePointer<UInt8>.allocate(capacity: rasterBufferSize)

    // Create CGBitmapContext for drawing and converting into image for display
    let context =
      CGContext(
        data: rasterBufferPtr,
        width: imageWidth,
        height: imageHeight,
        bitsPerComponent: bitsPerComponent,
        bytesPerRow: bytesPerRow,
        space: CGColorSpace(name: CGColorSpace.sRGB)!,
        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
      )!

    // use CG to draw into the context
    // use any CG drawing routines for drawing into this context
    // here we will erase the contents of the CGBitmapContext as the
    // raster buffer just contains random uninitialized data at this point.
    context.setFillColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0) // white
    context.addRect(CGRect(x: 0.0, y: 0.0, width: Double(imageWidth), height: Double(imageHeight)))
    context.fillPath()

    // Use any CG drawing routines or draw yourself
    // by accessing individual pixels in the raster image.
    // We draw a square one pixel at a time.
    let xStarting = 0
    let yStarting = 0
    let width: Int = imageWidth
    let height: Int = imageHeight

    // iterate over all rows for the entire height of the square
    for v in 0 ... (height - 1) {
      // calculate the offset to the row of pixels in the raster buffer
      // assume origin is bottom left corner of the raster image.
      // note, you could also use the top left, but GC uses the bottom left
      // so this method keeps your drawing and CG in sync in case you want
      // to use CG methods for drawing too.
      let pixel_vertical_offset: Int = rasterBufferSize - (bytesPerRow * (Int(yStarting) + v + 1))

      // iterate over all of the pixels in this row
      for u in 0 ... (width - 1) {
        // calculate the horizontal offset to the pixel in the row
        let pixel_horizontal_offset: Int = ((Int(xStarting) + u) * bytesPerPixel)

        // sum the horixontal and vertical offsets to get the pixel offset
        let pixel_offset = pixel_vertical_offset + pixel_horizontal_offset

        // calculate the offset of the pixel
        let pixelAddress: UnsafeMutablePointer<UInt8> = rasterBufferPtr + pixel_offset

        if fIterGlobal[u][v] >= iterationsMax { // black
          pixelAddress.pointee = UInt8(0) // red
          (pixelAddress + 1).pointee = UInt8(0) // green
          (pixelAddress + 2).pointee = UInt8(0) // blue
          (pixelAddress + 3).pointee = UInt8(255) // alpha
        } else {
          h = fIterGlobal[u][v] - fIterMin

          for block in 0 ... nBlocks {
            block0 = block

            if h >= blockBound[block], h < blockBound[block + 1] {
              if (h - blockBound[block]) / (blockBound[block + 1] - blockBound[block]) <= yY {
                h = blockBound[block]
              } else {
                h = blockBound[block] +
                  ((h - blockBound[block]) - yY * (blockBound[block + 1] - blockBound[block])) /
                  (1 - yY)
              }

              xX = (h - blockBound[block]) / (blockBound[block + 1] - blockBound[block])

              while block0 > nColors - 1 {
                block0 = block0 - nColors
              }

              block1 = block0 + 1

              if block1 == nColors {
                block1 = block1 - nColors
              }

              color = colors[block0][0] + xX * (colors[block1][0] - colors[block0][0])
              pixelAddress.pointee = UInt8(color) // R

              color = colors[block0][1] + xX * (colors[block1][1] - colors[block0][1])
              (pixelAddress + 1).pointee = UInt8(color) // G

              color = colors[block0][2] + xX * (colors[block1][2] - colors[block0][2])
              (pixelAddress + 2).pointee = UInt8(color) // B

              (pixelAddress + 3).pointee = UInt8(255) // alpha
            }
          }
          // IMPORTANT:
          // no type checking - make sure that address indexes
          // do not go beyond memory allocated for the buffer
        } // end else
      } // end for u
    } // end for v

    contextImage = context.makeImage()!
    rasterBufferPtr.deallocate()
    contextImageGlobal = contextImage
    return contextImage
  }

  /// Creates a `CGContext` for drawing and converting into an image for display.
  /// - Parameters:
  ///   - width: Width of the context.
  ///   - height: Height of the context.
  ///   - bitsPerComponent: The number of bits used for each component of a pixel.
  ///   - componentsPerPixel: The number of components for each pixel.
  /// - Returns: A `CGContext` instance for drawing.
  static func createCGContext(
    width: Int,
    height: Int,
    bitsPerComponent: Int,
    componentsPerPixel: Int
  ) -> CGContext? {
    let bytesPerRow = width * (bitsPerComponent * componentsPerPixel) / 8
    let rasterBufferSize = width * height * (bitsPerComponent * componentsPerPixel) / 8
    let rasterBufferPtr = UnsafeMutablePointer<UInt8>.allocate(capacity: rasterBufferSize)

    let context = CGContext(
      data: rasterBufferPtr,
      width: width,
      height: height,
      bitsPerComponent: bitsPerComponent,
      bytesPerRow: bytesPerRow,
      space: CGColorSpace(name: CGColorSpace.sRGB)!,
      bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
    )

    return context
  }
}
