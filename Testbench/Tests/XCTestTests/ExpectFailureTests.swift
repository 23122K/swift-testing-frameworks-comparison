import XCTest

final class ExpectFailureTests: XCTestCase {
  func testUnwrapCaughtFailureThenAssertEqual1() throws {
    XCTExpectFailure {
//      throw NSError(domain: "foo.com.error", code: 1)
      print("Foo")
    } issueMatcher: {
      switch $0.associatedError as? NSError {
      case .some:
        true
        
      case .none:
        false
      }
    }
  }
  
  func testFoo() async throws {
    let expectation = XCTestExpectation()
    expectation.isInverted = true
    
//    expectation.fulfill()
    
    await fulfillment(of: [expectation], timeout: 1)
  }

  func testUnwrapCaughtFailureThenAssertEqual2() throws {
    XCTAssertThrowsError(
      try { throw Failure(code: 2) }()
    ) { error in
      let failure = try? XCTUnwrap(error as? Failure)
      XCTAssert(failure?.code == 2)
    }
  }

  func testUnwrapCaughtFailureThenAssertEqual3() throws {
    XCTAssertThrowsError(
      try { throw Failure(code: 3) }()
    ) { error in
      let failure = try? XCTUnwrap(error as? Failure)
      XCTAssert(failure?.code == 3)
    }
  }

  func testUnwrapCaughtFailureThenAssertEqual4() throws {
    XCTAssertThrowsError(
      try { throw Failure(code: 4) }()
    ) { error in
      let failure = try? XCTUnwrap(error as? Failure)
      XCTAssert(failure?.code == 4)
    }
  }

  func testUnwrapCaughtFailureThenAssertEqual5() throws {
    XCTAssertThrowsError(
      try { throw Failure(code: 5) }()
    ) { error in
      let failure = try? XCTUnwrap(error as? Failure)
      XCTAssert(failure?.code == 5)
    }
  }

  func testUnwrapCaughtFailureThenAssertEqual6() throws {
    XCTAssertThrowsError(
      try { throw Failure(code: 6) }()
    ) { error in
      let failure = try? XCTUnwrap(error as? Failure)
      XCTAssert(failure?.code == 6)
    }
  }

  func testUnwrapCaughtFailureThenAssertEqual7() throws {
    XCTAssertThrowsError(
      try { throw Failure(code: 7) }()
    ) { error in
      let failure = try? XCTUnwrap(error as? Failure)
      XCTAssert(failure?.code == 7)
    }
  }

  func testUnwrapCaughtFailureThenAssertEqual8() throws {
    XCTAssertThrowsError(
      try { throw Failure(code: 8) }()
    ) { error in
      let failure = try? XCTUnwrap(error as? Failure)
      XCTAssert(failure?.code == 8)
    }
  }

  func testUnwrapCaughtFailureThenAssertEqual9() throws {
    XCTAssertThrowsError(
      try { throw Failure(code: 9) }()
    ) { error in
      let failure = try? XCTUnwrap(error as? Failure)
      XCTAssert(failure?.code == 9)
    }
  }

  func testUnwrapCaughtFailureThenAssertEqual10() throws {
    XCTAssertThrowsError(
      try { throw Failure(code: 10) }()
    ) { error in
      let failure = try? XCTUnwrap(error as? Failure)
      XCTAssert(failure?.code == 10)
    }
  }

  func testUnwrapCaughtFailureThenAssertEqual11() throws {
    XCTAssertThrowsError(
      try { throw Failure(code: 11) }()
    ) { error in
      let failure = try? XCTUnwrap(error as? Failure)
      XCTAssert(failure?.code == 11)
    }
  }

  func testUnwrapCaughtFailureThenAssertEqual12() throws {
    XCTAssertThrowsError(
      try { throw Failure(code: 12) }()
    ) { error in
      let failure = try? XCTUnwrap(error as? Failure)
      XCTAssert(failure?.code == 12)
    }
  }

  func testUnwrapCaughtFailureThenAssertEqual13() throws {
    XCTAssertThrowsError(
      try { throw Failure(code: 13) }()
    ) { error in
      let failure = try? XCTUnwrap(error as? Failure)
      XCTAssert(failure?.code == 13)
    }
  }

