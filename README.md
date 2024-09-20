# Google Calendar Integration with Rails

## Overview

This Rails application integrates with the Google Calendar API to provide seamless calendar and event management. Users can authenticate with Google, view and manage their calendars, and synchronize events between Google Calendar and the Rails application. The application also handles Google Calendar notifications to keep events updated automatically.

## Features

- **Google Authentication**: Users can log in using their Google account.
- **Calendar Management**: View and manage Google calendars and their events.
- **Event Synchronization**: Automatically sync events between Google Calendar and the application.
- **Webhooks**: Receive notifications from Google Calendar to keep events up-to-date.

## Repository

For the complete codebase, please visit the GitHub repository: [GoogleCalenderSync](https://github.com/mtmubeentahir/GoogleCalenderSync)

## Getting Started

### Prerequisites

- Ruby 3.0.0 or later
- Rails 7.0.0 or later
- PostgreSQL or another supported database
- A Google Cloud project with the Calendar API enabled

### Installation

1. **Clone the Repository**

    ```bash
    git clone https://github.com/mtmubeentahir/GoogleCalenderSync.git
    cd GoogleCalenderSync
    ```

2. **Install Dependencies**

    ```bash
    bundle install
    ```

3. **Set Up the Database**

    ```bash
    rails db:create
    rails db:migrate
    ```

4. **Configure Environment Variables**

    Create a `.env` file or use your preferred method to set the following environment variables:

    ```env
    GOOGLE_CLIENT_ID=your_client_id
    GOOGLE_CLIENT_SECRET=your_client_secret
    GOOGLE_REDIRECT_URI=your_redirect_uri
    ```

5. **Start the Rails Server**

    ```bash
    rails server
    ```

6. **Access the Application**

    Open your browser and navigate to `http://localhost:3000` to use the application.

## Usage

### Authentication

- **Log In**: Go to `/auth/google` to authenticate with your Google account.
- **Log Out**: Navigate to `/logout` to log out and clear your session.

### Calendar and Event Management

- **View Calendars**: Access `/calendars` to view your Google calendars and events.

## Testing

To run the tests for the application, execute:

```bash
bundle exec rspec
