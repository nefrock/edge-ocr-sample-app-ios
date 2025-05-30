//
//  MainView.swift
//  EdgeOCRSample
//
//  Created by kikemori on 2024/02/22.
//

import Foundation
import SwiftUI

import enum EdgeOCRSwift.BarcodeFormat
import class EdgeOCRSwift.EdgeOCR
import struct EdgeOCRSwift.ModelSettings

enum EdgeOCRSampleKind: Hashable {
    case mostSimpleView
    case boxesOverlayView
    case feedbackView
    case cropView
    case detectionFilterView
    case nTimesScanView
    case barcodeView
    case textImageView
    case barcodeImageView
    case whiteListView
    case fuzzySearchView
    case fuzzyRegexView
    case DPMView
}

struct MainView: View {
    @State var path = NavigationPath()

    // 読み込みインディケータ
    @State var isLoading: Bool = false

    // アクティベーションアラート
    @State var isActivated: Bool = false
    @State var showActivationAlert: Bool = false
    @State var activationAlertContent: String = ""

    // モデル読み込みアラート
    @State var showModelAlert: Bool = false
    @State var modelAlertContent: String = ""

    // モデルディレクトリのパス
    @State var aspectRatio = 1.0
    let modelPath = ""
    let licenseKey = ""

    // モデルのロードと画面遷移
    func loadModelAndNavigate(
        destination: EdgeOCRSampleKind,
        uid: String = "model-d320x320",
        modelSettings: ModelSettings = ModelSettings(),
        experimental: Bool = false
    ) {
        /* モデルをロード */
        Task {
            isLoading = true
            do {
                let info = try await loadModel(
                    path: modelPath, uid: uid, modelSettings: modelSettings,
                    experimental: experimental)
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

    // アクティベーション
    func tryActivation() {
        Task {
            isLoading = true
            if let errorMessage = await activate(key: licenseKey) {
                isLoading = false
                isActivated = false
                showActivationAlert = true
                activationAlertContent = "失敗\n" + errorMessage
            } else {
                isLoading = false
                isActivated = true
            }
        }
    }

    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                List {
                    Section {
                        // MARK: - 最もシンプルな例の実装

                        Button(action: {
                            loadModelAndNavigate(destination: .mostSimpleView)
                        }) {
                            Text("最もシンプルな例")
                        }

                        // MARK: - OCR結果を表示させる例の実装

                        Button(action: {
                            loadModelAndNavigate(destination: .boxesOverlayView)
                        }) {
                            Text("OCR結果を表示させる")
                        }

                        // MARK: - 範囲を指定してOCRする例の実装

                        Button(action: {
                            loadModelAndNavigate(destination: .cropView)
                        }) {
                            Text("範囲を指定してOCR")
                        }

                        // MARK: 検出結果をフィルタリングする例の実装

                        Button(action: {
                            var modelSettings = ModelSettings()
                            modelSettings.setDetectionFilter(CenterDetectionFilter())
                            loadModelAndNavigate(
                                destination: .detectionFilterView, modelSettings: modelSettings)
                        }) {
                            Text("検出結果をフィルタリング")
                        }

                        // MARK: - 複数回読み取りする例の実装

                        Button(action: {
                            /* 5回読み取ったら確定 */
                            var modelSettings = ModelSettings(textNToConfirm: 5)
                            /* 郵便番号のテキストマッパーを設定 */
                            modelSettings.setTextMapper(PostcodeTextMapper())
                            loadModelAndNavigate(
                                destination: .nTimesScanView, modelSettings: modelSettings)
                        }) {
                            Text("複数回読み取り")
                        }

                        // MARK: バーコード読み取りの例の実装

                        Button(action: {
                            // *QRCodeの複数回読み取りを設定する*
                            let barcodeFormats = [BarcodeFormat.QRCode: 5]
                            let modelSettings = ModelSettings(barcodeNToConfirm: barcodeFormats)
                            loadModelAndNavigate(
                                destination: .barcodeView, uid: "edgeocr_barcode_default",
                                modelSettings: modelSettings)
                        }) {
                            Text("バーコード読み取り")
                        }

                        // MARK: - フィードバック送信の例の実装

                        Button(action: {
                            loadModelAndNavigate(destination: .feedbackView)
                        }) {
                            Text("フィードバック送信")
                        }

                        // MARK: - テキスト画像読み取りの例の実装

                        Button(action: {
                            loadModelAndNavigate(destination: .textImageView)
                        }) {
                            Text("テキスト画像読み取り")
                        }

                        // MARK: - バーコード画像読み取りの例の実装

                        Button(action: {
                            loadModelAndNavigate(
                                destination: .barcodeImageView,
                                uid: "edgeocr_barcode_default")
                        }) {
                            Text("バーコード画像読み取り")
                        }

                        // MARK: - マスターデータを用いたOCR (完全一致)の例の実装

                        Button(action: {
                            loadModelAndNavigate(destination: .whiteListView)
                        }) {
                            Text("マスターデータを用いたOCR (完全一致)")
                        }

                        // MARK: - マスターデータを用いたOCR (曖昧一致)の例の実装

                        Button(action: {
                            loadModelAndNavigate(destination: .fuzzySearchView)
                        }) {
                            Text("マスターデータを用いたOCR (曖昧一致)")
                        }

                        // MARK: - 正規表現を用いたOCR (曖昧一致)の例の実装

                        Button(action: {
                            loadModelAndNavigate(destination: .fuzzyRegexView)
                        }) {
                            Text("正規表現を用いたOCR (曖昧一致)")
                        }

                        // MARK: - AI を用いたDPMコードの読み取り（Optional）

                        Button(action: {
                            loadModelAndNavigate(
                                destination: .DPMView, uid: "barcode_dpm", experimental: true)
                        }) {
                            Text("AI を用いたDPMコードの読み取り（Optional）")
                        }
                    }

                    Section {
                        // MARK: - アクティベーション

                        Button(isActivated ? "アクティベーション済み" : "アクティベーションされていません") {
                            tryActivation()
                        }
                        .foregroundColor(isActivated ? .blue : .red)
                        .alert(isPresented: $showActivationAlert) {
                            Alert(
                                title: Text("アクティベーション"),
                                message: Text(activationAlertContent))
                        }
                    }
                }
                .alert(isPresented: $showModelAlert) {
                    Alert(
                        title: Text("モデル読み込み"),
                        message: Text(modelAlertContent))
                }
                .navigationTitle("EdgeOCR Sample")
                .navigationDestination(for: EdgeOCRSampleKind.self) { value in
                    switch value {
                    case .mostSimpleView:
                        SimpleTextView()
                    case .boxesOverlayView:
                        BoxesOverlayView(aspectRatio: $aspectRatio)
                    case .feedbackView:
                        FeedbackView()
                    case .cropView:
                        CropView()
                    case .detectionFilterView:
                        DetectionFilterView(aspectRatio: $aspectRatio)
                    case .nTimesScanView:
                        NTimesScanView(aspectRatio: $aspectRatio)
                    case .barcodeView:
                        BarcodeView(aspectRatio: $aspectRatio)
                    case .textImageView:
                        TextImageView()
                    case .barcodeImageView:
                        BarcodeImageView()
                    case .whiteListView:
                        WhiteListView(aspectRatio: $aspectRatio)
                    case .fuzzySearchView:
                        FuzzySearchView(aspectRatio: $aspectRatio)
                    case .fuzzyRegexView:
                        FuzzyRegexView(aspectRatio: $aspectRatio)
                    case .DPMView:
                        DPMView(aspectRatio: $aspectRatio)
                    }
                }

                /* Show an indicator when checking a license */
                if isLoading {
                    ProgressView("Loading now...")
                        .progressViewStyle(.circular)
                        .padding()
                        .tint(Color.white)
                        .background(Color.gray)
                        .cornerRadius(8)
                        .scaleEffect(1.2)
                }
            }
        }
        .navigationViewStyle(.stack)
        .onAppear {
            // MARK: - アクティベーション

            tryActivation()
        }
    }
}

#Preview {
    MainView()
}
