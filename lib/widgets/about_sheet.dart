import 'package:flutter/material.dart';
import 'package:musice/constants/app_constants.dart';

class AboutSheet extends StatelessWidget {
  final String appName;
  final String version;
  const AboutSheet({super.key, required this.appName, required this.version});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          kDefaultPadding,
          kDefaultPadding,
          kDefaultPadding,
          kDefaultPadding,
        ),
        child: Container(
          padding: const EdgeInsets.all(kDefaultPadding),
          decoration: kSheetContainerDecoration,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text(
                'Слушайте любимые станции и управляйте громкостью в реальном времени.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  kCopyright,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white54,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  '$appName v$version',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white54,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
