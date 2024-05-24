# 最もシンプルな例

このチュートリアルでは，カメラを起動して画面に映った文字をログに出力するサンプルを説明します．


## 概要
カメラ出力から取得した `CMSampleBuffer` を `EdgeOCR API` の `scan` を実行することで，
画面に映っているテキストを検出・認識します．
検出・認識したテキストはログに出力します．
この例の実装は
`EdgeOCRSample/SimpleText/SimpleTextViewController.swift` と
`EdgeOCRSample/SimpleText/SimpleTextViews.wift`，
`EdgeOCRSample/Main/MainView.swift`
に実装されていますので，ご参考になさってください．


## 最もシンプルな例の実装方法
カメラから送られてくる各フレームごとの画像に対して OCR する箇所について説明します．
`SimpleTextViewController` クラスの `captureOutput(_:didOutput:from:)` にOCRの処理を記述します．
```swift
func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
    do {
        let scanResult = try edgeOCR.scan(sampleBuffer, viewBounds: viewBounds)
        for detection in scanResult.getTextDetections() {
            let text = detection.getText()
            if !text.isEmpty {
                os_log("detected: %@", type: .debug, text)
            }
        }
    } catch {
        os_log("Failed to scan texts: %@", type: .debug, error.localizedDescription)
        return
    }
}
```

`edgeOCR.scan` の呼び出しでは，`sampleBuffer` に加えて，カメラ出力が表示されている画面のサイズ `viewBounds` を引数として渡します．

`edgeOCR.scan` メソッドの戻り値は `ScanResult` オブジェクトです．
このオブジェクトから `getDetections` メソッドで OCR 結果である `Detection` オブジェクトが取得できます．
スキャン範囲内の対象物トのすべてをスキャンするので、複数の `Detection` オブジェクトが返されます。
また、対象物は `useModel` で選択したモデルによってテキスト、バーコード、またはその両方です。
`getDetections` の返す `Detection` オブジェクトを `Text` または `Barcode` にキャストして、それぞれの情報を取得できます。
文字列、またはバーコードのみを取得したい場合は、`getTextDetections` （または `getBarcodeDetections`）を使用してください．

また，カメラの解像度とスキャン範囲は異なっています．
詳しくは [OCR結果を画面に表示する](06-boxes-overlay.md) についてで解説します．

こちらのサンプルでは，`Detection` オブジェクトの中からテキストが空でないものをログに出力しています．


## 次のステップ
次はOCR結果を画面に表示する方法を説明します．

↪️ [OCR結果を画面に表示する](06-boxes-overlay.md)