  func testUnwrapCaughtFailureThenAssertEqual14() throws {
    XCTAssertThrowsError(
      try { throw Failure(code: 14) }()
    ) { error in
      let failure = try? XCTUnwrap(error as? Failure)
      XCTAssert(failure?.code == 14)
    }
  }

  func testUnwrapCaughtFailureThenAssertEqual15() throws {
    XCTAssertThrowsError(
      try { throw Failure(code: 15) }()
    ) { error in
      let failure = try? XCTUnwrap(error as? Failure)
      XCTAssert(failure?.code == 15)
    }
  }

  func testUnwrapCaughtFailureThenAssertEqual16() throws {
    XCTAssertThrowsError(
      try { throw Failure(code: 16) }()
    ) { error in
      let failure = try? XCTUnwrap(error as? Failure)
      XCTAssert(failure?.code == 16)
    }
  }

  func testUnwrapCaughtFailureThenAssertEqual17() throws {
    XCTAssertThrowsError(
      try { throw Failure(code: 17) }()
    ) { error in
      let failure = try? XCTUnwrap(error as? Failure)
      XCTAssert(failure?.code == 17)
    }
  }

  func testUnwrapCaughtFailureThenAssertEqual18() throws {
    XCTAssertThrowsError(
      try { throw Failure(code: 18) }()
    ) { error in
      let failure = try? XCTUnwrap(error as? Failure)
      XCTAssert(failure?.code == 18)
    }
  }

  func testUnwrapCaughtFailureThenAssertEqual19() throws {
    XCTAssertThrowsError(
      try { throw Failure(code: 19) }()
    ) { error in
      let failure = try? XCTUnwrap(error as? Failure)
      XCTAssert(failure?.code == 19)
    }
  }

  func testUnwrapCaughtFailureThenAssertEqual20() throws {
    XCTAssertThrowsError(
      try { throw Failure(code: 20) }()
    ) { error in
      let failure = try? XCTUnwrap(error as? Failure)
      XCTAssert(failure?.code == 20)
    }
  }

  func testUnwrapCaughtFailureThenAssertEqual21() throws {
    XCTAssertThrowsError(
      try { throw Failure(code: 21) }()
    ) { error in
      let failure = try? XCTUnwrap(error as? Failure)
      XCTAssert(failure?.code == 21)
    }
  }

  func testUnwrapCaughtFailureThenAssertEqual22() throws {
    XCTAssertThrowsError(
      try { throw Failure(code: 22) }()
    ) { error in
      let failure = try? XCTUnwrap(error as? Failure)
      XCTAssert(failure?.code == 22)
    }
  }

  func testUnwrapCaughtFailureThenAssertEqual23() throws {
    XCTAssertThrowsError(
      try { throw Failure(code: 23) }()
    ) { error in
      let failure = try? XCTUnwrap(error as? Failure)
      XCTAssert(failure?.code == 23)
    }
  }

  func testUnwrapCaughtFailureThenAssertEqual24() throws {
    XCTAssertThrowsError(
      try { throw Failure(code: 24) }()
    ) { error in
      let failure = try? XCTUnwrap(error as? Failure)
      XCTAssert(failure?.code == 24)
    }
  }

  func testUnwrapCaughtFailureThenAssertEqual25() throws {
    XCTAssertThrowsError(
      try { throw Failure(code: 25) }()
    ) { error in
      let failure = try? XCTUnwrap(error as? Failure)
      XCTAssert(failure?.code == 25)
    }
  }

  func testUnwrapCaughtFailureThenAssertEqual26() throws {
    XCTAssertThrowsError(
      try { throw Failure(code: 26) }()
    ) { error in
      let failure = try? XCTUnwrap(error as? Failure)
      XCTAssert(failure?.code == 26)
    }
  }

  func testUnwrapCaughtFailureThenAssertEqual27() throws {
    XCTAssertThrowsError(
      try { throw Failure(code: 27) }()
    ) { error in
      let failure = try? XCTUnwrap(error as? Failure)
      XCTAssert(failure?.code == 27)
    }
  }

  func testUnwrapCaughtFailureThenAssertEqual28() throws {
    XCTAssertThrowsError(
      try { throw Failure(code: 28) }()
    ) { error in
      let failure = try? XCTUnwrap(error as? Failure)
      XCTAssert(failure?.code == 28)
    }
  }

