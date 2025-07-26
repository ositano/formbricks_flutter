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


/// Represents the type of question presented in a survey.
///
/// - [freeText]: A freeform single-line text field.
/// - [openText]: A multi-line open-ended text field.
/// - [multipleChoiceSingle]: A single-select multiple choice question.
/// - [multipleChoiceMulti]: A multi-select multiple choice question.
/// - [pictureSelection]: A question where users select from images.
/// - [rating]: A standard rating scale (e.g., 1–5 stars).
/// - [nps]: Net Promoter Score scale (e.g., 0–10).
/// - [ranking]: Users reorder items by priority.
/// - [matrix]: A grid of options for multiple sub-questions.
/// - [consent]: A consent checkbox or agreement.
/// - [fileUpload]: Allows the user to upload a file.
/// - [date]: A date picker input.
/// - [cal]: A calendar input (potentially richer than `date`).
/// - [address]: An address form input.
/// - [contactInfo]: A form for collecting contact details (name, email, phone).
/// - [cta]: A call-to-action button question type.
/// - [unSupportedType]: Placeholder for unsupported or unknown question types.
enum QuestionType {
  freeText,
  openText,
  multipleChoiceSingle,
  multipleChoiceMulti,
  pictureSelection,
  rating,
  nps,
  ranking,
  matrix,
  consent,
  fileUpload,
  date,
  cal,
  address,
  contactInfo,
  cta,
  unSupportedType,
}


/// Specifies the action a logic rule should take when triggered.
///
/// - [jumpToQuestion]: Jumps to a specific question ID.
/// - [requireAnswer]: Requires the question to be answered before proceeding.
/// - [calculate]: Performs a calculation based on logic.
enum LogicActionObjective {
  jumpToQuestion,
  requireAnswer,
  calculate,
}


/// Specifies an operation performed in a logic action.
///
/// - [add]: Adds values together.
/// - [subtract]: Subtracts one value from another.
/// - [multiply]: Multiplies values together.
/// - [divide]: Divides one value by another.
/// - [assign]: Assigns a value to a variable.
enum LogicActionOperator {
  add,
  subtract,
  multiply,
  divide,
  assign,
}


/// Determines how multiple conditions are connected.
///
/// - [and]: All conditions must be true.
/// - [or]: At least one condition must be true.
enum ConditionConnector {
  and,
  or,
}


/// Defines how individual conditions are evaluated.
///
/// - [equals]: Checks if values are equal.
/// - [equalsOneOf]: Checks if value matches one in a list.
/// - [isLessThan]: Checks if value is less than the given one.
/// - [isLessThanOrEqual]: Checks if value is less than or equal.
/// - [isGreaterThan]: Checks if value is greater than the given one.
/// - [isGreaterThanOrEqual]: Checks if value is greater than or equal.
/// - [doesNotEqual]: Checks if values are not equal.
/// - [contains]: Checks if value contains a substring or item.
/// - [doesNotContain]: Checks if value does not contain a substring or item.
/// - [startsWith]: Checks if value starts with a specific prefix.
/// - [doesNotStartWith]: Checks if value does not start with a prefix.
/// - [endsWith]: Checks if value ends with a specific suffix.
/// - [doesNotEndWith]: Checks if value does not end with a suffix.
/// - [isSubmitted]: Checks if the question has been submitted.
/// - [noOperator]: Default fallback or undefined operator.
enum ConditionOperator {
  equals,
  equalsOneOf,
  isLessThan,
  isLessThanOrEqual,
  isGreaterThan,
  isGreaterThanOrEqual,
  doesNotEqual,
  contains,
  doesNotContain,
  startsWith,
  doesNotStartWith,
  endsWith,
  doesNotEndWith,
  isSubmitted,
  noOperator,
}


/// Identifies the source type used in a condition or calculation.
///
/// - [question]: References the value of another question.
/// - [static]: A static constant value (e.g., 5 or "hello").
/// - [variable]: A dynamic variable used in survey logic.
enum OperandType {
  question,
  static,
  variable,
}

