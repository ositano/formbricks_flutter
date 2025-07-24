class SDKError {
  SDKError._(); // Private constructor for singleton

  // Singleton instance
  static final SDKError instance = SDKError._();

  // Errors related to SDK initialization and configuration
  final sdkIsNotInitialized = Exception("Formbricks SDK is not initialized");
  final sdkIsAlreadyInitialized = Exception("Formbricks SDK is already initialized");

  // Errors related to network and connectivity
  final connectionIsNotAvailable = Exception("There is no connection.");
  final unableToLoadFormbicksJs = Exception("Unable to load Formbricks Javascript package.");

  // Errors related to surveys
  final surveyDisplayFetchError = Exception("Error: creating display: TypeError: Failure to fetch the survey data.");
  final surveyNotDisplayedError = Exception("Survey was not displayed due to display percentage restrictions.");
  final unableToRefreshEnvironment = Exception("Unable to refresh environment state.");
  final missingSurveyId = Exception("Survey id is mandatory to set.");
  final invalidDisplayOption = Exception("Invalid Display Option.");
  final unableToPostResponse = Exception("Unable to post survey response.");
  final surveyNotFoundError = Exception("No survey found matching the action class.");
  final noUserIdSetError = Exception("No userId is set, please set a userId first using the setUserId function");

  final couldNotCreateDisplayError = Exception("Something went wrong while creating a display. Please try again later");
  final couldNotCreateResponseError = Exception("Something went wrong while creating a response. Please try again later");
  final somethingWentWrongError = Exception("Something went wrong. Please try again later");
}
