@testable import Testbench
import Testing

@Suite
struct XcodebuildRegexTests {
  @Test
  func `Extract only successfull test cases`() throws {
    var count = 0
    for line in String.mockSuccessTestingOutputFromTestPlan.split(whereSeparator: \.isNewline) {
      let line = String(line)
      if let _ = line.match(using: .testingTestCaseSuccess, ignore: [.testingTestRunPassed]) {
        count += 1
      }
    }
    
    #expect(count == 66)
  }
  
  @Test
  func `Extract only test runs`() throws {
    var count = 0
    for line in String.mockSuccessTestingOutputFromTestPlan.split(whereSeparator: \.isNewline) {
      let line = String(line)
      if let _ = line.match(using: .testingTestRunPassed) {
        count += 1
      }
    }
    
    #expect(count == 2)
  }
  
  @Test
  func `Extract only test suits`() throws {
    var count = 0
    for line in String.mockSuccessTestingOutputFromTestPlan.split(whereSeparator: \.isNewline) {
      let line = String(line)
      if let _ = line.match(using: .testingTestSuite) {
        count += 1
      }
    }
    
    #expect(count == 6)
  }
}

extension String {
  static let mockSuccessTestingOutputFromTestPlan = """
  Testing started
  Test Suite 'All tests' started at 2025-11-13 18:46:05.981.
  Test Suite 'All tests' passed at 2025-11-13 18:46:05.981.
     Executed 0 tests, with 0 failures (0 unexpected) in 0.000 (0.000) seconds
  􀟈 Test run started.
  􀄵 Testing Library Version: 1085
  􀄵 Target Platform: arm64e-apple-macos14.0
  􀟈 Suite LoggableTests started.
  􀟈 Test whenLoggerAttachedToType_expectedToCaptureAllEvent() started.
  􁁛 Test whenLoggerAttachedToType_expectedToCaptureAllEvent() passed after 0.101 seconds.
  􁁛 Suite LoggableTests passed after 0.101 seconds.
  􁁛 Test run with 1 test in 1 suite passed after 0.101 seconds.
  Test Suite 'All tests' started at 2025-11-13 18:46:06.508.
  Test Suite 'All tests' passed at 2025-11-13 18:46:06.508.
     Executed 0 tests, with 0 failures (0 unexpected) in 0.000 (0.001) seconds
  􀟈 Test run started.
  􀄵 Testing Library Version: 1085
  􀄵 Target Platform: arm64e-apple-macos14.0
  􀟈 Suite LoggedMacroTests started.
  􀟈 Suite LogMacroTests started.
  􀟈 Suite OSLoggedMacroTests started.
  􀟈 Test class_withLoggableAsInitializer_noAdditionalAnnotations() started.
  􀟈 Suite OSLogMacroTests started.
  􀟈 Test actor_default_withOmmitAnnotations() started.
  􀟈 Test class_withLoggableAsStaticParameter_noAdditionalAnnotations() started.
  􀟈 Test struct_default_noAdditionalAnnotations() started.
  􀟈 Suite OSLoggerTests started.
  􀟈 Test class_withLoggableAsFunction_noAdditionalAnnotations() started.
  􀟈 Test functionWithInoutArgument_default_noAdditionalAnnotations() started.
  􀟈 Test enum_default_noAdditionalAnnotations() started.
  􀟈 Test voidFunction_loggableAsStaticParameter_noAdditionalAnnotations() started.
  􀟈 Test stringFunctionWithArguments_loggableAndLevelableAsStaticParameters_noAdditionalAnnotations() started.
  􀟈 Test extension_default_noAdditionalAnnotations() started.
  􀟈 Test throwingFunction_default_withTagAndLevelAnnotations() started.
  􀟈 Test mutatingThrowingFunction_default_noAdditionalAnnotations() started.
  􀟈 Test optionalIntFunction_default_noAdditionalAnnotations() started.
  􀟈 Test throwingFunctionWithArgument_default_withOmitParameterAnnotation() started.
  􀟈 Test genericFunctionWithGenericClosureParameter_default_noAdditionalAnnotations() started.
  􀟈 Test functionWithAsyncClosureArgument_default_noAdditionalAnnotations() started.
  􀟈 Test stringFunctionWithArgument_taggableAsStringLiteralType_noAdditionalAnnotations() started.
  􀟈 Test genericFunctionWithComplexSignature_default_withOmitSecondParameterAnnotation() started.
  􀟈 Test intFunctionWithVariadicParameters_default_noAdditionalAnnotations() started.
  􀟈 Test voidFunction_default_noAdditinalAnnotations() started.
  􀟈 Test functionWithInoutAndDefaultArgument_default_noAdditionalAnnotations() started.
  􀟈 Test asyncThrowingFunction_levelableAsStringLiteralTypeParameter_withTagAnnotation() started.
  􀟈 Test function_default_objcAnnotation() started.
  􀟈 Test tupleFunctionWithLabeledArguments_default_noAdditionalAnnotations() started.
  􀟈 Test stringFunctionWithDefaultParameters_default_noAdditionalAnnotations() started.
  􀟈 Test stringFunctionWithAsyncThrowingClosureParameter_default_noAdditionalAnnotations() started.
  􀟈 Test mutatingFunctionWithArgument_taggableAndLevelableAsPrameters_noAdditionalAnnotations() started.
  􀟈 Test genericArrayfunctionWithGenericClosureArgument_default_noAdditionalAnnotations() started.
  􀟈 Test enum_default_noAdditionalAnnotations() started.
  􀟈 Test extension_default_noAdditionalAnnotations() started.
  􀟈 Test genericFunctionWithMultipleConstraints_default_noAdditionalAnnotations() started.
  􀟈 Test struct_default_noAdditionalAnnotations() started.
  􀟈 Test staticFunctionWithArgument_omittableAsStringLiteralType_withOmitResultAnnotation() started.
  􀟈 Test class_withCustomSubsystemAndCategory_noAdditionalAnnotations() started.
  􀟈 Test functionWithArgument_default_mainActorAnnotation() started.
  􀟈 Test actor_default_withOmmitAnnotations() started.
  􀟈 Test functionWithClosureDefaultValue_default_noAdditionalAnnotations() started.
  􀟈 Test functionWithOptionalArgument_default_noAdditionalAnnotations() started.
  􀟈 Test functionWithEscapingClosure_default_noAdditionalAnnotations() started.
  􀟈 Test overridingStringFunction_default_noAdditionalAnnotations() started.
  􀟈 Test voidFunction_lggableAsInitializer_noAdditionalAnnotations() started.
  􀟈 Test staticGenericFunction_default_withDiscardableResultAnnotation() started.
  􀟈 Test functionWithAutoclosureArgument_omittableAsStaticParameter_withLevelAnnotation() started.
  􀟈 Test functionWithArgument_default_withDiscardableResultAndOmitResultAnnotations() started.
  􀟈 Test stringFunctionWithTupleParameter_default_noAdditionalAnnotations() started.
  􀟈 Test functionWithArguments_allTraits_noAdditionalAnnotations() started.
  􀟈 Test throwingFunctionWithArguments_omittableAsStaticParameter_noAdditionalAnnotations() started.
  􀟈 Test genericTupleFunctionWithWhereClauseAndArguments_default_withRedundantTagAnnotation() started.
  􀟈 Test throwingFunction_default_noAdditionalAnnotations() started.
  􀟈 Test mutatingFunction_default_withLevelAnnotation() started.
  􀟈 Test intClosureFunction_default_noAdditionalAnnotations() started.
  􀟈 Test function_default_noAdditionalAnnotations() started.
  􀟈 Test rethrowsFunctionWithClosureArgument_omittableAsStringLiteralType_withRedundatOmitParameterAnnotation() started.
  􀟈 Test stringFunction_default_noAdditionalAnnotations() started.
  􀟈 Test intFunctionWithVariadicParameters_taggableAsStringLiteralType_noAdditionalAnnotations() started.
  􀟈 Test functionWithArguments_allTraits_noAdditionalAnnotations() started.
  􀟈 Test mainActorStruct_withCustomAccessLevel_internalAccessModifier() started.
  􀟈 Test class_default_openAccessModifier() started.
  􀟈 Test extension_default_privateAccessModifer() started.
  􀟈 Test genericEnum_withCustomSubsystemAndCategory_privateAccessModifier() started.
  􀟈 Test actor_default_internalAccessModifier() started.
  􀟈 Test genericExtension_withCustomAccessLevel_privateAccessModifier() started.
  􀟈 Test class_default_finalAccessModifer() started.
  􀟈 Test enum_default_filePrivateAccessModifer() started.
  􀟈 Test struct_default_privateAccessModifer() started.
  􁁛 Test enum_default_noAdditionalAnnotations() passed after 0.384 seconds.
  􁁛 Test struct_default_noAdditionalAnnotations() passed after 0.384 seconds.
  􁁛 Test class_withLoggableAsStaticParameter_noAdditionalAnnotations() passed after 0.384 seconds.
  􁁛 Test actor_default_withOmmitAnnotations() passed after 0.384 seconds.
  􁁛 Test functionWithInoutArgument_default_noAdditionalAnnotations() passed after 0.395 seconds.
  􁁛 Test voidFunction_loggableAsStaticParameter_noAdditionalAnnotations() passed after 0.395 seconds.
  􁁛 Test class_withLoggableAsFunction_noAdditionalAnnotations() passed after 0.410 seconds.
  􁁛 Test class_withLoggableAsInitializer_noAdditionalAnnotations() passed after 0.421 seconds.
  􁁛 Test extension_default_noAdditionalAnnotations() passed after 0.427 seconds.
  􁁛 Test functionWithAsyncClosureArgument_default_noAdditionalAnnotations() passed after 0.426 seconds.
  􁁛 Test optionalIntFunction_default_noAdditionalAnnotations() passed after 0.426 seconds.
  􁁛 Test stringFunctionWithArguments_loggableAndLevelableAsStaticParameters_noAdditionalAnnotations() passed after 0.426 seconds.
  􁁛 Test throwingFunction_default_withTagAndLevelAnnotations() passed after 0.426 seconds.
  􁁛 Test genericFunctionWithGenericClosureParameter_default_noAdditionalAnnotations() passed after 0.426 seconds.
  􁁛 Test throwingFunctionWithArgument_default_withOmitParameterAnnotation() passed after 0.426 seconds.
  􁁛 Test stringFunctionWithArgument_taggableAsStringLiteralType_noAdditionalAnnotations() passed after 0.426 seconds.
  􁁛 Test voidFunction_default_noAdditinalAnnotations() passed after 0.426 seconds.
  􁁛 Test mutatingThrowingFunction_default_noAdditionalAnnotations() passed after 0.426 seconds.
  􁁛 Test functionWithInoutAndDefaultArgument_default_noAdditionalAnnotations() passed after 0.426 seconds.
  􁁛 Test function_default_objcAnnotation() passed after 0.426 seconds.
  􁁛 Test intFunctionWithVariadicParameters_default_noAdditionalAnnotations() passed after 0.426 seconds.
  􁁛 Test genericFunctionWithComplexSignature_default_withOmitSecondParameterAnnotation() passed after 0.427 seconds.
  􁁛 Test enum_default_noAdditionalAnnotations() passed after 0.426 seconds.
  􁁛 Test stringFunctionWithDefaultParameters_default_noAdditionalAnnotations() passed after 0.426 seconds.
  􁁛 Test asyncThrowingFunction_levelableAsStringLiteralTypeParameter_withTagAnnotation() passed after 0.427 seconds.
  􁁛 Test tupleFunctionWithLabeledArguments_default_noAdditionalAnnotations() passed after 0.427 seconds.
  􁁛 Test extension_default_noAdditionalAnnotations() passed after 0.427 seconds.
  􁁛 Test struct_default_noAdditionalAnnotations() passed after 0.427 seconds.
  􁁛 Test stringFunctionWithAsyncThrowingClosureParameter_default_noAdditionalAnnotations() passed after 0.427 seconds.
  􁁛 Test functionWithArgument_default_mainActorAnnotation() passed after 0.427 seconds.
  􁁛 Test class_withCustomSubsystemAndCategory_noAdditionalAnnotations() passed after 0.427 seconds.
  􁁛 Test actor_default_withOmmitAnnotations() passed after 0.427 seconds.
  􁁛 Test staticFunctionWithArgument_omittableAsStringLiteralType_withOmitResultAnnotation() passed after 0.427 seconds.
  􁁛 Test genericArrayfunctionWithGenericClosureArgument_default_noAdditionalAnnotations() passed after 0.427 seconds.
  􁁛 Test functionWithClosureDefaultValue_default_noAdditionalAnnotations() passed after 0.427 seconds.
  􁁛 Test voidFunction_lggableAsInitializer_noAdditionalAnnotations() passed after 0.424 seconds.
  􁁛 Test functionWithEscapingClosure_default_noAdditionalAnnotations() passed after 0.424 seconds.
  􁁛 Test functionWithOptionalArgument_default_noAdditionalAnnotations() passed after 0.427 seconds.
  􁁛 Test overridingStringFunction_default_noAdditionalAnnotations() passed after 0.424 seconds.
  􁁛 Test genericFunctionWithMultipleConstraints_default_noAdditionalAnnotations() passed after 0.428 seconds.
  􁁛 Test staticGenericFunction_default_withDiscardableResultAnnotation() passed after 0.424 seconds.
  􁁛 Test functionWithAutoclosureArgument_omittableAsStaticParameter_withLevelAnnotation() passed after 0.424 seconds.
  􁁛 Test mutatingFunction_default_withLevelAnnotation() passed after 0.423 seconds.
  􁁛 Test functionWithArgument_default_withDiscardableResultAndOmitResultAnnotations() passed after 0.424 seconds.
  􁁛 Test mutatingFunctionWithArgument_taggableAndLevelableAsPrameters_noAdditionalAnnotations() passed after 0.428 seconds.
  􁁛 Test intClosureFunction_default_noAdditionalAnnotations() passed after 0.422 seconds.
  􁁛 Test functionWithArguments_allTraits_noAdditionalAnnotations() passed after 0.424 seconds.
  􁁛 Test function_default_noAdditionalAnnotations() passed after 0.422 seconds.
  􁁛 Test genericTupleFunctionWithWhereClauseAndArguments_default_withRedundantTagAnnotation() passed after 0.425 seconds.
  􁁛 Test stringFunctionWithTupleParameter_default_noAdditionalAnnotations() passed after 0.426 seconds.
  􁁛 Test rethrowsFunctionWithClosureArgument_omittableAsStringLiteralType_withRedundatOmitParameterAnnotation() passed after 0.424 seconds.
  􁁛 Test class_default_openAccessModifier() passed after 0.378 seconds.
  􁁛 Test stringFunction_default_noAdditionalAnnotations() passed after 0.424 seconds.
  􁁛 Test extension_default_privateAccessModifer() passed after 0.371 seconds.
  􁁛 Test mainActorStruct_withCustomAccessLevel_internalAccessModifier() passed after 0.381 seconds.
  􁁛 Test actor_default_internalAccessModifier() passed after 0.371 seconds.
  􁁛 Test throwingFunctionWithArguments_omittableAsStaticParameter_noAdditionalAnnotations() passed after 0.427 seconds.
  􁁛 Test functionWithArguments_allTraits_noAdditionalAnnotations() passed after 0.424 seconds.
  􁁛 Test intFunctionWithVariadicParameters_taggableAsStringLiteralType_noAdditionalAnnotations() passed after 0.425 seconds.
  􁁛 Suite LoggedMacroTests passed after 0.435 seconds.
  􁁛 Test enum_default_filePrivateAccessModifer() passed after 0.372 seconds.
  􁁛 Suite OSLogMacroTests passed after 0.436 seconds.
  􁁛 Suite OSLoggedMacroTests passed after 0.436 seconds.
  􁁛 Test struct_default_privateAccessModifer() passed after 0.372 seconds.
  􁁛 Test class_default_finalAccessModifer() passed after 0.374 seconds.
  􁁛 Test genericEnum_withCustomSubsystemAndCategory_privateAccessModifier() passed after 0.377 seconds.
  􁁛 Test genericExtension_withCustomAccessLevel_privateAccessModifier() passed after 0.375 seconds.
  􁁛 Suite OSLoggerTests passed after 0.439 seconds.
  􁁛 Test throwingFunction_default_noAdditionalAnnotations() passed after 0.438 seconds.
  􁁛 Suite LogMacroTests passed after 0.445 seconds.
  􁁛 Test run with 65 tests in 5 suites passed after 0.459 seconds.
  """
}
