import 'package:flutter/material.dart';
import './database.dart';
import 'package:intl/intl.dart'; // ロケール。日時表示で使う。

final db = Database();

void main() {
  final list = Expanded(
    child: StreamBuilder(
      stream: db.watchEntries(),
      builder:
          (BuildContext context, AsyncSnapshot<List<Todo>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // snapshot.data![i].カラム名 では長いので
        List<Todo>  tl = snapshot.data ?? [];
        
        return ListView.builder(        
          itemCount: snapshot.data!.length,
          itemBuilder: (context, i) => ListTile(
            leading: const Icon(Icons.person),
            title: Text(tl[i].content),
            //DateFormat df = DateFormat('yyyy-MM-dd HH:mm:ss');
            subtitle: Text( 
              "[ID:${tl[i].id}] ${DateFormat('yyyy-MM-dd HH:mm:ss').format(tl[i].createDatetime)}" 
            ),
            trailing:  Wrap(
              spacing: 5, // アイコンの間の幅を調整
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () async {
                    await db.updateTodo(tl[i].id,
                      '更新'
                    );
                  },
                ), 
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () async { // 削除なので、本来は「確認ダイアログ」を挟む
                    await db.deleteTodo(tl[i].id);
                  },
                ),
              ],
            ),
            tileColor: Colors.purple[50], // アイテムの背景色
          ),
        );
      },
    ),
  );

  final addButton = ElevatedButton(
    child: const Text('追加'),
    onPressed: () async {
      await db.insertTodo(
        '追加', DateTime.now()
      );
    },
  );

  final body = SafeArea( // ボディー
    child: Column(
      children: [
        list,
        addButton,
      ],
    )
  );

  final sc = Scaffold(
    body: body, // ボディー
  );

  final app = MaterialApp(home: sc);
  runApp(app);
}
