# Building the YAZI APK in the cloud (no Mac, no Android Studio)

GitHub builds the app on their machines and gives you an APK to download
on your phone. Free, and nothing needs installing on your laptop.

## One-time setup (about 15 minutes)

1. Go to **github.com** and sign in (create a free account if you don't have one).
2. Click **+** (top right) → **New repository**.
   - Name: `yazi-app`
   - Choose **Private**
   - Do NOT tick "Add a README"
   - Click **Create repository**
3. On the next page click **uploading an existing file**.
4. Open the `yozi_app` folder on your computer, select **everything inside it**
   (including the hidden `.github` folder — see the note below) and drag it into
   the browser window. Wait for all files to finish uploading.
5. Scroll down, click **Commit changes**.

> **The `.github` folder must be included.** It holds the build instructions.
> On Windows: File Explorer → View → tick "Hidden items".
> On Mac: press **Cmd+Shift+.** in Finder to show hidden folders.
> Easiest alternative: drag the `yozi_app` folder itself rather than its contents.

## Building the APK (every time, about 8 minutes)

1. In your repository click the **Actions** tab.
2. Click **Build YAZI APK** on the left.
3. Click **Run workflow** → leave the API address as it is → **Run workflow**.
4. Wait for the green tick.
5. Click into the finished run, scroll to **Artifacts**, and download **YAZI-apk**.
6. Open the downloaded zip, take the `.apk` file, and send it to your phone
   (WhatsApp to yourself, email, or Google Drive).
7. On the phone, tap the file and allow "install from unknown sources" if asked.

## Pointing it at a different server

If the server address ever changes, put the new one in the "Backend API base URL"
box when you press Run workflow. Nothing in the code needs editing.

## If a build fails

Click the failed step to see the red error message and send it over — the log
line is usually enough to tell what went wrong.
