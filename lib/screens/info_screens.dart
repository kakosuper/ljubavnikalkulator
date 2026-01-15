import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../helpers/translate_helper.dart'; // Importujemo naš t() helper
import 'package:lottie/lottie.dart';

// STRANA O APLIKACIJI
class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(t(context, "O aplikaciji")),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
  padding: const EdgeInsets.all(20),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(
        t(context,
          "Ova aplikacija koristi napredne astrološke algoritme i ASCII modulo proračune kako bi odredila kompatibilnost između dve osobe. "
          "Naš cilj je da pružimo zabavan način za istraživanje odnosa kroz numerologiju i astrologiju."
        ),
        style: const TextStyle(fontSize: 16, height: 1.5),
        textAlign: TextAlign.justify,
      ),
      const SizedBox(height: 24),

      // Lottie ispod teksta
      Center(
        child: SizedBox(
          height: 220,
          width: 220,
          child: Lottie.asset(
            'assets/vaga.json',
            fit: BoxFit.contain,
          ),
        ),
      ),
    ],
  ),
),

    );
  }
}

// STRANA KONTAKT
class ContactPage extends StatelessWidget {
  
  // Funkcija za pokretanje mejla
  Future<void> _launchEmail(BuildContext context) async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'kakosuper@gmail.com',
      queryParameters: {
        // I subjekt mejla može biti preveden
        'subject': t(context, 'Ljubavni Kalkulator - Podrška/Predlog')
      },
    );
    
    try {
      if (await canLaunchUrl(emailLaunchUri)) {
        await launchUrl(emailLaunchUri);
      } else {
        throw 'Could not launch $emailLaunchUri';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t(context, "Greška prilikom otvaranja mejl klijenta."))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(t(context, "Kontakt")),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.email_outlined, size: 80, color: Colors.pink[200]),
              SizedBox(height: 30),
              Text(
                t(context, "Imate predlog ili vam je potrebna pomoć?"),
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: () => _launchEmail(context),
                icon: Icon(Icons.send),
                label: Text(t(context, "Kontaktirajte nas putem mejla")),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                  backgroundColor: Colors.pink[50],
                  foregroundColor: Colors.pink,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}