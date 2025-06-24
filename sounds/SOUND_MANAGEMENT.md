# TimeMinder Sound Management

TimeMinder now includes comprehensive sound management capabilities that allow you to download, store, and organize custom sound files for use as notification sounds.

## Features

### 1. Persistent Sound Storage
- Custom sound selections are automatically saved to `TimeMinder.ini`
- Sound files are stored in the `sounds/` directory
- Settings persist between application restarts

### 2. Sound File Management
- **Download from URL**: Download sound files directly from the internet
- **Select Local File**: Choose existing sound files from your computer
- **Select from Downloaded**: Choose from previously downloaded sound files
- **Copy External Files**: Automatically copy external sound files to the sounds directory

### 3. Supported Audio Formats
- WAV (.wav)
- MP3 (.mp3)
- WMA (.wma)
- AAC (.aac)
- M4A (.m4a)
- FLAC (.flac)

## Hotkeys

### Sound Management
- `Ctrl+Shift+S`: Open sound management menu
- `Ctrl+Shift+I`: Show sound information and status

### Sound Management Menu Options
1. **Select Local File**: Choose a sound file from your computer
2. **Download from URL**: Download a sound file from the internet
3. **Select from Downloaded**: Choose from files in the sounds directory
4. **Clear Custom Sound**: Remove custom sound (use default beep)
5. **Open Sounds Folder**: Open the sounds directory in File Explorer

## File Organization

### Sounds Directory
- Location: `[TimeMinder Directory]/sounds/`
- Automatically created if it doesn't exist
- All downloaded and copied sound files are stored here
- Files are automatically renamed to avoid conflicts

### Configuration File
- Location: `[TimeMinder Directory]/TimeMinder.ini`
- Stores the path to the currently selected custom sound
- Automatically created and updated when sound settings change

## Usage Examples

### Downloading a Sound File
1. Press `Ctrl+Shift+S`
2. Select "Download from URL"
3. Enter the URL of the sound file
4. Wait for download to complete
5. The file will be saved to the sounds directory and set as your custom sound

### Selecting a Local File
1. Press `Ctrl+Shift+S`
2. Select "Select Local File"
3. Choose your sound file
4. Optionally copy it to the sounds directory for better organization
5. The file will be set as your custom sound

### Managing Downloaded Files
1. Press `Ctrl+Shift+S`
2. Select "Select from Downloaded"
3. Choose from the list of available sound files
4. The selected file will be set as your custom sound

### Checking Sound Status
1. Press `Ctrl+Shift+I`
2. View information about your current custom sound
3. See available sound files in the sounds directory
4. Check file sizes and status

## Benefits

### Persistence
- Custom sound settings are saved between restarts
- Sound files are stored locally for reliable access
- No need to re-select sounds after application restart

### Organization
- All sound files are stored in a dedicated directory
- Automatic file naming prevents conflicts
- Easy access to all downloaded sounds

### Reliability
- Files are copied locally to prevent broken links
- Automatic verification of file existence
- Fallback to default beep if custom sound is unavailable

### User-Friendly
- Simple menu-based interface
- Progress indicators for downloads
- Clear status information
- Automatic directory creation

## Technical Details

### File Storage
- Sound files are stored in the `sounds/` subdirectory
- Configuration is stored in `TimeMinder.ini`
- Automatic directory creation on first use

### Error Handling
- Graceful fallback to default beep if custom sound fails
- File existence verification before playback
- Automatic cleanup of invalid file references

### Performance
- Minimal impact on application startup
- Efficient file scanning and management
- Optimized sound file loading

## Troubleshooting

### Custom Sound Not Playing
1. Press `Ctrl+Shift+I` to check sound status
2. Verify the sound file exists and is accessible
3. Check if the file format is supported
4. Try selecting a different sound file

### Download Failures
1. Check your internet connection
2. Verify the URL is correct and accessible
3. Ensure the file is a supported audio format
4. Try downloading from a different source

### Configuration Issues
1. Check if `TimeMinder.ini` exists and is writable
2. Verify the sounds directory exists and is accessible
3. Restart the application to reload configuration
4. Clear and re-set custom sound if needed 