## Demo

<a href="https://github.com/raflizocky/notes-app/blob/main/demo-img/Demo.md">Here</a>

## Features

- **CRUD Notes**: Add, Edit, or Delete notes
- **Search**: Quickly find notes using the search functionality
- **Responsive Design**: Works well on both desktop and mobile devices

## Installation

1. Create a new project at [Supabase](https://supabase.com/).
2. Create a new table at `Table Editor` & fill the column like at `lib/models/note.dart`.
3. Disable `Row Level Security (RLS)` (only at testing) or Add `Policies` to prevent issues.
4. Clone this repository:
   ```shell
   git clone https://github.com/raflizocky/notes-app.git
   ```
5. Navigate to the project directory:

   ```shell
   cd notes-app
   ```

6. Create a new file name `dotenv` & Paste your `Projact URL & API Key` like this:

   ```shell
   SUPABASE_URL=YOUR_PROJECT_URL
   SUPABASE_ANON_KEY=YOUR_API_KEY
   ```

7. Install depedencies:

   ```shell
   flutter pub get
   ```

8. Run the app:
   ```shell
   flutter run
   ```

## Contributing

If you'd like to contribute, please fork the repository and make changes as you'd like. Pull requests are warmly welcome.
