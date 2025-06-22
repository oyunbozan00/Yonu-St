import 'package:flutter/material.dart';

void main() => runApp(YonuSApp());

class YonuSApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yonu-S',
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: Color(0xFFF7F7F7),
        textTheme: TextTheme(bodyMedium: TextStyle(fontSize: 16)),
      ),
      home: StockPage(),
    );
  }
}

class StockModel {
  String name;
  String code;
  int dokulen;
  int boyanan;
  int hazir;
  int verilen;
  int siparis;

  StockModel(this.name, this.code,
      {this.dokulen = 0,
      this.boyanan = 0,
      this.hazir = 0,
      this.verilen = 0,
      this.siparis = 0});

  int get utop => hazir + verilen;
  int get kalanDokum => (siparis - dokulen).clamp(0, siparis);
  int get kalanBoyama => (siparis - boyanan).clamp(0, siparis);

  StockModel clone() => StockModel(name, code,
      dokulen: dokulen,
      boyanan: boyanan,
      hazir: hazir,
      verilen: verilen,
      siparis: siparis);
}

class StockPage extends StatefulWidget {
  @override
  _StockPageState createState() => _StockPageState();
}

class _StockPageState extends State<StockPage> {
  List<StockModel> models = [
    StockModel('Zürafa', 'zü'),
    StockModel('Fil', 'fi'),
  ];

  List<List<StockModel>> history = [];
  int historyIndex = -1;

  void addToHistory() {
    history = history.sublist(0, historyIndex + 1);
    history.add(models.map((m) => m.clone()).toList());
    historyIndex++;
  }

  void applyCommand(String cmd) {
    if (cmd.length < 4) return;
    final code = cmd.substring(0, 2);
    final number = int.tryParse(cmd.substring(2, cmd.length - 1));
    final action = cmd[cmd.length - 1];
    if (number == null) return;

    final model = models.firstWhere((m) => m.code == code, orElse: () => null);
    if (model == null) return;

    setState(() {
      addToHistory();
      switch (action) {
        case 'd':
          model.dokulen += number;
          break;
        case 'b':
          model.boyanan += number;
          model.dokulen -= number;
          break;
        case 'h':
          model.hazir += number;
          model.boyanan -= number;
          break;
        case 'v':
          model.verilen += number;
          model.hazir -= number;
          break;
        case 's':
          model.siparis += number;
          break;
        case 'x':
          final target = cmd[cmd.length - 2];
          switch (target) {
            case 'd':
              model.dokulen -= number;
              break;
            case 'b':
              model.boyanan -= number;
              break;
            case 'h':
              model.hazir -= number;
              break;
            case 'v':
              model.verilen -= number;
              break;
          }
          break;
      }
    });
  }

  void undo() {
    if (historyIndex > 0) {
      setState(() {
        historyIndex--;
        models = history[historyIndex].map((m) => m.clone()).toList();
      });
    }
  }

  void redo() {
    if (historyIndex < history.length - 1) {
      setState(() {
        historyIndex++;
        models = history[historyIndex].map((m) => m.clone()).toList();
      });
    }
  }

  void showQuickAddDialog(StockModel model, String category) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [1, 9, 12].map((value) => ElevatedButton(
          child: Text('+$value'),
          onPressed: () {
            final code = model.code;
            final commandLetter = {
              'dokulen': 'd',
              'boyanan': 'b',
              'hazir': 'h',
              'verilen': 'v',
              'siparis': 's'
            }[category];
            applyCommand('$code${value}$commandLetter');
            Navigator.pop(context);
          },
        )).toList(),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    addToHistory();
  }

  @override
  Widget build(BuildContext context) {
    bool canUndo = historyIndex > 0;
    bool canRedo = historyIndex < history.length - 1;

    return Scaffold(
      appBar: AppBar(
        title: Text("Yonu-S"),
        actions: [
          IconButton(icon: Icon(Icons.undo), onPressed: canUndo ? undo : null),
          IconButton(icon: Icon(Icons.redo), onPressed: canRedo ? redo : null),
        ],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: MaterialStateColor.resolveWith((_) => Colors.grey.shade200),
          dataRowColor: MaterialStateColor.resolveWith((_) => Colors.white),
          columns: [
            DataColumn(label: Text('Dök')), DataColumn(label: Text('Boy')), DataColumn(label: Text('Hazır')),
            DataColumn(label: Text('Ü-Top')), DataColumn(label: Text('Verilen')),
            DataColumn(label: Text('Sipariş')), DataColumn(label: Text('Kalan Döküm')),
            DataColumn(label: Text('Kalan Boyama'))
          ],
          rows: models.map((m) => DataRow(cells: [
            DataCell(GestureDetector(onTap: () => showQuickAddDialog(m, 'dokulen'), child: Text(m.dokulen.toString()))),
            DataCell(GestureDetector(onTap: () => showQuickAddDialog(m, 'boyanan'), child: Text(m.boyanan.toString()))),
            DataCell(GestureDetector(onTap: () => showQuickAddDialog(m, 'hazir'), child: Text(m.hazir.toString()))),
            DataCell(Text(m.utop.toString())),
            DataCell(GestureDetector(onTap: () => showQuickAddDialog(m, 'verilen'), child: Text(m.verilen.toString()))),
            DataCell(GestureDetector(onTap: () => showQuickAddDialog(m, 'siparis'), child: Text(m.siparis.toString()))),
            DataCell(Text(m.kalanDokum.toString())),
            DataCell(Text(m.kalanBoyama.toString())),
          ])).toList(),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Komut gir (ör: zü15d)',
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (val) => applyCommand(val),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
