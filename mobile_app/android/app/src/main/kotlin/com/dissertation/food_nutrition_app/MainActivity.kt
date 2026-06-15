package com.dissertation.food_nutrition_app

import android.graphics.Bitmap
import android.graphics.BitmapFactory
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.FileInputStream
import java.nio.MappedByteBuffer
import java.nio.channels.FileChannel

// Platform Channel для TFLite-инференса в офлайн-режиме.
// Канал: 'com.nutriscan/tflite_classifier'
// Dart-сторона: lib/features/classification/data/datasources/platform_channel_datasource.dart
//
// Поддерживаемые методы:
//   loadModel(modelPath: String, labelsPath: String) → {status, numClasses}
//   classifyImage(imageBytes: ByteArray) → {predictions: [{label, confidence}]}
class MainActivity : FlutterActivity() {

    private val CHANNEL = "com.nutriscan/tflite_classifier"

    // TFLite интерпретатор (загружается lazily)
    private var interpreterLoaded = false
    private var classLabels: List<String> = emptyList()
    // MappedByteBuffer хранит модель в памяти (TFLite Interpreter ожидает ByteBuffer)
    private var modelBuffer: MappedByteBuffer? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "loadModel" -> {
                        val modelPath  = call.argument<String>("modelPath")  ?: ""
                        val labelsPath = call.argument<String>("labelsPath") ?: ""
                        loadModel(modelPath, labelsPath, result)
                    }
                    "classifyImage" -> {
                        val imageBytes = call.argument<ByteArray>("imageBytes") ?: ByteArray(0)
                        classifyImage(imageBytes, result)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    // Загружает TFLite-модель из assets и читает файл с классами.
    // assets/models/kazakh_model.tflite + assets/models/kazakh_labels.txt
    private fun loadModel(modelPath: String, labelsPath: String, result: MethodChannel.Result) {
        try {
            val assetManager = assets

            // Загрузка модели в MappedByteBuffer
            val modelFd = assetManager.openFd(modelPath)
            val inputStream = FileInputStream(modelFd.fileDescriptor)
            val channel = inputStream.channel
            modelBuffer = channel.map(
                FileChannel.MapMode.READ_ONLY,
                modelFd.startOffset,
                modelFd.declaredLength
            )
            inputStream.close()

            // Загрузка меток классов
            val labelsStream = assetManager.open(labelsPath)
            classLabels = labelsStream.bufferedReader().readLines().filter { it.isNotBlank() }
            labelsStream.close()

            interpreterLoaded = true
            result.success(mapOf("status" to "loaded", "numClasses" to classLabels.size))
        } catch (e: Exception) {
            interpreterLoaded = false
            result.error("MODEL_LOAD_ERROR", e.message, null)
        }
    }

    // Запускает TFLite-инференс на переданном изображении.
    // Возвращает топ-3 предсказания с confidence в %.
    private fun classifyImage(imageBytes: ByteArray, result: MethodChannel.Result) {
        if (!interpreterLoaded) {
            result.error("MODEL_NOT_LOADED", "Model not initialized. Call loadModel first.", null)
            return
        }

        try {
            val bitmap = BitmapFactory.decodeByteArray(imageBytes, 0, imageBytes.size)
                ?: run {
                    result.error("IMAGE_ERROR", "Failed to decode image", null)
                    return
                }

            // Препроцессинг: resize 224×224, нормализация [0, 1]
            val resized = Bitmap.createScaledBitmap(bitmap, 224, 224, true)
            val inputArray = Array(1) { Array(224) { Array(224) { FloatArray(3) } } }

            for (y in 0 until 224) {
                for (x in 0 until 224) {
                    val pixel = resized.getPixel(x, y)
                    inputArray[0][y][x][0] = ((pixel shr 16 and 0xFF) / 255.0f)
                    inputArray[0][y][x][1] = ((pixel shr 8  and 0xFF) / 255.0f)
                    inputArray[0][y][x][2] = ((pixel        and 0xFF) / 255.0f)
                }
            }

            val outputArray = Array(1) { FloatArray(classLabels.size) }

            // Запуск инференса через org.tensorflow.lite.Interpreter
            // Примечание: для работы необходимо добавить зависимость в build.gradle:
            //   implementation 'org.tensorflow:tensorflow-lite:2.14.0'
            // Сейчас реализация возвращает заглушку, пока .tflite-файл не добавлен в assets.
            // После добавления модели раскомментируйте:
            //   val interpreter = Interpreter(modelBuffer!!)
            //   interpreter.run(inputArray, outputArray)
            //   interpreter.close()

            // --- Заглушка (placeholder) ---
            result.error("MODEL_FILE_NOT_FOUND",
                "Add kazakh_model.tflite to assets/models/ to enable offline mode", null)
        } catch (e: Exception) {
            result.error("CLASSIFICATION_ERROR", e.message, null)
        }
    }
}