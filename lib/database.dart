import 'package:drift/drift.dart';
import 'package:drift/wasm.dart'; // Web専用（アプリで使うとエラーになるので注意）
part 'database.g.dart'; // ファイル名.g.dart

class Todos extends Table{
  IntColumn get id => integer().autoIncrement()(); // ID
  TextColumn get content => text()(); // 内容
  // TextColumn get content => text().withLength(min: 12, max: 48)();
  DateTimeColumn get createDatetime => dateTime()(); // 作成日時
  // DateTimeColumn get createDatetime => dateTime().nullable()();
}

@DriftDatabase(tables: [Todos])
class Database extends _$Database {
  Database._(QueryExecutor e) : super(e);
  factory Database() => Database._(connectOnWeb());
  @override
  int get schemaVersion => 1;

  Future insertTodo(String content,DateTime createDatetime) {
    return into(todos).insert(TodosCompanion.insert(content: content, createDatetime: createDatetime));
  }

  Future deleteTodo(int id) {
    return (delete(todos)..where((todo) => todo.id.equals(id))).go();
  }

  Future updateTodo(int id, String content) {
    return (update(todos)..where((todo) => todo.id.equals(id)))
        .write(TodosCompanion(content: Value(content)));
  }  

  Stream<List<Todo>> watchEntries() {
    return (select(todos)).watch();
  }
}

DatabaseConnection connectOnWeb() { // DBコネクト(Web用)
  return DatabaseConnection.delayed(Future(() async {
    final result = await WasmDatabase.open(
      databaseName: 'todos_db',
      sqlite3Uri: Uri.parse('sqlite3.wasm'),
      driftWorkerUri: Uri.parse('drift_worker.js'),
    );

    if (result.missingFeatures.isNotEmpty) {
      print('Using ${result.chosenImplementation} due to missing browser '
          'features: ${result.missingFeatures}');
    }

    return result.resolvedExecutor;
  }));
}





