import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:intl/intl.dart';
import '../services/history_service.dart';
import '../models/history_item.dart';
import '../helpers/translate_helper.dart';

class HistoryPage extends StatefulWidget {
  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<HistoryItem> _history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void _loadHistory() async {
    final data = await HistoryService.getHistory();
    setState(() {
      _history = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeumorphicTheme.baseColor(context),
      body: _history.isEmpty
          ? Center(child: Text(t(context, "Istorija je prazna")))
          : ListView.builder(
              padding: EdgeInsets.all(15),
              itemCount: _history.length,
              itemBuilder: (context, index) {
                final item = _history[index];
                return _buildHistoryCard(item);
              },
            ),
    );
  }

  Widget _buildHistoryCard(HistoryItem item) {
    bool isAdvanced = item.sun1 != null;

    return Neumorphic(
      margin: EdgeInsets.only(bottom: 15),
      style: NeumorphicStyle(
        depth: 4,
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(15)),
      ),
      child: ExpansionTile(
        title: Text(
          "${item.name1} ❤️ ${item.name2}",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.pink),
        ),
        subtitle: Text("${item.score}% - ${DateFormat('dd.MM.yyyy HH:mm').format(item.date)}"),
        trailing: Icon(Icons.keyboard_arrow_down, color: Colors.pink[200]),
        children: [
          Padding(
            padding: EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${t(context, "Rezultat")}: ${item.message}",
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
                if (isAdvanced) ...[
                  Divider(),
                  Text("Astro Podaci:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _astroMiniCol(item.name1, item.sun1, item.asc1, item.moon1),
                      Icon(Icons.auto_awesome, color: Colors.amber, size: 15),
                      _astroMiniCol(item.name2, item.sun2, item.asc2, item.moon2),
                    ],
                  ),
                ]
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _astroMiniCol(String name, String? s, String? a, String? m) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(name, style: TextStyle(fontSize: 10, color: Colors.pink[300])),
        Text("${t(context, "S")}: ${t(context, s ?? "")}", style: TextStyle(fontSize: 11)),
        Text("${t(context, "A")}: ${t(context, a ?? "")}", style: TextStyle(fontSize: 11)),
        Text("${t(context, "M")}: ${t(context, m ?? "")}", style: TextStyle(fontSize: 11)),
      ],
    );
  }
}