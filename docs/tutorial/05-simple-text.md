# 最もシンプルな例

このチュートリアルでは，カメラを起動して画面に映った文字をログに出力するサンプルを説明します．


## 概要
カメラ出力から取得した `CMSampleBuffer` を `EdgeOCR API` の `scanTexts` を実行することで，
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
        let scanResult = try edgeOCR.scanTexts(sampleBuffer, previewViewBounds: previewBounds)
        for detection in scanResult.getTextDetections() {
            let text = detection.getScanObject().getText()
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

`edgeOCR.scanTexts` の呼び出しでは，`sampleBuffer` に加えて，カメラ出力が表示されている画面のサイズ `previewBounds` を引数として渡します．

`edgeOCR.scanTexts` メソッドの戻り値は `ScanResult` オブジェクトです．
このオブジェクトから `getDetections` メソッドで OCR 結果である `Detection` オブジェクトが取得できます． 
スキャン範囲内のテキストのすべてをスキャンするので，複数の `Detection` オブジェクトが返されます．

また，カメラの解像度とスキャン範囲は異なっています．
詳しくは [SDK が解析する画像の範囲](06-boxes-overlay.md) についてで解説します．

`Detection` オブジェクトでは読み取り対象ごとに対応する `ScanObject` オブジェクトが返されます．
`Text` の `ScanObject` から、読み取り結果のテキストを取得できます． 
こちらのサンプルでは，`Detection` オブジェクトの中からテキストが空でないものをログに出力しています．