  func testUnwrapCaughtFailureThenAssertEqual29() throws {
    XCTAssertThrowsError(
      try { throw Failure(code: 29) }()
    ) { error in
      let failure = try? XCTUnwrap(error as? Failure)
      XCTAssert(failure?.code == 29)
    }
  }

  func testUnwrapCaughtFailureThenAssertEqual30() throws {
    XCTAssertThrowsError(
      try { throw Failure(code: 30) }()
    ) { error in
      let failure = try? XCTUnwrap(error as? Failure)
      XCTAssert(failure?.code == 30)
    }
  }

  func testUnwrapCaughtFailureThenAssertEqual31() throws {
    XCTAssertThrowsError(
      try { throw Failure(code: 31) }()
    ) { error in
      let failure = try? XCTUnwrap(error as? Failure)
      XCTAssert(failure?.code == 31)
    }
  }

  func testUnwrapCaughtFailureThenAssertEqual32() throws {
    XCTAssertThrowsError(
      try { throw Failure(code: 32) }()
    ) { error in
      let failure = try? XCTUnwrap(error as? Failure)
      XCTAssert(failure?.code == 32)
    }
  }

  func testUnwrapCaughtFailureThenAssertEqual33() throws {
    XCTAssertThrowsError(
      try { throw Failure(code: 33) }()
    ) { error in
      let failure = try? XCTUnwrap(error as? Failure)
      XCTAssert(failure?.code == 33)
    }
  }

  func testUnwrapCaughtFailureThenAssertEqual34() throws {
    XCTAssertThrowsError(
      try { throw Failure(code: 34) }()
    ) { error in
      let failure = try? XCTUnwrap(error as? Failure)
      XCTAssert(failure?.code == 34)
    }
  }

  func testUnwrapCaughtFailureThenAssertEqual35() throws {
    XCTAssertThrowsError(
      try { throw Failure(code: 35) }()
    ) { error in
      let failure = try? XCTUnwrap(error as? Failure)
      XCTAssert(failure?.code == 35)
    }
  }

  func testUnwrapCaughtFailureThenAssertEqual36() throws {
    XCTAssertThrowsError(
      try { throw Failure(code: 36) }()
    ) { error in
      let failure = try? XCTUnwrap(error as? Failure)
      XCTAssert(failure?.code == 36)
    }
  }

  func testUnwrapCaughtFailureThenAssertEqual37() throws {
    XCTAssertThrowsError(
      try { throw Failure(code: 37) }()
    ) { error in
      let failure = try? XCTUnwrap(error as? Failure)
      XCTAssert(failure?.code == 37)
    }
  }

  func testUnwrapCaughtFailureThenAssertEqual38() throws {
    XCTAssertThrowsError(
      try { throw Failure(code: 38) }()
    ) { error in
      let failure = try? XCTUnwrap(error as? Failure)
      XCTAssert(failure?.code == 38)
    }
  }

  func testUnwrapCaughtFailureThenAssertEqual39() throws {
    XCTAssertThrowsError(
      try { throw Failure(code: 39) }()
    ) { error in
      let failure = try? XCTUnwrap(error as? Failure)
      XCTAssert(failure?.code == 39)
    }
  }

  func testUnwrapCaughtFailureThenAssertEqual40() throws {
    XCTAssertThrowsError(
      try { throw Failure(code: 40) }()
    ) { error in
      let failure = try? XCTUnwrap(error as? Failure)
      XCTAssert(failure?.code == 40)
    }
  }

  func testUnwrapCaughtFailureThenAssertEqual41() throws {
    XCTAssertThrowsError(
      try { throw Failure(code: 41) }()
    ) { error in
      let failure = try? XCTUnwrap(error as? Failure)
      XCTAssert(failure?.code == 41)
    }
  }

  func testUnwrapCaughtFailureThenAssertEqual42() throws {
    XCTAssertThrowsError(
      try { throw Failure(code: 42) }()
    ) { error in
      let failure = try? XCTUnwrap(error as? Failure)
      XCTAssert(failure?.code == 42)
    }
  }

