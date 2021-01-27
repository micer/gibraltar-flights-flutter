import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart';

void showAboutDialog({
  @required BuildContext context,
}) {
  assert(context != null);
  showDialog<void>(
    context: context,
    builder: (context) {
      return _AboutDialog();
    },
  );
}

Future<String> getVersionNumber() async {
  final packageInfo = await PackageInfo.fromPlatform();
  return packageInfo.version;
}

class _AboutDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final bodyTextStyle = textTheme.bodyText1.apply(color: Colors.black87);

    final name = 'Gibraltar Flights';
    final madeByText = 'Made in Flutter with ❤️ during 2020/21 pandemic times.';
    final repoLinkText = "source code";
    final privacyLinkText = "privacy policy";
    final mainText =
        "Feel free to check out the source code of this app if you're interested. Mandatory link to privacy policy belongs here too.";
    final repoLinkIndex = mainText.indexOf(repoLinkText);
    final repoLinkIndexEnd = repoLinkIndex + repoLinkText.length;
    final privacyLinkIndex = mainText.indexOf(privacyLinkText);
    final privacyLinkIndexEnd = privacyLinkIndex + privacyLinkText.length;
    final mainTextFirst = mainText.substring(0, repoLinkIndex);
    final mainTextSecond =
        mainText.substring(repoLinkIndexEnd, privacyLinkIndex);
    final mainTextThird = mainText.substring(privacyLinkIndexEnd);

    return AlertDialog(
      backgroundColor: Theme.of(context).primaryColorLight,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      content: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            FutureBuilder(
              future: getVersionNumber(),
              builder: (context, snapshot) => Text(
                snapshot.hasData ? '$name ${snapshot.data}' : '$name',
                style: textTheme.headline6.apply(color: Colors.black87),
              ),
            ),
            const SizedBox(height: 24),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    style: bodyTextStyle,
                    text: mainTextFirst,
                  ),
                  TextSpan(
                    style: bodyTextStyle.copyWith(
                        color: colorScheme.primary,
                        decoration: TextDecoration.underline),
                    text: repoLinkText,
                    recognizer: TapGestureRecognizer()
                      ..onTap = () async {
                        final url =
                            'https://github.com/micer/gibraltar-flights-flutter';
                        if (await canLaunch(url)) {
                          await launch(
                            url,
                            forceSafariVC: false,
                          );
                        }
                      },
                  ),
                  TextSpan(
                    style: bodyTextStyle,
                    text: mainTextSecond,
                  ),
                  TextSpan(
                    style: bodyTextStyle.copyWith(
                        color: colorScheme.primary,
                        decoration: TextDecoration.underline),
                    text: privacyLinkText,
                    recognizer: TapGestureRecognizer()
                      ..onTap = () async {
                        final url =
                            'https://micer.eu/gibflights/privacy_policy.html';
                        if (await canLaunch(url)) {
                          await launch(
                            url,
                            forceSafariVC: false,
                          );
                        }
                      },
                  ),
                  TextSpan(
                    style: bodyTextStyle,
                    text: mainTextThird,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Text(
              madeByText,
              style: bodyTextStyle,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: Text(MaterialLocalizations.of(context).closeButtonLabel),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
