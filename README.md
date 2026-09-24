# Artex

Artex is a mobile application for sharing art, ideas, and multimedia content, designed to connect artists and enthusiasts through visual, auditory, and written experiences.

[click here to download the app](app-release.apk)

---

## Key Features

### Authentication and Onboarding

* **Automatic Language Detection:** Configures automatically based on the device's system language (supporting English, Portuguese, and Spanish) with manual selection available on the authentication screen.
* **Customized Registration:** Account creation using email, password, and username. Optional profile picture (defaults to the first letter of the username) and biographic description.
* **Persistent Session:** Keeps users logged in automatically without requiring re-authentication upon opening the app.

---

## Main Structure and Navigation

The application is organized into three main screens accessible via a persistent bottom navigation bar:

### 1. User Panel (Left Screen)

* **Created Pieces and Drafts:** Quick access to published artworks and pieces currently under development.
* **Create New Piece:** Direct shortcut to the creation flow.
* **Profile Management:** Options to update username, profile picture, description, and application language.
* **Account Settings:** Options to update email, change password, return to login, and delete the account.
* **Friends Network:** Access to the friends list and friend requests management panel.

### 2. Main Dashboard (Middle Screen)

* **Currently Watching:** Displays the 5 pieces currently being watched by the user, with a "See More" button to view full watch history.
* **Liked Pieces:** Direct access button to view all pieces liked by the user.
* **Top 3 Most Liked Pieces:** Highlights the top 3 pieces on the platform decorated with custom **Gold**, **Silver**, and **Bronze** borders, with a "See More" button to explore full rankings.
* **Favorite Artists:** Dedicated section to view and follow preferred creators.

### 3. Explore and Discovery (Right Screen)

* **Personalized Recommendations:** Feed generated based on user likes, watch history, and favorite artists.
* **Multi-Criteria Search:** Search bar filtering by piece title, author name, and content type.
* **Category Filters:**
* **All / Picture**
* **Audio:** Optional filter by duration time interval.
* **Text:** Optional filter by estimated reading time in minutes.



---

## Content Presentation and Interaction

* **Art Piece Cards:** Displays author details (name and profile picture), title, brief description, like button with counter, view/watching counter, and edit/delete options (visible only to the item's author).
* **Author Cards:** Displays profile name, profile picture, and total accumulated likes.
* **Piece Detail Screen:**
* Full display of the artwork content.
* Header featuring the author card (navigates directly to the user's profile when tapped).
* Comments section with smooth rounded borders and timestamps.
* **Dynamic Translation:** Button to translate text into the selected app language or revert to the original language.
* **Audio/Text Accessibility:** Text-to-speech audio reader for text pieces, or text displaying for audio pieces.



---

## Content Creation and Editing

* **Supported Formats:** Choose between Image, Audio, or Text.
* **Integrated Capture Tools:** In-app audio recording, camera photo capture, and text editor.
* **File Upload and Smart Conversion:**
* Support for uploading local files.
* **Image-to-Text OCR:** Automatic text converter for uploaded images or inline image placement within text blocks.



---

## Technologies Used

* **Framework:** Flutter (Dart)
* **Authentication & Database:** Firebase Auth & Cloud Firestore
* **State Management:** Riverpod
* **Internationalization:** i18n (English, Portuguese, Spanish)