  func testUnwrapCaughtFailureThenAssertEqual43() throws {
    XCTAssertThrowsError(
      try { throw Failure(code: 43) }()
    ) { error in
      let failure = try? XCTUnwrap(error as? Failure)
      XCTAssert(failure?.code == 43)
    }
  }

  func testUnwrapCaughtFailureThenAssertEqual44() throws {
    XCTAssertThrowsError(
      try { throw Failure(code: 44) }()
    ) { error in
      let failure = try? XCTUnwrap(error as? Failure)
      XCTAssert(failure?.code == 44)
    }
  }

  func testUnwrapCaughtFailureThenAssertEqual45() throws {
    XCTAssertThrowsError(
      try { throw Failure(code: 45) }()
    ) { error in
      let failure = try? XCTUnwrap(error as? Failure)
      XCTAssert(failure?.code == 45)
    }
  }

  func testUnwrapCaughtFailureThenAssertEqual46() throws {
    XCTAssertThrowsError(
      try { throw Failure(code: 46) }()
    ) { error in
      let failure = try? XCTUnwrap(error as? Failure)
      XCTAssert(failure?.code == 46)
    }
  }

  func testUnwrapCaughtFailureThenAssertEqual47() throws {
    XCTAssertThrowsError(
      try { throw Failure(code: 47) }()
    ) { error in
      let failure = try? XCTUnwrap(error as? Failure)
      XCTAssert(failure?.code == 47)
    }
  }

  func testUnwrapCaughtFailureThenAssertEqual48() throws {
    XCTAssertThrowsError(
      try { throw Failure(code: 48) }()
    ) { error in
      let failure = try? XCTUnwrap(error as? Failure)
      XCTAssert(failure?.code == 48)
    }
  }

  func testUnwrapCaughtFailureThenAssertEqual49() throws {
    XCTAssertThrowsError(
      try { throw Failure(code: 49) }()
    ) { error in
      let failure = try? XCTUnwrap(error as? Failure)
      XCTAssert(failure?.code == 49)
    }
  }

  func testUnwrapCaughtFailureThenAssertEqual50() throws {
    XCTAssertThrowsError(
      try { throw Failure(code: 50) }()
    ) { error in
      let failure = try? XCTUnwrap(error as? Failure)
      XCTAssert(failure?.code == 50)
    }
  }

  func testUnwrapCaughtFailureThenAssertEqual51() throws {
    XCTAssertThrowsError(
      try { throw Failure(code: 51) }()
    ) { error in
      let failure = try? XCTUnwrap(error as? Failure)
      XCTAssert(failure?.code == 51)
    }
  }

  func testUnwrapCaughtFailureThenAssertEqual52() throws {
    XCTAssertThrowsError(
      try { throw Failure(code: 52) }()
    ) { error in
      let failure = try? XCTUnwrap(error as? Failure)
      XCTAssert(failure?.code == 52)
    }
  }

  func testUnwrapCaughtFailureThenAssertEqual53() throws {
    XCTAssertThrowsError(
      try { throw Failure(code: 53) }()
    ) { error in
      let failure = try? XCTUnwrap(error as? Failure)
      XCTAssert(failure?.code == 53)
    }
  }

  func testUnwrapCaughtFailureThenAssertEqual54() throws {
    XCTAssertThrowsError(
      try { throw Failure(code: 54) }()
    ) { error in
      let failure = try? XCTUnwrap(error as? Failure)
      XCTAssert(failure?.code == 54)
    }
  }

  func testUnwrapCaughtFailureThenAssertEqual55() throws {
    XCTAssertThrowsError(
      try { throw Failure(code: 55) }()
    ) { error in
      let failure = try? XCTUnwrap(error as? Failure)
      XCTAssert(failure?.code == 55)
    }
  }

  func testUnwrapCaughtFailureThenAssertEqual56() throws {
    XCTAssertThrowsError(
      try { throw Failure(code: 56) }()
    ) { error in
      let failure = try? XCTUnwrap(error as? Failure)
      XCTAssert(failure?.code == 56)
    }
  }

  func testUnwrapCaughtFailureThenAssertEqual57() throws {
    XCTAssertThrowsError(
      try { throw Failure(code: 57) }()
    ) { error in
      let failure = try? XCTUnwrap(error as? Failure)
      XCTAssert(failure?.code == 57)
    }
  }

