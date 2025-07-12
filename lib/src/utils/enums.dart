/// Specifies the application environment mode.
/// - [dev]: Used for development and testing.
/// - [prod]: Used for production deployment.
enum AppMode { dev, prod }

/// Defines how a survey should be displayed in the UI.
/// - [dialog]: Shows the survey in a standard alert dialog.
/// - [bottomSheetModal]: Shows the survey as a bottom sheet modal.
/// - [fullScreen]: Displays the survey using a full-screen takeover.
enum SurveyDisplayMode { dialog, bottomSheetModal, fullScreen }

/// Represents the type of trigger that initiates a survey or form.
/// - [noCode]: Triggered via configuration (no code required).
/// - [code]: Triggered programmatically in code.
enum TriggerType { noCode, code }
