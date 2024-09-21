# TimeTracker App

## Usage

**Home Screen:**
- Displays a grid of activity categories.
- Each category shows an associated icon, the category name, and the number of hours spent on that activity.
- Tap on a category to add or update the hours spent on it.

**Add Category:**
- Tap the "+" button to create a new category.
- You can assign a name and select an icon from a predefined set of icons.

**Track Hours:**
- For each category, tap to input the number of hours spent on that activity.
- The hours are saved and displayed under the category.

**Save Daily Log:**
- At the bottom of the screen, press "Save Daily Log" to store the day's activity.
- This resets the tracked hours for the next day, but the data is saved in the history.

**View History:**
- Tap the clock icon in the app bar to view a list of daily logs.
- The history shows the date and how many hours were spent on each activity.

**Persistence:**
- The app automatically saves categories, hours, and history using `SharedPreferences`, so the data remains even when the app is closed.
