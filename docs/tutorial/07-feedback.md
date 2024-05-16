# 読み取れない画像のフィードバック

弊社のEdgeOCRは、日々の学習と進化を続け、最高の性能を提供するよう努力しています．
現場で読み取れない画像やテキストに出会った場合、
ぜひそれらの情報を弊社のサーバーにフィードバックしていただけると幸いです．
お客様からのフィードバックを受けて、我々はより優れたOCRエンジンを開発し、
次回のリリースで読み取れなかったテキストや画像に対処する可能性が高まります．
皆様の貴重なフィードバックをお待ちしております．


## 概要

フィードバックを送信するには `reportImage`　というメソッドを使用します．
```swift 
public func reportImage(_ image: CMSampleBuffer, userMessage: String, previewViewBounds: CGRect) throws -> ScanResult
```

メソッドを実行すると画像に対してスキャンが行われ，画像と結果が弊社のサーバーに送信されます．
`userMessage` は任意記述になります．
画像を撮影した状況などを記述していただけると助かります．

この例の実装は 
`EdgeOCRSample/Views/Feedback/FeedbackViewController.swift` と
`EdgeOCRSample/Views/Feedback/FeedbackView.swift` ，
`EdgeOCRSample/Views/Main/MainView.swift` 
に実装されていますので，ご参考になさってください．


## 画像のフィードバックの実装方法

app/src/main/java/com/nefrock/edgeocr_example/report/ReportScannerActivity.java に、ボタンを押すと現在の画面をフィードバックする機能を実装しています．
ご自身のアプリに組み込む場合は、こちらのコードを参考にしてください．
```swift
func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
    // MARK: - フィードバックの送信

    if sendFlag {
        do {
            let _ = try edgeOCR.reportImage(
                sampleBuffer,
                userMessage: "",
                previewViewBounds: previewBounds)
            Task { @MainActor in
                sendFlag = false
            }
        } catch {
            os_log("Failed to scan texts: %@", type: .debug, error.localizedDescription)
            return
        }
    }
}
```
