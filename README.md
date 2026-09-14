# portfolio_flutter

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

# DNS CONFIG
Type	Name	Content
A	@	185.199.108.153
A	@	185.199.109.153
A	@	185.199.110.153
A	@	185.199.111.153
Set Proxy status = DNS only for these.
Then add:
 
Type	Name	Content
CNAME	www	anikshakys.github.io
 
 
# DEPLOYEMNT STEPS


flutter clean
flutter pub get
flutter build web --release --base-href "/"



test flutter run -d chrome

create .github/workflows/deploy.yml

On GitHub:
Repository → Settings → Pages

Under:
Build and deployment → Source
select
GitHub Actions

Then
GitHub → Repository → Actions
1. Actions permissions

Select:

✅ Allow all actions and reusable workflows

2. Require actions to be pinned

Leave:

☐ Require actions to be pinned to a full-length commit SHA