class VerificationResult {
  final bool isValid;
  final String message;
  final Map<String, String>? extractedData;
  final bool isConnectionError;

  VerificationResult({
    required this.isValid, 
    required this.message, 
    this.extractedData,
    this.isConnectionError = false,
  });
}
