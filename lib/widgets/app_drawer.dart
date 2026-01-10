import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/language_provider.dart'; // Import provajdera za jezik
import '../screens/info_screens.dart';
import '../helpers/translate_helper.dart'; // Import t() funkcije

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Slušamo promene jezika kako bi se Drawer odmah osvežio
    final langProvider = Provider.of<LanguageProvider>(context);

    return Drawer(
      backgroundColor: NeumorphicTheme.baseColor(context),
      child: Column(
        children: [
          // Zaglavlje Drawera
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: Colors.pink[100]),
            accountName: Text(
              t(context, "Ljubavni Kalkulator"),
              style: TextStyle(color: Colors.pink[900], fontWeight: FontWeight.bold),
            ),
            accountEmail: Text(
              t(context, "Verzija 1.0.0"),
              style: TextStyle(color: Colors.pink[700]),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.favorite, color: Colors.pink, size: 40),
            ),
          ),

          // PODEŠAVANJE PISMA (Ćirilica / Latinica)
          _drawerItem(
            icon: Icons.language,
            text: t(context, "Pismo (Ćirilica / Latinica)"),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(t(context, "Izaberi pismo")),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        title: Text("Latinica"),
                        onTap: () {
                          langProvider.setScript(ScriptType.latinica);
                          Navigator.pop(context);
                        },
                      ),
                      ListTile(
                        title: Text("Ћирилица"),
                        onTap: () {
                          langProvider.setScript(ScriptType.cirilica);
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // TEMA APLIKACIJE
          _drawerItem(
            icon: Icons.brightness_6,
            text: t(context, "Promeni temu"),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(t(context, "Izaberi temu")),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        title: Text(t(context, "Svetla")),
                        onTap: () {
                          Provider.of<ThemeProvider>(context, listen: false).setTheme(ThemeMode.light);
                          Navigator.pop(context);
                        },
                      ),
                      ListTile(
                        title: Text(t(context, "Tamna")),
                        onTap: () {
                          Provider.of<ThemeProvider>(context, listen: false).setTheme(ThemeMode.dark);
                          Navigator.pop(context);
                        },
                      ),
                      ListTile(
                        title: Text(t(context, "Sistemska")),
                        onTap: () {
                          Provider.of<ThemeProvider>(context, listen: false).setTheme(ThemeMode.system);
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // NOTIFIKACIJE
          _drawerItem(
            icon: Icons.notifications_active,
            text: t(context, "Podešavanja notifikacija"),
            onTap: () {
              // Ovde će ići logika za notifikacije
            },
          ),

          Divider(height: 30, thickness: 1),

          // O APLIKACIJI
          _drawerItem(
            icon: Icons.info,
            text: t(context, "O aplikaciji"),
            onTap: () {
              Navigator.pop(context); // Zatvori Drawer pre navigacije
              Navigator.push(context, MaterialPageRoute(builder: (context) => AboutPage()));
            },
          ),

          // KONTAKT
          _drawerItem(
            icon: Icons.email,
            text: t(context, "Kontakt"),
            onTap: () {
              Navigator.pop(context); // Zatvori Drawer pre navigacije
              Navigator.push(context, MaterialPageRoute(builder: (context) => ContactPage()));
            },
          ),

          Spacer(),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Text(
              t(context, "Napravljeno sa ❤️"),
              style: TextStyle(color: Colors.grey),
            ),
          )
        ],
      ),
    );
  }

  Widget _drawerItem({required IconData icon, required String text, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.pink[400]),
      title: Text(text),
      onTap: onTap,
    );
  }
}