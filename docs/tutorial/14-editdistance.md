# マスターデータを用いたOCR (曖昧一致)

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
編集距離は，一方の文字列をもう一方の文字列に変換するために必要な *挿入*, *削除*, *置換* の三つの操作の最小回数を表します．

例えば，`kitten` と `sitting` の編集距離は3です．
以下のように変換することで，`kitten` を `sitting` に変換することができます．
```
                  kitten
-(k を s に置換)-> sitten
-(e を i に置換)-> sittin
-(g を末尾に挿入)-> sitting
```

詳しくは，[Wikipedia](https://ja.wikipedia.org/wiki/%E7%B7%A8%E9%9B%86%E8%B7%9D%E9%9B%A2) を参照してください．


## マスターデータを用いたOCR (曖昧一致)の実装
`EdgeOCRSample/Views/EditDistance/EditDistanceAnalyzer.swift` に実装されている `EditDistanceAnalyzer` クラスを使用して，検出結果とマスターデータの比較を行います．
その際に，検出結果とマスターデータに含まれている文字列との編集距離を計算し，一定以下の場合に文字を検出します．

```swift
class EditDistanceAnalyzer {
    let candidates: Set = [
        "東京都新宿区",
        "群馬県前橋市",
        "神奈川県横浜市",
        "大阪府中央区",
        "沖縄県那覇市",
        "北海道札幌市",
    ]

    init() {}

    // 二つの文字列の編集距離を計算
    private static func editDistance(_ s0: String, s1: String) -> Int {
        var matrix = [[Int]](repeating: [Int](repeating: 0, count: s1.count + 1), count: s0.count + 1)
        for i in 0...s0.count {
            matrix[i][0] = i
        }
        for j in 0...s1.count {
            matrix[0][j] = j
        }
        for i in 1...s0.count {
            for j in 1...s1.count {
                let cost = s0[s0.index(s0.startIndex, offsetBy: i - 1)] == s1[s1.index(s1.startIndex, offsetBy: j - 1)] ? 0 : 1
                matrix[i][j] = min(matrix[i - 1][j] + 1, matrix[i][j - 1] + 1, matrix[i - 1][j - 1] + cost)
            }
        }
        return matrix[s0.count][s1.count]
    }

    func analyze(_ detections: [Text], minDist: Int) -> AnalyzerResult {
        var targetDetections = [Text]()
        var notTargetDetections = [Text]()

        for detection in detections {
            for candidate in candidates {
                let text = detection.getText()
                var dist = minDist + 1
                if !text.isEmpty {
                    dist = EditDistanceAnalyzer.editDistance(text, s1: candidate)
                }
                if dist <= minDist {
                    detection.setText(candidate)
                    targetDetections.append(detection)
                } else {
                    notTargetDetections.append(detection)
                }
            }
        }

        return AnalyzerResult(
            targetDetections: targetDetections,
            notTargetDetections: notTargetDetections)
    }
}
```

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
