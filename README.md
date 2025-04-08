# CurrencyTrackerApp
💱 Currency Tracker App

A modern SwiftUI iOS app that tracks real-time exchange rates for a personalized list of currencies. Users can search, add, and remove currencies from their board. The app supports offline caching, automatic updates, and smooth animations.

---

📲 Features

- 🔍 Search and add currencies to track
- 📉 Live exchange rate updates (every 5 seconds)
- ⚡ Offline support using cached data
- ✅ Select and deselect currencies easily
- 🔄 Pull-to-refresh support
- 📦 Clean MVVM architecture
- 🧪 Unit & UI test coverage
- 🎨 Animated placeholder views when no data

---

📡 API

This app uses the Open Exchange Rates API (https://openexchangerates.org) for all currency data.

🔗 Endpoints used:

- GET https://openexchangerates.org/api/latest.json  
  Docs: https://docs.openexchangerates.org/reference/latest-json

- GET https://openexchangerates.org/api/currencies.json  
  Docs: https://docs.openexchangerates.org/reference/currencies-json

---

🔐 API Key

You must create a free account and get your API key from https://openexchangerates.org/signup.

Replace the existing key inside CurrencyAPIService.swift:

private let appId = "YOUR_API_KEY_HERE"

---

🛠 Tech Stack

- Swift 5.9
- SwiftUI
- Combine
- Network.framework
- MVVM Architecture
- XCTest & XCUITest

---

🧪 Running Tests

To run unit and UI tests:

⌘ + U

Or select the test target and press Run.

---

📦 Installation

1. Clone the repo  
   git clone https://github.com/your-username/currency-tracker-app.git

2. Open in Xcode  
   open CurrencyTrackerApp.xcodeproj

3. Add your API key to CurrencyAPIService.swift

4. Build and run on simulator or device.

---

📄 License

This project is open source and available under the MIT License.

---

🙌 Contributing

Contributions are welcome! Open a pull request or issue and let's improve the app together.