  func testUnwrapCaughtFailureThenAssertEqual58() throws {
    XCTAssertThrowsError(
      try { throw Failure(code: 58) }()
    ) { error in
      let failure = try? XCTUnwrap(error as? Failure)
      XCTAssert(failure?.code == 58)
    }
  }

  func testUnwrapCaughtFailureThenAssertEqual59() throws {
    XCTAssertThrowsError(
      try { throw Failure(code: 59) }()
    ) { error in
      let failure = try? XCTUnwrap(error as? Failure)
      XCTAssert(failure?.code == 59)
    }
  }

  func testUnwrapCaughtFailureThenAssertEqual60() throws {
    XCTAssertThrowsError(
      try { throw Failure(code: 60) }()
    ) { error in
      let failure = try? XCTUnwrap(error as? Failure)
      XCTAssert(failure?.code == 60)
    }
  }

  func testUnwrapCaughtFailureThenAssertEqual61() throws {
    XCTAssertThrowsError(
      try { throw Failure(code: 61) }()
    ) { error in
      let failure = try? XCTUnwrap(error as? Failure)
      XCTAssert(failure?.code == 61)
    }
  }

  func testUnwrapCaughtFailureThenAssertEqual62() throws {
    XCTAssertThrowsError(
      try { throw Failure(code: 62) }()
    ) { error in
      let failure = try? XCTUnwrap(error as? Failure)
      XCTAssert(failure?.code == 62)
    }
  }

  func testUnwrapCaughtFailureThenAssertEqual63() throws {
    XCTAssertThrowsError(
      try { throw Failure(code: 63) }()
    ) { error in
      let failure = try? XCTUnwrap(error as? Failure)
      XCTAssert(failure?.code == 63)
    }
  }

  func testUnwrapCaughtFailureThenAssertEqual64() throws {
    XCTAssertThrowsError(
      try { throw Failure(code: 64) }()
    ) { error in
      let failure = try? XCTUnwrap(error as? Failure)
      XCTAssert(failure?.code == 64)
    }
  }

  func testUnwrapCaughtFailureThenAssertEqual65() throws {
    XCTAssertThrowsError(
      try { throw Failure(code: 65) }()
    ) { error in
      let failure = try? XCTUnwrap(error as? Failure)
      XCTAssert(failure?.code == 65)
    }
  }

  func testUnwrapCaughtFailureThenAssertEqual66() throws {
    XCTAssertThrowsError(
      try { throw Failure(code: 66) }()
    ) { error in
      let failure = try? XCTUnwrap(error as? Failure)
      XCTAssert(failure?.code == 66)
    }
  }

  func testUnwrapCaughtFailureThenAssertEqual67() throws {
    XCTAssertThrowsError(
      try { throw Failure(code: 67) }()
    ) { error in
      let failure = try? XCTUnwrap(error as? Failure)
      XCTAssert(failure?.code == 67)
    }
  }

  func testUnwrapCaughtFailureThenAssertEqual68() throws {
    XCTAssertThrowsError(
      try { throw Failure(code: 68) }()
    ) { error in
      let failure = try? XCTUnwrap(error as? Failure)
      XCTAssert(failure?.code == 68)
    }
  }

  func testUnwrapCaughtFailureThenAssertEqual69() throws {
    XCTAssertThrowsError(
      try { throw Failure(code: 69) }()
    ) { error in
      let failure = try? XCTUnwrap(error as? Failure)
      XCTAssert(failure?.code == 69)
    }
  }

  func testUnwrapCaughtFailureThenAssertEqual70() throws {
    XCTAssertThrowsError(
      try { throw Failure(code: 70) }()
    ) { error in
      let failure = try? XCTUnwrap(error as? Failure)
      XCTAssert(failure?.code == 70)
    }
  }

  func testUnwrapCaughtFailureThenAssertEqual71() throws {
    XCTAssertThrowsError(
      try { throw Failure(code: 71) }()
    ) { error in
      let failure = try? XCTUnwrap(error as? Failure)
      XCTAssert(failure?.code == 71)
    }
  }

