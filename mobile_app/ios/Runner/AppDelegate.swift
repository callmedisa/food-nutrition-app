import Flutter
import UIKit

// Platform Channel для TFLite-инференса на iOS (офлайн-режим).
// Канал: 'com.nutriscan/tflite_classifier'
// Dart-сторона: lib/features/classification/data/datasources/platform_channel_datasource.dart
//
// Для полной работы TFLite добавьте в Podfile:
//   pod 'TensorFlowLiteSwift', '~> 2.14'
// И добавьте файл модели: ios/Runner/Assets/kazakh_model.tflite

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {

    private let channelName = "com.nutriscan/tflite_classifier"
    private var modelLoaded = false
    private var classLabels: [String] = []

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        let controller = window?.rootViewController as? FlutterViewController
        if let controller = controller {
            let channel = FlutterMethodChannel(
                name: channelName,
                binaryMessenger: controller.binaryMessenger
            )
            channel.setMethodCallHandler { [weak self] call, result in
                switch call.method {
                case "loadModel":
                    guard let args = call.arguments as? [String: Any],
                          let modelPath  = args["modelPath"]  as? String,
                          let labelsPath = args["labelsPath"] as? String else {
                        result(FlutterError(code: "INVALID_ARGS", message: "Missing arguments", details: nil))
                        return
                    }
                    self?.loadModel(modelPath: modelPath, labelsPath: labelsPath, result: result)

                case "classifyImage":
                    guard let args = call.arguments as? [String: Any],
                          let imageData = args["imageBytes"] as? FlutterStandardTypedData else {
                        result(FlutterError(code: "INVALID_ARGS", message: "Missing image bytes", details: nil))
                        return
                    }
                    self?.classifyImage(imageData: imageData.data, result: result)

                default:
                    result(FlutterMethodNotImplemented)
                }
            }
        }

        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    // Загружает TFLite-модель из Bundle и читает файл с метками классов.
    private func loadModel(modelPath: String, labelsPath: String, result: FlutterResult) {
        // Проверяем наличие файла модели в Bundle
        let modelName = (modelPath as NSString).deletingPathExtension
        guard let modelURL = Bundle.main.url(forResource: modelName, withExtension: "tflite") else {
            result(FlutterError(
                code: "MODEL_FILE_NOT_FOUND",
                message: "Add \(modelPath) to ios/Runner/ to enable offline mode",
                details: nil
            ))
            return
        }

        // Загрузка меток классов
        let labelsName = (labelsPath as NSString).deletingPathExtension
        if let labelsURL = Bundle.main.url(forResource: labelsName, withExtension: "txt"),
           let labelsContent = try? String(contentsOf: labelsURL) {
            classLabels = labelsContent
                .components(separatedBy: .newlines)
                .filter { !$0.isEmpty }
        }

        // Инициализация TFLite Interpreter
        // Примечание: для работы необходим пакет TensorFlowLiteSwift (Podfile).
        // После добавления пода раскомментируйте:
        //   do {
        //       let interpreter = try Interpreter(modelPath: modelURL.path)
        //       try interpreter.allocateTensors()
        //       self.interpreter = interpreter
        //       self.modelLoaded = true
        //       result(["status": "loaded", "numClasses": self.classLabels.count])
        //   } catch {
        //       result(FlutterError(code: "MODEL_LOAD_ERROR", message: error.localizedDescription, details: nil))
        //   }

        // --- Заглушка (model file found, but interpreter not linked) ---
        modelLoaded = true
        result(["status": "loaded", "numClasses": classLabels.count])
    }

    // Запускает TFLite-инференс на изображении и возвращает топ-3 предсказания.
    private func classifyImage(imageData: Data, result: FlutterResult) {
        guard modelLoaded else {
            result(FlutterError(code: "MODEL_NOT_LOADED", message: "Call loadModel first", details: nil))
            return
        }

        guard UIImage(data: imageData) != nil else {
            result(FlutterError(code: "IMAGE_ERROR", message: "Failed to decode image", details: nil))
            return
        }

        // Препроцессинг: resize 224×224, нормализация [0, 1]
        // После добавления TensorFlowLiteSwift pod раскомментируйте полный инференс.
        //
        // var inputTensor = try interpreter.input(at: 0)
        // ... (resize image → FloatArray 1×224×224×3, run, get output)

        result(FlutterError(
            code: "MODEL_FILE_NOT_FOUND",
            message: "Add kazakh_model.tflite to ios/Runner/ and link TensorFlowLiteSwift pod",
            details: nil
        ))
    }
}