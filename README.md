# Crypto Price Chart

A Flutter web application that displays real-time cryptocurrency price charts using the CoinGecko API.

this is an illustration on my blog post: How AI Tools Like Cursor Are Revolutionizing Code Generation

## Features

- Real-time cryptocurrency price tracking
- Interactive line chart with price history
- Multiple time ranges (1 Day, 1 Month, 1 Year)
- Support for multiple cryptocurrencies
- Min/Max price indicators
- Interactive tooltips with price and timestamp
- Dark theme UI

## Screenshots

[Add screenshots of your application here]

## Getting Started

### Prerequisites

- Flutter SDK (latest version)
- Dart SDK (latest version)
- A web browser

### Installation

1. Clone the repository:
bash
git clone [your-repository-url]
cd crypto-price-chart
flutter pub get
flutter run -d chrome


### CORS Configuration

For development purposes, this application uses the CORS Anywhere proxy to handle API requests. Before running the application:

1. Visit https://cors-anywhere.herokuapp.com/corsdemo
2. Request temporary access to the demo server

For production deployment, consider:
- Using CoinGecko's Pro API
- Setting up your own backend proxy server

## Dependencies

- `flutter`: Flutter SDK
- `http`: ^1.1.0 - For making HTTP requests
- `fl_chart`: ^0.65.0 - For rendering interactive charts
- `intl`: ^0.18.0 - For date formatting

## Project Structure
lib/
├── main.dart
├── screens/
│ └── crypto_chart_screen.dart
├── services/
│ └── crypto_service.dart
└── widgets/
└── duration_button.dart