/// Specifies the environment the app is running in.
///
/// - [dev]: Development environment for testing and debugging.
/// - [prod]: Production environment for live deployment.
enum AppMode { dev, prod }

/// Specifies the platform where the survey will be launched.
///
/// - [inApp]: Surveys are displayed within the app interface using flutter classes.
/// - [web]: Surveys are opened in a webview.
enum SurveyPlatform { inApp, webView }

/// Specifies how the survey UI is presented to the user.
///
/// - [dialog]: Displays the survey in a modal dialog box.
/// - [bottomSheetModal]: Displays the survey in a draggable bottom sheet.
/// - [fullScreen]: Displays the survey in a full-screen view.
enum SurveyDisplayMode { dialog, bottomSheetModal, fullScreen }
