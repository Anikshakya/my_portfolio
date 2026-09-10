class Experience {
  final String id, title, company, location, startDate, endDate;
  final bool isCurrent;
  final String description;
  final List<String> achievements;
  final List<String> technologies;

  const Experience({
    required this.id,
    required this.title,
    required this.company,
    required this.location,
    required this.startDate,
    required this.endDate,
    required this.isCurrent,
    required this.description,
    required this.achievements,
    required this.technologies,
  });
}

const List<Experience> experiences = [
  Experience(
    id: 'exp-1',
    title: 'Flutter Developer',
    company: 'Miracle Interface',
    location: 'Kathmandu, Nepal',
    startDate: 'Feb 2023',
    endDate: 'Present',
    isCurrent: true,
    description:
        'Architecting and shipping high-performance cross-platform Flutter applications for international clients in Japan and Nepal.',
    achievements: [
      'Developed and released 7+ production mobile apps on App Store and Google Play.',
      'Implemented In-App Purchase systems, billing, Open Street Maps, Google Maps, offline-first sync, REST APIs, Push Notifications, Deeplinking, and much more.',
      'Engineered specialized native hardware features including NFC My Number Card and QR scanner engines.',
    ],
    technologies: ['Flutter', 'Dart', 'Firebase', 'REST API', 'NFC', 'In-App Purchase', 'Maps', 'Deeplinking', 'Native Platform Channels'],
  ),
  Experience(
    id: 'exp-2',
    title: 'Flutter Trainee',
    company: 'Miracle Interface',
    location: 'Kathmandu, Nepal',
    startDate: 'Aug 2022',
    endDate: 'Feb 2023',
    isCurrent: false,
    description:
        'Strengthened mobile application engineering skills and contributed to commercial client mobile projects.',
    achievements: [
      'Built responsive mobile UIs and reusable component widget libraries.',
      'Integrated Firebase authentication, push notifications, and analytics.',
    ],
    technologies: ['Flutter', 'Dart', 'Firebase', 'GetX', 'Git'],
  ),
  Experience(
    id: 'exp-3',
    title: 'Flutter Intern',
    company: 'Miracle Interface',
    location: 'Kathmandu, Nepal',
    startDate: 'Apr 2022',
    endDate: 'Aug 2022',
    isCurrent: false,
    description:
        'Gained hands-on commercial experience in cross-platform mobile development and Dart fundamental patterns.',
    achievements: [
      'Assisted senior developers in UI bug fixes and feature development.',
      'Mastered Flutter layouts, REST API consumption, and Git version control.',
    ],
    technologies: ['Flutter', 'Dart', 'REST API', 'Git'],
  ),
  Experience(
    id: 'exp-4',
    title: 'Web Intern',
    company: 'YIT',
    location: 'Lalitpur, Nepal',
    startDate: 'Feb 2018',
    endDate: 'Apr 2018',
    isCurrent: false,
    description: 'Gained hands-on experience in Html, Css, JavaScript.',
    achievements: [
      'Web Apps, JavaScript techniques.',
      'Mastered web UI, responsiveness.',
    ],
    technologies: ['Html', 'Css', 'React', 'JavaScript'],
  ),
];
