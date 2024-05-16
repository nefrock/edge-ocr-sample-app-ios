# アクティベーション
このチュートリアルではSDKのアクティベーション方法について説明します．


## 概要
ライセンスキーと EdgeOCRSwift の NefrockLicenseAPI を用いて，Nefrock License を有効化 (アクティベーション)します．
アクティベーションの実装は，`EdgeOCRSample/Views/MainView/MainView.swift` と
`EdgeOCRSample/Models/Activation/ActivationModel.swift` に実装されていますので，ご参考になさってください．


## アクティベーション方法
SDK のスキャン機能を使う前に，SDK を使用するデバイスでライセンスのアクティベーションを行う必要があります．
アクティベーションはそのデバイスで初めて SDK を使うときのみ必要です． 
アクティベーションはオンライン環境で行う必要があります．



> [!WARNING] 
> EdgeOCR アプリを削除し再インストールを行うと，再度のアクティベーションが必要になり，別デバイスとして登録されますのでご注意ください．

アクティベーションの実行、アクティベーション状態の確認を行うために、 NefrockLicenseAPI を用います．
```swift
let licenseAPI 
    = try LicenseBuilder().withLicenseKey(licenseKey: "your key").build()
```

`"your key"` の部分にはライセンスキーを入れてください．

アクティベーションを行うには，`activate()` メソッドを呼び出します．
```swift
func activate() async throws -> License
```
- アクティベーションが成功した時には，`License` 構造体が返り値として返されます．
- アクティベーションが失敗した時には，`EdgeError` 例外が投げられます．

一度アクティベーションを行うと，次回以降はアクティベーションを行う必要はありません．
ライセンス情報はファイルに保存されますので，アプリを再起動してもアクティベーションを行う必要はありません．

アクティベーション状態の確認は，`isActivated` で行うことができます．
```swift
func isActivated() async throws -> License
```

ライセンスファイルが存在するか確認を行います．
ファイルが見つからない場合，サーバーに非同期で問い合わせを行います．
デバイスがアクティベーション済みの場合ライセンスファイルが生成されます．
この関数を呼ぶことにより，新しいデバイスとして登録されることはありません．

- アクティベーションの確認が成功した時には，`License` 構造体が返り値として返されます．
- アクティベーションの確認が失敗した時には，`EdgeError` 例外が投げられます．
