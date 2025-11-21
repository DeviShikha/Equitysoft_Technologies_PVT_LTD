weatherapp

Short description: A simple Flutter weather app that shows current weather and a 5-day forecast for a searched city or the device's current location.

How to run

Clone: git clone <https://github.com/DeviShikha/Equitysoft_Technologies_PVT_LTD/tree/main>

Enter folder: cd weatherapp

Install packages: flutter pub get

Provide API key: create a file lib/constants.dart (see API keys section).

Run: flutter run (or open in Android Studio / VS Code)

API keys

This app uses a weather REST API (for example: OpenWeatherMap).

Create an account on the API provider, get your API key, then add it as shown:

Option A (simple): open lib/constants.dart and set const String WEATHER_API_KEY = '5df4bd3e31ad4aa901a707c4c45402af';


Implementation overview

Screens

Home — Search city input, shows current weather card and small forecast.

Details — Detailed weather info, hourly/5-day forecast.

Settings — Units (Celsius/Fahrenheit), theme, and saved cities.

State management

Provider for app-level state (current weather, selected city, preferences).

Data & Backend

Fetches data from a REST API using http.

Uses shared_preferences to save user preferences and last-searched city.

Location

Uses geolocator to get device location (with permission handling).

Key packages

http — API calls

provider — State management

geolocator — Device location & permissions

shared_preferences — Local simple storage

Key features implemented

Search weather by city name.

Get current location weather (with permission prompts).

Show current weather with temperature, humidity, wind speed, and icon.

5-day forecast list.

Save preferred units (C/F) locally.

Challenges & fixes

Challenge 1: Location permission denied

Problem: App crashed or couldn't fetch location when user denied permissions.

Fix: Added permission checks with friendly UI prompt and fallback to search by city.

Challenge 2: API rate limits / failed responses

Problem: API sometimes returns errors or no data.

Fix: Implemented error handling and retry; show user-friendly message when data is unavailable and use cached last-known data if present.

Challenge 3: Responsive UI on small/large screens

Problem: Layout looked cramped on small phones.

Fix: Used LayoutBuilder/Flexible/MediaQuery and percentage paddings to adapt layout.

Notes

Excluded files: .keystore, build/, /android/app/*.keystore (do not commit sensitive keys)

Add .gitignore to avoid committing build/, .env, and secret files.

If API requires paid plan, include instructions to use mock data or sample key.