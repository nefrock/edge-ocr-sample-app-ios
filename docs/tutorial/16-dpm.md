# AI を用いた DPM コードの読み取り（Optional）

このチュートリアルでは、DPM（Direct Part Marking）コードの読み取りについて説明します.

## 概要

AI を使用して DPM コードを読み取ることができます.

この機能の実装例は、以下のファイルに記載されていますので、ご参照ください.
- `EdgeOCRSample/Views/DPM/DPMViewController.swift`
- `EdgeOCRSample/Views/DPM/DPMView.swift`

> [!CAUTION]
> AI を用いた DPM コードの読み取りには、`barcode_dpm` モデルを使用します.
> お使いのモデルに以下のファイルが含まれていることを確認してください.
> * `composite/barcode_dpm.json`
> * `detector/barcode_dpm.bin`
> * `detector/barcode_dpm.json` 
> * `recognizer/barcode_dpm.bin`
> * `recognizer/barcode_dpm.json`


## AI を用いた DPM コードの読み取りの実装方法
`EdgeOCRSample/Views/Main/MainView.swift` で DPM コード読み取り用の AI モデルを選択します.
DPM コード読み取り用の AI は現在 experimental なモデルであるため、`loadModelAndNavigate` メソッドの `experimental` 引数を `true` に設定してください.

> [!IMPORTANT]
> DPM 読み取り用の AI モデルは、現在 experimental なモデルです.
> `EdgeOCRSample/Models/LoadModel/LoadModel.swift` で `edgeOCR.availableModelsWithExperimental()` を使用して、experimental なモデルも含めた利用可能なモデル一覧を取得してください.
> ```swift
> let allModels = experimental ? edgeOCR.availableModelsWithExperimental() : edgeOCR.availableModels()
> for candidate in allModels {
>     os_log("model candidate: %@", candidate.getUID())
>     if candidate.getUID() == uid {
>         model = candidate
>     }
> }
> ```

```swift
// MARK: - AI を用いた DPM コードの読み取り（Optional）

Button(action: {
    loadModelAndNavigate(destination: .DPMView, uid: "barcode_dpm", experimental: true)
}) {
    Text("AI を用いた DPM コードの読み取り（Optional）")
}
```

`EdgeOCRSample/Views/DPM/DPMViewController.swift` で DPM コードのスキャンを実行しています.
`useModel` で DPM コードを読み取れるモデルを選択し、OCR の場合と同様に `scan` メソッドを使用して DPM コードをスキャンします.

```swift
func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
    let scanResult: ScanResult
    do {
        scanResult = try edgeOCR.scan(sampleBuffer, viewBounds: viewBounds)
    } catch {
        os_log("Failed to scan texts: %@", type: .debug, error.localizedDescription)
        return
    }

    DispatchQueue.main.async { [weak self] in
        self?.drawDetections(result: scanResult)
    }
}
```

## DPM コードとテキストのスキャンを同時に実行する方法
DPM コードとテキストを同時にスキャンしたい場合は、モデルディレクトリに `composite/hybrid_dpm_text.json` を追加し、以下のように設定してください.

```json
{
  "type": "Hybrid",
  "barcodeDetectorUid": "barcode_dpm",
  "barcodeRecognizerUid": "barcode_dpm",
  "textDetectorUid": "detector-d320x320",
  "textRecognizerUid": "recognizer"
}
```

モデルディレクトリに `composite/hybrid_dpm_text.json` を追加した後、`EdgeOCRSample/Views/Main/MainView.swift` の `loadModelAndNavigate` メソッドの `uid` パラメーターに `hybrid_dpm_text` を指定してください.

```swift
// MARK: - AI を用いた DPM コードの読み取り（Optional）

Button(action: {
    loadModelAndNavigate(destination: .DPMView, uid: "hybrid_dpm_text", experimental: true)
}) {
    Text("AI を用いた DPM コードの読み取り（Optional）")
}
``` 

これにより、DPM コードとテキストを同時にスキャンできるようになります.