  func testUnwrapCaughtFailureThenAssertEqual72() throws {
    XCTAssertThrowsError(
      try { throw Failure(code: 72) }()
    ) { error in
      let failure = try? XCTUnwrap(error as? Failure)
      XCTAssert(failure?.code == 72)
    }
  }

  func testUnwrapCaughtFailureThenAssertEqual73() throws {
    XCTAssertThrowsError(
      try { throw Failure(code: 73) }()
    ) { error in
      let failure = try? XCTUnwrap(error as? Failure)
      XCTAssert(failure?.code == 73)
    }
  }

  func testUnwrapCaughtFailureThenAssertEqual74() throws {
    XCTAssertThrowsError(
      try { throw Failure(code: 74) }()
    ) { error in
      let failure = try? XCTUnwrap(error as? Failure)
      XCTAssert(failure?.code == 74)
    }
  }

  func testUnwrapCaughtFailureThenAssertEqual75() throws {
    XCTAssertThrowsError(
      try { throw Failure(code: 75) }()
    ) { error in
      let failure = try? XCTUnwrap(error as? Failure)
      XCTAssert(failure?.code == 75)
    }
  }

  func testUnwrapCaughtFailureThenAssertEqual76() throws {
    XCTAssertThrowsError(
      try { throw Failure(code: 76) }()
    ) { error in
      let failure = try? XCTUnwrap(error as? Failure)
      XCTAssert(failure?.code == 76)
    }
  }

  func testUnwrapCaughtFailureThenAssertEqual77() throws {
    XCTAssertThrowsError(
      try { throw Failure(code: 77) }()
    ) { error in
      let failure = try? XCTUnwrap(error as? Failure)
      XCTAssert(failure?.code == 77)
    }
  }

  func testUnwrapCaughtFailureThenAssertEqual78() throws {
    XCTAssertThrowsError(
      try { throw Failure(code: 78) }()
    ) { error in
      let failure = try? XCTUnwrap(error as? Failure)
      XCTAssert(failure?.code == 78)
    }
  }

  func testUnwrapCaughtFailureThenAssertEqual79() throws {
    XCTAssertThrowsError(
      try { throw Failure(code: 79) }()
    ) { error in
      let failure = try? XCTUnwrap(error as? Failure)
      XCTAssert(failure?.code == 79)
    }
  }

  func testUnwrapCaughtFailureThenAssertEqual80() throws {
    XCTAssertThrowsError(
      try { throw Failure(code: 80) }()
    ) { error in
      let failure = try? XCTUnwrap(error as? Failure)
      XCTAssert(failure?.code == 80)
    }
  }

  func testUnwrapCaughtFailureThenAssertEqual81() throws {
    XCTAssertThrowsError(
      try { throw Failure(code: 81) }()
    ) { error in
      let failure = try? XCTUnwrap(error as? Failure)
      XCTAssert(failure?.code == 81)
    }
  }

  func testUnwrapCaughtFailureThenAssertEqual82() throws {
    XCTAssertThrowsError(
      try { throw Failure(code: 82) }()
    ) { error in
      let failure = try? XCTUnwrap(error as? Failure)
      XCTAssert(failure?.code == 82)
    }
  }

  func testUnwrapCaughtFailureThenAssertEqual83() throws {
    XCTAssertThrowsError(
      try { throw Failure(code: 83) }()
    ) { error in
      let failure = try? XCTUnwrap(error as? Failure)
      XCTAssert(failure?.code == 83)
    }
  }

  func testUnwrapCaughtFailureThenAssertEqual84() throws {
    XCTAssertThrowsError(
      try { throw Failure(code: 84) }()
    ) { error in
      let failure = try? XCTUnwrap(error as? Failure)
      XCTAssert(failure?.code == 84)
    }
  }

  func testUnwrapCaughtFailureThenAssertEqual85() throws {
    XCTAssertThrowsError(
      try { throw Failure(code: 85) }()
    ) { error in
      let failure = try? XCTUnwrap(error as? Failure)
      XCTAssert(failure?.code == 85)
    }
  }

  func testUnwrapCaughtFailureThenAssertEqual86() throws {
    XCTAssertThrowsError(
      try { throw Failure(code: 86) }()
    ) { error in
      let failure = try? XCTUnwrap(error as? Failure)
      XCTAssert(failure?.code == 86)
    }
  }

