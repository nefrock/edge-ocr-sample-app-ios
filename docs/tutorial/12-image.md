# 画像のOCR
このチュートリアルでは，`CMSampleBuffer`　ではなく，`UIImage` から画像をスキャンする方法を説明いたします．


## 概要
画像に対して，テキストをスキャンするのは `scan(:image)` メソッドに，
`UIImage` を引数として渡すことで行うことができます．
一方で，バーコードをスキャンするのは `scan(:image)` メソッドに，
`UIImage` を引数として渡すことで行うことができます．

テキスト画像の読み込みの実装は
`EdgeOCRSample/Views/TextImage/TextImageView.swift` と　
`EdgeOCRSample/Views/TextImage/TextImageFooter.swift`，
`EdgeOCRSample/Views/TextImage/TextImageScanner.swift`，
`EdgeOCRSample/Views/Main/MainView.swift`，
に実装されていますので，ご参考になさってください．

バーコード画像の実装は
`EdgeOCRSample/Views/BarcodeImage/BarcodeImageView.swift` と　
`EdgeOCRSample/Views/BarcodeImage/BarcodeImageFooter.swift`，
`EdgeOCRSample/Views/BarcodeImage/BarcodeImageScanner.swift`，
`EdgeOCRSample/Views/Main/MainView.swift`，
に実装されていますので，ご参考になさってください．


## Text画像のスキャン方法
`Assets.xcassets` に保存された画像 `sample_text.jpeg` を `UIImage` に変換し，`scan(:image)` メソッドに渡しています．
`UIImage` を引数に `scan` を呼び出した場合は，同期的にOCR結果が返却されます．

```swift
extension UIImage {
    // MARK: - テキスト画像スキャン

    func scanTextImage() throws -> UIImage? {
        let edgeOCR = EdgeOCR.getInstance()

        let rotatedImage = self.fixImageRotation()

        // MARK: - 画像からテキストを検出・認識

        let detections = try edgeOCR.scan(rotatedImage)

        // MARK: - バウンデイングボックスの座標を画像の絶対座標へ変換

        var boundingBoxes: [CGRect] = []
        var texts: [String] = []
        for detection in detections.getTextDetections() {
            let bbox = detection.getBoundingBox()
            let x = self.size.width * bbox.minX
            let y = self.size.height * bbox.minY
            let width = self.size.width * bbox.width
            let height = self.size.height * bbox.height
            let rect = CGRect(x: x, y: y, width: width, height: height)
            boundingBoxes.append(rect)
            texts.append(detection.getText())
        }

        // MARK: - 検出・認識結果を画像に反映させた新しい画像を生成

        let imagesWithBbox =
            self.drawBoundingBoxes(
                boundingBoxes: boundingBoxes,
                texts: texts,
                textColor: UIColor.black,
                boxColor: UIColor.green.withAlphaComponent(0.5))

        return imagesWithBbox
    }
}
```


## Barcode画像のスキャン方法
`Assets.xcassets` に保存された画像 `sample_barcode.jpeg` を `UIImage` に変換し，`scan(:image)` メソッドに渡しています．
`UIImage` を引数に `scan` を呼び出した場合は，同期的にOCR結果が返却されます．
```swift
extension UIImage {
    // MARK: - バーコード画像スキャン

    func scanBarcodeImage() throws -> UIImage? {
        let edgeOCR = EdgeOCR.getInstance()

        let rotatedImage = self.fixImageRotation()

        // MARK: - 画像からバーコードを検出・認識

        let barcodeScanOption = BarcodeScanOption(
            targetFormats: [BarcodeFormat.AnyFormat])
        let detections = try edgeOCR.scan(rotatedImage,
                                                  barcodeScanOption: barcodeScanOption)

        // MARK: - バウンデイングボックスの座標を画像の絶対座標へ変換

        var boundingBoxes: [CGRect] = []
        var texts: [String] = []
        for detection in detections.getBarcodeDetections() {
            let bbox = detection.getBoundingBox()
            let x = self.size.width * bbox.minX
            let y = self.size.height * bbox.minY
            let width = self.size.width * bbox.width
            let height = self.size.height * bbox.height
            let rect = CGRect(x: x, y: y, width: width, height: height)
            boundingBoxes.append(rect)
            texts.append(detection.getText())
        }

        // MARK: - 検出・認識結果を画像に反映させた新しい画像を生成

        let imagesWithBbox =
            self.drawBoundingBoxes(
                boundingBoxes: boundingBoxes,
                texts: texts,
                textColor: UIColor.black,
                boxColor: UIColor.green.withAlphaComponent(0.5))

        return imagesWithBbox
    }
}
```


## 次のステップ
次はマスターデータを用いたOCRの方法を説明します．

↪️ [マスターデータを用いたOCR (完全一致)](13-whitelist.md)
