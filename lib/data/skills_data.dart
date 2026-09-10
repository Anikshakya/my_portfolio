import 'package:flutter/material.dart';

class Skill {
  final String id, name, category, levelLabel, description;
  final double level;
  final Color color;
  final List<String> tags;

  const Skill({
    required this.id,
    required this.name,
    required this.category,
    required this.level,
    required this.levelLabel,
    required this.color,
    required this.description,
    required this.tags,
  });
}

const Color hudCyan = Color(0xFF00F0FF);
const Color hudMagenta = Color(0xFFFF007F);
const Color hudAmber = Color(0xFFFFAA00);
const Color hudGreen = Color(0xFF00FF66);

const List<String> skillCategories = [
  'All Skills',
  'Mobile & Frameworks',
  'State & Architecture',
  'Backend & APIs',
  'Native & Integrations',
  'DevOps & Tools',
];

const List<Skill> allSkills = [
  Skill(
    id: 'flutter-sdk',
    name: 'Flutter SDK',
    category: 'Mobile & Frameworks',
    level: 0.95,
    levelLabel: 'Expert',
    color: hudCyan,
    description: 'Cross-platform iOS & Android engineering, custom UI & responsive layouts.',
    tags: ['iOS', 'Android', 'Web', 'Dart 3'],
  ),
  Skill(
    id: 'dart-language',
    name: 'Dart Language',
    category: 'Mobile & Frameworks',
    level: 0.92,
    levelLabel: 'Expert',
    color: hudCyan,
    description: 'Asynchronous programming, Streams, Isolates, Null Safety, OOP mastery.',
    tags: ['Async/Await', 'Streams', 'Generics', 'Null Safety'],
  ),
  Skill(
    id: 'clean-arch',
    name: 'Clean Architecture & MVVM',
    category: 'State & Architecture',
    level: 0.88,
    levelLabel: 'Advanced',
    color: hudMagenta,
    description: 'Decoupled domain, data, and presentation layers for maintainable codebases.',
    tags: ['SOLID', 'Dependency Injection', 'Repository Pattern', 'GetIt'],
  ),
  Skill(
    id: 'getx-provider',
    name: 'GetX / Provider',
    category: 'State & Architecture',
    level: 0.85,
    levelLabel: 'Advanced',
    color: hudMagenta,
    description: 'Lightweight state management, route management, and dependency injection.',
    tags: ['GetX', 'Provider', 'Dependency Injection'],
  ),
  Skill(
    id: 'firebase-suite',
    name: 'Firebase Suite',
    category: 'Backend & APIs',
    level: 0.88,
    levelLabel: 'Advanced',
    color: hudAmber,
    description: 'Firestore, Auth, Cloud Messaging (FCM), Crashlytics, and Remote Config.',
    tags: ['FCM', 'Firestore', 'Auth', 'Analytics'],
  ),
  Skill(
    id: 'rest-apis',
    name: 'REST APIs & Networking',
    category: 'Backend & APIs',
    level: 0.90,
    levelLabel: 'Expert',
    color: hudGreen,
    description: 'HTTP / Dio client, JSON serialization, Interceptors, error handling.',
    tags: ['Dio', 'JSON Parsing', 'JWT Auth', 'WebSockets'],
  ),
  Skill(
    id: 'local-storage',
    name: 'Local Storage & Databases',
    category: 'Backend & APIs',
    level: 0.82,
    levelLabel: 'Advanced',
    color: hudCyan,
    description: 'Offline-first data caching with Hive, Shared Preferences, and SQLite.',
    tags: ['SharedPreferences', 'SQLite', 'Get Storage'],
  ),
  Skill(
    id: 'payments',
    name: 'In-App Subscriptions & Payments',
    category: 'Native & Integrations',
    level: 0.85,
    levelLabel: 'Advanced',
    color: hudGreen,
    description: 'App Store & Play Store subscription engines, gifting systems, and receipt validation.',
    tags: ['In-App Purchase', 'Subscriptions'],
  ),
  Skill(
    id: 'qr-scanning',
    name: 'QR Scanning & Loyalty Rewards',
    category: 'Native & Integrations',
    level: 0.88,
    levelLabel: 'Advanced',
    color: hudAmber,
    description: 'Bulk product scanning, warranty verification, and loyalty point calculators.',
    tags: ['QR Code', 'Camera Engine'],
  ),
  Skill(
    id: 'maps-geo',
    name: 'Maps & Geo-Data Services',
    category: 'Native & Integrations',
    level: 0.82,
    levelLabel: 'Advanced',
    color: hudCyan,
    description: 'Location services, property geo-data valuation, and public facility search.',
    tags: ['Google Maps', 'Geolocation', 'Geo-Data Matrix'],
  ),
  Skill(
    id: 'deployment',
    name: 'App Store & Play Store Deployment',
    category: 'DevOps & Tools',
    level: 0.90,
    levelLabel: 'Expert',
    color: hudGreen,
    description: 'Full lifecycle release management on Google Play Store & Apple App Store.',
    tags: ['App Store Connect', 'Play Console', 'Release Lifecycle'],
  ),
  Skill(
    id: 'git-control',
    name: 'Git & Version Control',
    category: 'DevOps & Tools',
    level: 0.88,
    levelLabel: 'Advanced',
    color: hudMagenta,
    description: 'Branching strategies (GitFlow), pull requests, code reviews, and versioning.',
    tags: ['Git', 'GitHub', 'Code Reviews', 'GitFlow'],
  ),
  Skill(
    id: 'push-i18n',
    name: 'Push Notifications & i18n',
    category: 'DevOps & Tools',
    level: 0.85,
    levelLabel: 'Advanced',
    color: hudAmber,
    description: 'Real-time notification feeds, disaster alerts, and multi-language internationalization.',
    tags: ['Push Alerts', 'i18n Localization', 'Bilingual UI'],
  ),
];
