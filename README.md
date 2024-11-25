# Clipboard Manager

A lightweight, user-friendly clipboard manager written in PowerShell that allows you to track and manage your clipboard history.

![image](https://github.com/user-attachments/assets/cb062938-e476-43e7-9ad0-12f8d54ea9ef)


## Features

- Real-time clipboard monitoring
- Clean, modern UI using Windows Forms
- Pin application to stay on top of other windows
- Copy history management
- Right-click context menu with additional options
- View full text of lengthy clipboard entries
- Notification system for copy operations

## Key Functions

- **Copy Selected**: Copy any historical clipboard entry back to the clipboard
- **Clear History**: Remove all clipboard entries and clear the current clipboard
- **View Full Text**: Open lengthy clipboard entries in a separate window for better visibility
- **Remove Entry**: Delete individual entries from the history (except the most recent one)
- **Pin Application**: Keep the window on top of other applications

## Technical Details

- Written in PowerShell with Windows Forms
- Uses System.Windows.Forms, System.Drawing, and PresentationFramework assemblies
- Implements strict mode for better error handling
- Features responsive UI with hover effects and modern styling
- Automatically manages system resources with proper cleanup on exit
