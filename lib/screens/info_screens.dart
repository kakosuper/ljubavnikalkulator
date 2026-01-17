import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../helpers/translate_helper.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';

import 'package:ljubavnikalkulator/ui/ui_tokens.dart';
import 'package:ljubavnikalkulator/widgets/fancy_appbar_title.dart';

// STRANA O APLIKACIJI
class AboutPage extends StatelessWidget {
  Future<void> _openPrivacyPolicy(BuildContext context) async {
    final uri = Uri.parse('https://www.margosdev.com/home/ljubav-i-zvezde');
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok) throw 'Could not launch $uri';
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t(context, "Ne mogu da otvorim Privacy Policy link."))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const FancyAppBarTitle(
          titleKey: "O aplikaciji",
          subtitleKey: "Kako radi • Šta dobijaš",
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: UiTokens.background(context),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: UiTokens.pagePadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Neumorphic(
                  style: NeumorphicStyle(
                    depth: 6,
                    boxShape: NeumorphicBoxShape.roundRect(
                      BorderRadius.circular(UiTokens.cardRadius),
                    ),
                    color: UiTokens.surface(context),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      t(
                        context,
                        "Ova aplikacija koristi napredne astrološke algoritme i ASCII modulo proračune kako bi odredila kompatibilnost između dve osobe. "
                        "Naš cilj je da pružimo zabavan način za istraživanje odnosa kroz numerologiju i astrologiju.",
                      ),
                      style: TextStyle(
                        fontSize: 15.5,
                        height: 1.5,
                        color: UiTokens.textPrimary(context),
                      ),
                      textAlign: TextAlign.justify,
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Lottie ispod teksta (kao "hero" vizual)
                Center(
                  child: Neumorphic(
                    style: NeumorphicStyle(
                      depth: 4,
                      boxShape: NeumorphicBoxShape.roundRect(
                        BorderRadius.circular(UiTokens.cardRadius),
                      ),
                      color: UiTokens.surface(context),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: SizedBox(
                        height: 220,
                        width: 220,
                        child: Lottie.asset(
                          'assets/vaga.json',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // Privacy Policy link
                Neumorphic(
                  style: NeumorphicStyle(
                    depth: 6,
                    boxShape: NeumorphicBoxShape.roundRect(
                      BorderRadius.circular(UiTokens.cardRadius),
                    ),
                    color: UiTokens.surface(context),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          t(context, "Privatnost"),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: UiTokens.textPrimary(context),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          t(
                            context,
                            "Pročitajte kako aplikacija koristi podatke i kako rade reklame.",
                          ),
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.4,
                            color: UiTokens.textSecondary(context),
                          ),
                        ),
                        const SizedBox(height: 12),
                        NeumorphicButton(
                          onPressed: () => _openPrivacyPolicy(context),
                          style: NeumorphicStyle(
                            depth: 4,
                            color: NeumorphicTheme.isUsingDark(context)
                                ? UiTokens.accentPink
                                : Colors.pink[50],
                            boxShape: NeumorphicBoxShape.roundRect(
                              BorderRadius.circular(UiTokens.buttonRadius),
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 14,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.privacy_tip_outlined,
                                size: 18,
                                color: NeumorphicTheme.isUsingDark(context)
                                    ? Colors.white
                                    : UiTokens.accentPink,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                t(context, "Privacy Policy"),
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.2,
                                  color: NeumorphicTheme.isUsingDark(context)
                                      ? Colors.white
                                      : UiTokens.accentPink,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
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
        'subject': t(context, 'Ljubavni Kalkulator - Podrška/Predlog'),
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
        SnackBar(
          content: Text(
            t(context, "Greška prilikom otvaranja mejl klijenta."),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = NeumorphicTheme.isUsingDark(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const FancyAppBarTitle(
          titleKey: "Kontakt",
          subtitleKey: "Pitanja • Predlozi • Podrška",
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: UiTokens.background(context),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: UiTokens.pagePadding,
              child: Neumorphic(
                style: NeumorphicStyle(
                  depth: 6,
                  boxShape: NeumorphicBoxShape.roundRect(
                    BorderRadius.circular(UiTokens.cardRadius),
                  ),
                  color: UiTokens.surface(context),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.email_outlined,
                        size: 76,
                        color: isDark ? Colors.pink[200] : Colors.pink[300],
                      ),
                      const SizedBox(height: 18),
                      Text(
                        t(context, "Imate predlog ili vam je potrebna pomoć?"),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: UiTokens.textPrimary(context),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        t(context, "Pišite nam i odgovorićemo čim stignemo."),
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.4,
                          color: UiTokens.textSecondary(context),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 18),

                      NeumorphicButton(
                        onPressed: () => _launchEmail(context),
                        style: NeumorphicStyle(
                          depth: 4,
                          color: isDark ? UiTokens.accentPink : Colors.pink[50],
                          boxShape: NeumorphicBoxShape.roundRect(
                            BorderRadius.circular(UiTokens.buttonRadius),
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 14,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.send,
                              size: 18,
                              color: isDark ? Colors.white : UiTokens.accentPink,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              t(context, "Kontaktirajte nas putem mejla"),
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.2,
                                color: isDark ? Colors.white : UiTokens.accentPink,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
