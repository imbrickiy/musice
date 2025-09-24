import 'package:flutter/material.dart';
import 'package:musice/models/station.dart';

// Window
const Size kWindowSize = Size(390, 844);

// Colors
const Color kSeedColor = Color(0xFF7C4DFF);
const Color kScaffoldBackgroundColor = Color(0xFF0B0B0D);
const Color kIconColor = Colors.white70;
const Color kDividerColor = Colors.white24;
const Color kBorderColor = Colors.white24;

// Durations
const Duration kSplashDuration = Duration(milliseconds: 1200);
const Duration kReactionDuration = Duration(milliseconds: 900);
const Duration kAnimationDuration = Duration(milliseconds: 180);

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