  func testUnwrapCaughtFailureThenAssertEqual87() throws {
    XCTAssertThrowsError(
      try { throw Failure(code: 87) }()
    ) { error in
      let failure = try? XCTUnwrap(error as? Failure)
      XCTAssert(failure?.code == 87)
    }
  }

  func testUnwrapCaughtFailureThenAssertEqual88() throws {
    XCTAssertThrowsError(
      try { throw Failure(code: 88) }()
    ) { error in
      let failure = try? XCTUnwrap(error as? Failure)
      XCTAssert(failure?.code == 88)
    }
  }

  func testUnwrapCaughtFailureThenAssertEqual89() throws {
    XCTAssertThrowsError(
      try { throw Failure(code: 89) }()
    ) { error in
      let failure = try? XCTUnwrap(error as? Failure)
      XCTAssert(failure?.code == 89)
    }
  }

  func testUnwrapCaughtFailureThenAssertEqual90() throws {
    XCTAssertThrowsError(
      try { throw Failure(code: 90) }()
    ) { error in
      let failure = try? XCTUnwrap(error as? Failure)
      XCTAssert(failure?.code == 90)
    }
  }

  func testUnwrapCaughtFailureThenAssertEqual91() throws {
    XCTAssertThrowsError(
      try { throw Failure(code: 91) }()
    ) { error in
      let failure = try? XCTUnwrap(error as? Failure)
      XCTAssert(failure?.code == 91)
    }
  }

  func testUnwrapCaughtFailureThenAssertEqual92() throws {
    XCTAssertThrowsError(
      try { throw Failure(code: 92) }()
    ) { error in
      let failure = try? XCTUnwrap(error as? Failure)
      XCTAssert(failure?.code == 92)
    }
  }

  func testUnwrapCaughtFailureThenAssertEqual93() throws {
    XCTAssertThrowsError(
      try { throw Failure(code: 93) }()
    ) { error in
      let failure = try? XCTUnwrap(error as? Failure)
      XCTAssert(failure?.code == 93)
    }
  }

  func testUnwrapCaughtFailureThenAssertEqual94() throws {
    XCTAssertThrowsError(
      try { throw Failure(code: 94) }()
    ) { error in
      let failure = try? XCTUnwrap(error as? Failure)
      XCTAssert(failure?.code == 94)
    }
  }

  func testUnwrapCaughtFailureThenAssertEqual95() throws {
    XCTAssertThrowsError(
      try { throw Failure(code: 95) }()
    ) { error in
      let failure = try? XCTUnwrap(error as? Failure)
      XCTAssert(failure?.code == 95)
    }
  }

  func testUnwrapCaughtFailureThenAssertEqual96() throws {
    XCTAssertThrowsError(
      try { throw Failure(code: 96) }()
    ) { error in
      let failure = try? XCTUnwrap(error as? Failure)
      XCTAssert(failure?.code == 96)
    }
  }

  func testUnwrapCaughtFailureThenAssertEqual97() throws {
    XCTAssertThrowsError(
      try { throw Failure(code: 97) }()
    ) { error in
      let failure = try? XCTUnwrap(error as? Failure)
      XCTAssert(failure?.code == 97)
    }
  }

  func testUnwrapCaughtFailureThenAssertEqual98() throws {
    XCTAssertThrowsError(
      try { throw Failure(code: 98) }()
    ) { error in
      let failure = try? XCTUnwrap(error as? Failure)
      XCTAssert(failure?.code == 98)
    }
  }

  func testUnwrapCaughtFailureThenAssertEqual99() throws {
    XCTAssertThrowsError(
      try { throw Failure(code: 99) }()
    ) { error in
      let failure = try? XCTUnwrap(error as? Failure)
      XCTAssert(failure?.code == 99)
    }
  }

  func testUnwrapCaughtFailureThenAssertEqual100() throws {
    XCTAssertThrowsError(
      try { throw Failure(code: 100) }()
    ) { error in
      let failure = try? XCTUnwrap(error as? Failure)
      XCTAssert(failure?.code == 100)
    }
  }
}

extension ExpectFailureTests {
  struct Failure: Error {
    let code: Int
  }
}
