# テキストの複数回読み取りで精度を上げる

このチュートリアルでは，OCRの精度を上げるために，複数回連続で同じテキストを読み込んだかを判定する方法を説明いたします．


## 概要
`ModelSettings` 構造体の `nToConfirm` に連続で同じテキストを読み取る回数を指定します．
そして，`scanTexts` メソッドの返り値の `ScanObject` の `ScanConfirmationStatus` を確認することで，
連続で同じテキストを読み取ったかを判定することができます．

この例の実装は 
`EdgeOCRSample/Views/NTimes/NtimesViewController.swift` と　
`EdgeOCRSample/Views/NTimes/NtimesView.swift`，
`EdgeOCRSample/Views/Main/MainView.swift`，
に実装されていますので，ご参考になさってください．


## テキストの複数回読み取り実装方法
`EdgeOCRSample/Views/Main/MainView.swift` で読み取り回数の設定を行います．
読み取り回数の設定は `ModelSettings` 構造体の `nToConfirm` によって，設定します．
読み取り回数を設定した `ModelSettings` 構造体を `EdgeVisionAPI` のメソッド `useModel` に引数として渡すことで，
読み取り回数を設定したOCRを行うことができます．


5回同じ内容を読み取った場合にテキストを確定するように設定しています．
デフォルトのテキストの読み取り確定までの回数は1回です．
```swift 
// MARK: - 複数回読み取り
Button(action: {
    /* 5回読み取ったら確定 */
    let modelSettings = ModelSettings(nToConfirm: 5)
    loadModelAndNavigate(destination: .nTimesScanView)
}) {
    Text("複数回読み取り")
}
```

`EdgeOCRSample/Views/NTimes/NtimesViewController.swift` において，
読み取り結果のフィルタリングを行っています．
`getStatus()` メソッドの返り値の `ScanConfirmationStatus` が `Confirmed` か
どうかで読み取り結果が確定しているかどうかを判定しています．
```swift
// MARK: - テキストが連続して読み取られたか確認

if status == ScanConfirmationStatus.Confirmed {
    if text.wholeMatch(of: regex) != nil {
        let bbox = detection.getBoundingBox()
        drawDetection(bbox: bbox, text: text)
    } else {
        let bbox = detection.getBoundingBox()
        drawDetection(
            bbox: bbox,
            text: text,
            boxColor: UIColor.red.withAlphaComponent(0.5).cgColor)
    }
}
```


## TextMapperの設定
複数回読み取りを行う間に、手ブレやカメラの移動などによって読み取り範囲が変化してしまうと、
読み取り結果が異なってしまい、読み取り回数のカウントがリセットされてしまいます．
そこで、以前の結果と読み取り結果を比較する前に `TextMapper` を用いて読み取り結果を正規化することで、読み取り範囲の変化による影響を軽減することができます．
`TextMapper` クラスを継承し、`apply` メソッドを実装することで、TextMapperを作成します．
読み取り対象が郵便番号なので、英字や記号を数字に変換する処理を実装しています．
また、郵便番号のみを抽出するための正規表現も実装しています．

```swift
class PostcodeTextMapper: TextMapper {
    // 郵便番号に一致する正規表現を作成する
    let regex = /^\D*(\d{3})-(\d{4})\D*$/

    override func map(_ text: Text) -> String {
        var t = text.getText()
        t = t.replacingOccurrences(of: "A", with: "4")
        t = t.replacingOccurrences(of: "A", with: "4")
        t = t.replacingOccurrences(of: "B", with: "8")
        t = t.replacingOccurrences(of: "b", with: "6")
        t = t.replacingOccurrences(of: "C", with: "0")
        t = t.replacingOccurrences(of: "D", with: "0")
        t = t.replacingOccurrences(of: "G", with: "6")
        t = t.replacingOccurrences(of: "g", with: "9")
        t = t.replacingOccurrences(of: "I", with: "1")
        t = t.replacingOccurrences(of: "i", with: "1")
        t = t.replacingOccurrences(of: "l", with: "1")
        t = t.replacingOccurrences(of: "O", with: "0")
        t = t.replacingOccurrences(of: "o", with: "0")
        t = t.replacingOccurrences(of: "Q", with: "0")
        t = t.replacingOccurrences(of: "q", with: "9")
        t = t.replacingOccurrences(of: "S", with: "5")
        t = t.replacingOccurrences(of: "s", with: "5")
        t = t.replacingOccurrences(of: "U", with: "0")
        t = t.replacingOccurrences(of: "Z", with: "2")
        t = t.replacingOccurrences(of: "z", with: "2")
        t = t.replacingOccurrences(of: "/", with: "1")

        if let match = t.wholeMatch(of: regex) {
            t = String(match.1) + "-" + String(match.2)
        }
        return t
    }
}

```

作成した `TextMapper` を`setTectMapper` メソッドを用いて設定します．

```swift
// MARK: - 複数回読み取り
Button(action: {
    /* 5回読み取ったら確定 */
    let modelSettings = ModelSettings(nToConfirm: 5)
    /* 郵便番号のテキストマッパーを設定 */
    modelSettings.setTextMapper(PostcodeTextMapper())
    loadModelAndNavigate(destination: .nTimesScanView)
}) {
    Text("複数回読み取り")
}
```
