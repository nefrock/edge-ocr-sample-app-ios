# バーコードスキャン

このチュートリアルでは，バーコードをスキャンする方法について説明します。


## 概要

`scanBarcodes`メソッドを使用して，画像内のバーコードをスキャンすることができます。

この例の実装は 
`EdgeOCRSample/Views/Barcode/BarcodeViewController.swift` と　
`EdgeOCRSample/Views/Barcode/BarcodeView.swift`，
`EdgeOCRSample/Views/Main/MainView.swift`，
に実装されていますので，ご参考になさってください．


## バーコード読み取りの実装方法
`EdgeOCRSample/Views/Main/MainView.swift` でバーコードスキャナの初期化とバーコードフォーマット毎の確定までの読み取り回数を設定しています．
サンプルではQRコードのみ5回読み取った後、結果を確定するように設定しています．
それ以外のバーコードフォーマットは読み取り回数を指定していないため、デフォルトでは1回の読み取り後に結果を確定します．
```swift

// MARK: バーコード読み取りの例の実装

Button(action: {
    // *QRCodeの複数回読み取りを設定する*
    let barcodeFormats = [(BarcodeFormat.QRCode, 5)]
    let edgeOCR = EdgeOCR.getInstance()
    edgeOCR.setBarcodesNToConfirm(barcodeFormats)

    loadModelAndNavigate(destination: .barcodeView)
}) {
    Text("バーコード読み取り")
}

```

`EdgeOCRSample/Views/BarcodeViewController.swift` でバーコードスキャンを実行しています．
OCR の場合と基本的には同じですが、バーコードを読む場合は `scanTexts` の代わりに `scanBarcodes` を呼び出してください。
また、`scanBarcodes` の第2引数には、`BarcodeScanOption` を用いて読みたいバーコードのフォーマットを指定します。
こちらのサンプルではすべてのバーコードのフォーマットを読み取るようにしていますが、
リストで指定することで、複数のフォーマットを指定することも可能です．

また、`EdgeOCRSample/Views/Main/MainView.swift` で設定した読み取り回数を超えた場合は、
`getStatus()` で `ScanConfirmationStatus.Confirmed` が返ります． 
本サンプルでは読み取り回数を超えたバーコードのみを結果として表示しています．

`showDialog()` でスキャン結果の表示後 `resetScanningState() `を呼び出すことで、
EdgeOCR のスキャン状況をリセットしています.
これにより、バーコードの確定までの読み取り回数をリセットすることができます.
```swift 
func showDialog(detections: [Detection<Barcode>]) {
    var messages: [String] = []
    for detection in detections {
        let text = detection.getScanObject().getText()
        messages.append(text)
    }
    self.messages = messages
    showDialog = true

    // MARK: - バーコードのスキャン状況をリセット

    edgeOCR.resetScanningState()
}

func drawDetections(result: ScanResult) {
    var detections: [Detection<Barcode>] = []

    CATransaction.begin()
    CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
    detectionLayer.sublayers = nil
    for detection in result.getBarcodeDetections() {
        let text = detection.getScanObject().getText()
        let status = detection.getStatus()
        if status == ScanConfirmationStatus.Confirmed {
            let bbox = detection.getBoundingBox()
            drawDetection(bbox: bbox, text: text)
            detections.append(detection)
        }
    }
    CATransaction.commit()

    if detections.count > 0 && !showDialog {
        showDialog(detections: detections)
    }
}

func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
    let scanResult: ScanResult
    do {
        // MARK: - バーコードの読み取り

        scanResult = try edgeOCR.scanBracodes(sampleBuffer, barcodeScanOption: barcodeScanOption, previewViewBounds: previewBounds)

    } catch {
        ...
    }

    DispatchQueue.main.async { [weak self] in
        self?.drawDetections(result: scanResult)
    }
}
```
