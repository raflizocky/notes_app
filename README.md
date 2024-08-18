# Notes App

A simple note-taking app built with Flutter and Supabase.

## Demo

<a href="https://github.com/raflizocky/notes_app/blob/main/demo-img/Demo.md">View Demo Images</a>

## Stack

- Flutter
- Supabase

## Features

- **Note Management**: Create, edit, and delete notes.
- **Category Management**: Add, edit, and delete categories.
- **Search**: Search notes by title or description.

## Installation

1. Database

   - New project
   - Create notes & categories table
   - Disable `RLS`/add `Policies` on your own
   - Get Project `URL` & `API Key`

2. Terminal

   - ```shell
     git clone https://github.com/raflizocky/notes-app.git
     ```
   - ```shell
     code notes-app
     ```

3. `dotenv`

   ```shell
   SUPABASE_URL=YOUR_PROJECT_URL
   SUPABASE_ANON_KEY=YOUR_API_KEY
   ```

4. Terminal
   ```shell
   flutter pub get ; flutter run
   ```

## Usage

- .apk
  ```shell
  flutter build apk --release
  ```
