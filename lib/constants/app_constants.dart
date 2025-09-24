import 'package:flutter/material.dart';
import 'package:musice/models/station.dart';

// Window
const Size kWindowSize = Size(390, 844);

// Colors
const Color kSeedColor = Color(0xFFF65500);
const Color kPrimaryColor = Color(0xFFF65500);
const Color kOnPrimaryColor = Colors.white;
const Color kSecondaryColor = Color(0x00000090);
const Color kBackgroundColor = Color(0xFF0B0B0D);
const Color kScaffoldBackgroundColor = Color(0xFF0B0B0D);
const Color kIconColor = Colors.white70;
const Color kDividerColor = Colors.white24;
const Color kBorderColor = Colors.white24;

// Durations
const Duration kSplashDuration = Duration(milliseconds: 1200);
const Duration kReactionDuration = Duration(milliseconds: 900);
const Duration kAnimationDuration = Duration(milliseconds: 180);
const Duration kWaveAnimDuration = Duration(seconds: 2);

// App Info
const String kAppName = 'Musice';
const String kAppVersion = '1.0.0';
const String kCopyright = 'imbrickiy © 2025';

// Stations
const List<Station> kStations = [
  Station('Deep', 'https://hls-01-radiorecord.hostingradio.ru/record-deep/playlist.m3u8'),
  Station('Chill-Out', 'https://hls-01-radiorecord.hostingradio.ru/record-chil/playlist.m3u8'),
  Station('Ambient', 'https://hls-01-radiorecord.hostingradio.ru/record-ambient/playlist.m3u8'),
  Station('Power Deep', 'https://listen.powerapp.com.tr/powerdeep/abr/playlist.m3u8'),
  Station('Business FM SPb', 'https://bfmreg.hostingradio.ru/spb.bfm128.mp3'),
  Station('Business FM', 'https://bfm.hostingradio.ru/bfm256.mp3'),
];

// UI
const double kDefaultPadding = 16.0;
const double kDefaultRadius = 16.0;

// Sheet
const double kSheetHandleWidth = 36.0;
const double kSheetHandleHeight = 4.0;
const double kSheetHandleRadius = 2.0;
const EdgeInsets kSheetPadding = EdgeInsets.only(top: 8, bottom: 12);
const EdgeInsets kSheetTitlePadding = EdgeInsets.symmetric(vertical: 12);
const TextStyle kSheetTitleTextStyle = TextStyle(color: kIconColor, fontSize: 16, fontWeight: FontWeight.w500);
const Color kSheetDividerColor = Colors.white12;
const TextStyle kSheetListTileTextStyle = TextStyle(color: Colors.white);

// Header
const double kHeaderHPad = 20.0;
const double kHeaderVPad = 20.0;
const double kHeaderTitleFontSize = 20.0;
const FontWeight kHeaderTitleFontWeight = FontWeight.w400;
const double kHeaderButtonSize = 56.0;
const double kHeaderIconSize = 28.0;

// Play section
const double kPlayOuterSize = 240.0;
const double kPlayInnerSize = 140.0;
const double kPlayIconSize = 64.0;
const double kLoaderSize = 28.0;
const double kPlayBorderWidth = 1.0;
const Color kPlayBorderColor = kBorderColor;
const int kWaveCount = 3;
const double kWaveStrokeWidth = 1.0;
const Color kWaveColor = Colors.white;

// Volume section
const double kVolumeSectionBottomPadding = 40.0;
const double kVolumeControlHeight = 140.0;
const double kVolumeLabelFontSize = 13.0;
const double kVolumeLabelLetterSpacing = 4.0;
const FontWeight kVolumeLabelFontWeight = FontWeight.w400;
const double kSliderTrackHeight = 3.0;
const Color kSliderActiveTrackColor = Colors.white;
const Color kSliderInactiveTrackColor = Colors.white54;
const Color kSliderThumbColor = Colors.transparent;
const Color kSliderOverlayColor = Colors.white24;

