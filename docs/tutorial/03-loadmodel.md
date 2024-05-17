# モデル選択とロード
このチュートリアルでは，モデルの選択とロード方法について説明いたします．


## 概要
EdgeOCRVisionAPI を用いて，モデルをロードします．
モデルのアスペクト比を用いて．OCR結果の描画範囲を決定するため．OCR画面に遷移する前にモデルのロードを行うことを推奨します．
本サンプルアプリでは `MainView.swift` で，各サンプル　ViewController　への遷移前にモデルのロードを行っています．


## モデルのロード方法
サンプルアプリでは，`Models/LoadModel/LoadModel.swift/func loadModel(path:) async -> String?` と `Views/Main/MainView.swift` でモデルのロードを行っています．

```swift
func loadModel(
    path: String,
    modelSettings: EdgeOCRSwift.ModelSettings = ModelSettings()
) async throws -> ModelInformation? {
    let modelPath = Bundle.main.path(forResource: path, ofType: "")
    guard let modelPath = modelPath else {
        throw EdgeError.notFound(description: "Not found models at given the path: \(path)")
    }

    let edgeOCR = try ModelBuilder().fromPath(modelPath).build()
    var model: Model?
    for candidate in edgeOCR.availableModels() {
        os_log("model candidate: %@", candidate.getUID())
        if candidate.getUID() == "model-d320x320" {
            model = candidate
        }
    }

    guard let model = model else {
        throw EdgeError.notFound(description: "Not found model-d320x320 model")
    }

    let modelInfo = try await edgeOCR.useModel(model, settings: modelSettings)
    os_log("model: %@", type: .debug, "\(model)")
    return modelInfo
}
```

`loadModel` では `edgeOCR.useModel` を使用して，モデルをロードします．
`edgeOCR.useModel` の第1引数には、`Model` を指定します．
SDK のデフォルトでは `model-d256x64`， `model-d256x128`, `model-d320x160`, ``model-d320x320`, `model-d640x640` が指定できます．
`model-d640x640` は `model-d320x320` に比べて高精度のモデルで，OCRに時間がかかります．
ユースケースやデバイスのスペックに合わせてどのモデルを使うかを選択していただけます．
また，カスタマイズしたモデルを利用する場合もこちらで指定を行います．
また `edgeOCR.useModel` の第2引数には、`ModelSettings` を指定することができます．
`ModelSettings` では，モデルパラメータの設定や，検出結果のフィルタ設定，`TextMapper` の設定を行うことができます．

バーコード読み取りのみを利用する場合は，モデルロードの必要はありません．


```swift
// モデルのロードと画面遷移
func loadModelAndNavigate(destination: EdgeOCRSampleKind, modelSettings: ModelSettings = ModelSettings()) {
    /* モデルをロード */
    Task {
        isLoading = true
        do {
            let info = try await loadModel(path: modelPath, modelSettings: modelSettings)
            aspectRatio = info!.getAspectRatio()
            /* 画面遷移 */
            path.append(destination)
        } catch {
            showModelAlert = true
            modelAlertContent = "失敗\n" + error.localizedDescription
        }
        isLoading = false
    }
}

...
    // MARK: - 最もシンプルな例の実装

    Button(action: {
        loadModelAndNavigate(destination: .mostSimpleView)
    }) {
        Text("最もシンプルな例")
    }
...
```

サンプルアプリでは，`loadModelAndNavigate` 関数を用いて，遷移先（上記の場合では，`SimpleTextView()`）が表示されるときにモデルをロードしています．


## GPU を使用するモデルのロードにかかる時間について
GPU を使用するモデルは，初回のロード時のみロード時間が数秒かかります． 
この時間はローエンドのデバイスほど時間がかかる傾向にあります．
ただし 2 回目以降のロードは高速に処理され，アプリを削除しない限りはロードに数秒かかることはありません．


## 次のステップ
次はカメラの設定の方法を説明します．

↪️ [カメラの設定](04-setup-camera.md)
