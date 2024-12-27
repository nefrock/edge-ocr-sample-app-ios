# マスターデータを用いた OCR (曖昧一致)

このチュートリアルでは，編集距離を用いて一定の誤差を許容して，マスターデータ（ホワイトリスト）から文字を検出する方法を説明いたします．

## 概要

検出結果のテキストをマスターデータに登録されている文字列と比較し，編集距離が一定以下の場合に文字を検出します．
そして，テキストを検出した場合には，ダイアログを表示します．

この例の実装は，
`EdgeOCRSample/Views/EditDistance/EditDistanceViewController.swift` と
`EdgeOCRSample/Views/EditDistance/EditDistanceView.swift`，
`EdgeOCRSample/Views/EditDistance/EditDistanceAnalyzer.swift`，
`EdgeOCRSample/Views/Main/MainView.swift`，
に実装されていますので，ご参考になさってください．

## 編集距離とは

編集距離とは，文字列間の類似度を表す指標の一つです．
編集距離は，一方の文字列をもう一方の文字列に変換するために必要な _挿入_, _削除_, _置換_ の三つの操作の最小回数を表します．

例えば，`kitten` と `sitting` の編集距離は 3 です．
以下のように変換することで，`kitten` を `sitting` に変換することができます．

```
                  kitten
-(k を s に置換)-> sitten
-(e を i に置換)-> sittin
-(g を末尾に挿入)-> sitting
```

詳しくは，[Wikipedia](https://ja.wikipedia.org/wiki/%E7%B7%A8%E9%9B%86%E8%B7%9D%E9%9B%A2) を参照してください．

## マスターデータを用いた OCR (曖昧一致)の実装

`EdgeOCRSample/Views/EditDistance/EditDistanceAnalyzer.swift` に実装されている `EditDistanceAnalyzer` クラスを使用して，検出結果とマスターデータの比較を行います．
その際に，検出結果とマスターデータに含まれている文字列との編集距離を `FuzzySearch` クラスを使用して，一定以下の場合に文字を検出します．

```swift
class FuzzySearchAnalyzer {
    let candidates: [String] = [
        "東京都新宿区",
        "群馬県前橋市",
        "神奈川県横浜市",
        "大阪府中央区",
        "沖縄県那覇市",
        "北海道札幌市",
    ]
    let fuzzySearch = FuzzySearch(FuzzySearch.DistanceType.editDistance)

    init() {
        do {
            try fuzzySearch.loadWeight(FuzzySearch.WeightType.NNDistance)
            try fuzzySearch.loadMasterData(candidates)
        } catch {
            os_log("Failed to load weight or master data: %s", log: .default, type: .error, error.localizedDescription)
        }
    }

    func analyze(_ detections: [Text], minDist: Int) -> AnalyzerResult {
        var targetDetections = [Text]()
        var notTargetDetections = [Text]()

        for detection in detections {
            var targetDetection: Text? = nil
            let text = detection.getText()
            let ret = fuzzySearch.calcSimilarityWithMasterData(text, parallel: true, normalized: false)
            if let ret = ret {
                let (matched, dist) = ret
                if dist <= Double(minDist) {
                    detection.setText(matched)
                    targetDetection = detection
                }
            }
            if let targetDetection = targetDetection {
                targetDetections.append(targetDetection)
            } else {
                notTargetDetections.append(detection)
            }
        }

        return AnalyzerResult(
            targetDetections: targetDetections,
            notTargetDetections: notTargetDetections)
    }
}
```

`FuzzySearch` クラスでは、`loadWeight` メソッドで重みを読み込み，`loadMasterData` メソッドでマスターデータを読み込みます．
そして、`calcSimilarityWithMasterData` メソッドで検出結果とマスターデータの編集距離を計算します．
`loadWeight` メソッドは，`FuzzySearch.WeightType` によって重みを指定します．
使用できる重みは、以下の三つです。

- `FuzzySearch.WeightType.Default`: デフォルトの重み
- `FuzzySearch.WeightType.Disabled`: 重みを使用しません．
- `FuzzySearch.WeightType.NNDistance`: ニューラルネットワークを使用して算出した類似度重み

次に，`EdgeOCRSample/Views/EditDistance/EditDistanceViewController.swift` では，`EditDistanceAnalyzer` クラスを使用して，検出結果とマスターデータの比較を行います．

`targetDetections` にはマスターデータに含まれている `Text` が，`notTargetDetections` には含まれていない `Text` が格納されます．

`targetDetections` は緑色の枠で囲まれたテキストを，`notTargetDetections` は赤色の枠で囲まれたテキストを表示します．

```swift
func drawDetections(result: ScanResult) {
    CATransaction.begin()
    CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
    detectionLayer.sublayers = nil

    // MARK: - 編集距離を許容して，マスターデータ（ホワイトリスト）に検出結果が含まれているかを判定

    let detections = result.getTextDetections()
    let minDist = 1
    let analyzerResult = analyzer.analyze(detections, minDist: minDist)
    var messages: [String] = []
    for targetDetection in analyzerResult.getTargetDetections() {
        let text = targetDetection.getText()
        let bbox = targetDetection.getBoundingBox()
        drawDetection(bbox: bbox, text: text)
        messages.append(text)
    }

    for notTargetDetection in analyzerResult.getNotTargetDetections() {
        let text = notTargetDetection.getText()
        let bbox = notTargetDetection.getBoundingBox()
        drawDetection(bbox: bbox, text: text, boxColor: UIColor.red.withAlphaComponent(0.5).cgColor)
    }

    if messages.count > 0 {
        showDialog = true
        self.messages = messages
    }
    CATransaction.commit()
}
```

## 次のステップ

次は正規表現を用いた曖昧一致について説明します．

↪️ [正規表現を用いた検索（曖昧一致）](15-fuzzy-regex.md)
