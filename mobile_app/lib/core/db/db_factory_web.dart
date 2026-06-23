import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

// Для веба sqflite не работает напрямую — подключаем WASM-движок.
// NoWebWorker: вариант без отдельного worker-потока. Обычный databaseFactoryFfiWeb
// ломается при заходе НЕ через localhost (открытый баг пакета: воркер не отвечает,
// "unsupported result null") — именно так получает доступ телефон по IP в локальной сети.
void initDatabaseFactory() {
  databaseFactory = databaseFactoryFfiWebNoWebWorker;
}
