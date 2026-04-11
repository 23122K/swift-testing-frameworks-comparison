import Testing

@Suite
enum FooTests {
  case bar
  init() { self = .bar }
  
  @Test
  func baz() async throws {
    #expect(true)
  }
}

@Suite(.serialized)
struct ExpectFailureTests {
  @Test
  func unwrapCaughtFailureThenAssertEqual1() throws {
    let failure = #expect(throws: Failure.self) {
      throw Failure(code: 1)
    }
    
    let code = try #require(failure?.code)
    #expect(code == 1)
  }

  @Test
  func unwrapCaughtFailureThenAssertEqual2() throws {
    let failure = #expect(throws: Failure.self) {
      throw Failure(code: 2)
    }
    
    let code = try #require(failure?.code)
    #expect(code == 2)
  }

  @Test
  func unwrapCaughtFailureThenAssertEqual3() throws {
    let failure = #expect(throws: Failure.self) {
      throw Failure(code: 3)
    }
    
    let code = try #require(failure?.code)
    #expect(code == 3)
  }

  @Test
  func unwrapCaughtFailureThenAssertEqual4() throws {
    let failure = #expect(throws: Failure.self) {
      throw Failure(code: 4)
    }
    
    let code = try #require(failure?.code)
    #expect(code == 4)
  }

  @Test
  func unwrapCaughtFailureThenAssertEqual5() throws {
    let failure = #expect(throws: Failure.self) {
      throw Failure(code: 5)
    }
    
    let code = try #require(failure?.code)
    #expect(code == 5)
  }

  @Test
  func unwrapCaughtFailureThenAssertEqual6() throws {
    let failure = #expect(throws: Failure.self) {
      throw Failure(code: 6)
    }
    
    let code = try #require(failure?.code)
    #expect(code == 6)
  }

  @Test
  func unwrapCaughtFailureThenAssertEqual7() throws {
    let failure = #expect(throws: Failure.self) {
      throw Failure(code: 7)
    }
    
    let code = try #require(failure?.code)
    #expect(code == 7)
  }

  @Test
  func unwrapCaughtFailureThenAssertEqual8() throws {
    let failure = #expect(throws: Failure.self) {
      throw Failure(code: 8)
    }
    
    let code = try #require(failure?.code)
    #expect(code == 8)
  }

  @Test
  func unwrapCaughtFailureThenAssertEqual9() throws {
    let failure = #expect(throws: Failure.self) {
      throw Failure(code: 9)
    }
    
    let code = try #require(failure?.code)
    #expect(code == 9)
  }

  @Test
  func unwrapCaughtFailureThenAssertEqual10() throws {
    let failure = #expect(throws: Failure.self) {
      throw Failure(code: 10)
    }
    
    let code = try #require(failure?.code)
    #expect(code == 10)
  }

  @Test
  func unwrapCaughtFailureThenAssertEqual11() throws {
    let failure = #expect(throws: Failure.self) {
      throw Failure(code: 11)
    }
    
    let code = try #require(failure?.code)
    #expect(code == 11)
  }

  @Test
  func unwrapCaughtFailureThenAssertEqual12() throws {
    let failure = #expect(throws: Failure.self) {
      throw Failure(code: 12)
    }
    
    let code = try #require(failure?.code)
    #expect(code == 12)
  }

  @Test
  func unwrapCaughtFailureThenAssertEqual13() throws {
    let failure = #expect(throws: Failure.self) {
      throw Failure(code: 13)
    }
    
    let code = try #require(failure?.code)
    #expect(code == 13)
  }

  @Test
  func unwrapCaughtFailureThenAssertEqual14() throws {
    let failure = #expect(throws: Failure.self) {
      throw Failure(code: 14)
    }
    
    let code = try #require(failure?.code)
    #expect(code == 14)
  }

  @Test
  func unwrapCaughtFailureThenAssertEqual15() throws {
    let failure = #expect(throws: Failure.self) {
      throw Failure(code: 15)
    }
    
    let code = try #require(failure?.code)
    #expect(code == 15)
  }

  @Test
  func unwrapCaughtFailureThenAssertEqual16() throws {
    let failure = #expect(throws: Failure.self) {
      throw Failure(code: 16)
    }
    
    let code = try #require(failure?.code)
    #expect(code == 16)
  }

  @Test
  func unwrapCaughtFailureThenAssertEqual17() throws {
    let failure = #expect(throws: Failure.self) {
      throw Failure(code: 17)
    }
    
    let code = try #require(failure?.code)
    #expect(code == 17)
  }

  @Test
  func unwrapCaughtFailureThenAssertEqual18() throws {
    let failure = #expect(throws: Failure.self) {
      throw Failure(code: 18)
    }
    
    let code = try #require(failure?.code)
    #expect(code == 18)
  }

  @Test
  func unwrapCaughtFailureThenAssertEqual19() throws {
    let failure = #expect(throws: Failure.self) {
      throw Failure(code: 19)
    }
    
    let code = try #require(failure?.code)
    #expect(code == 19)
  }

  @Test
  func unwrapCaughtFailureThenAssertEqual20() throws {
    let failure = #expect(throws: Failure.self) {
      throw Failure(code: 20)
    }
    
    let code = try #require(failure?.code)
    #expect(code == 20)
  }

  @Test
  func unwrapCaughtFailureThenAssertEqual21() throws {
    let failure = #expect(throws: Failure.self) {
      throw Failure(code: 21)
    }
    
    let code = try #require(failure?.code)
    #expect(code == 21)
  }

  @Test
  func unwrapCaughtFailureThenAssertEqual22() throws {
    let failure = #expect(throws: Failure.self) {
      throw Failure(code: 22)
    }
    
    let code = try #require(failure?.code)
    #expect(code == 22)
  }

  @Test
  func unwrapCaughtFailureThenAssertEqual23() throws {
    let failure = #expect(throws: Failure.self) {
      throw Failure(code: 23)
    }
    
    let code = try #require(failure?.code)
    #expect(code == 23)
  }

  @Test
  func unwrapCaughtFailureThenAssertEqual24() throws {
    let failure = #expect(throws: Failure.self) {
      throw Failure(code: 24)
    }
    
    let code = try #require(failure?.code)
    #expect(code == 24)
  }

  @Test
  func unwrapCaughtFailureThenAssertEqual25() throws {
    let failure = #expect(throws: Failure.self) {
      throw Failure(code: 25)
    }
    
    let code = try #require(failure?.code)
    #expect(code == 25)
  }

  @Test
  func unwrapCaughtFailureThenAssertEqual26() throws {
    let failure = #expect(throws: Failure.self) {
      throw Failure(code: 26)
    }
    
    let code = try #require(failure?.code)
    #expect(code == 26)
  }

  @Test
  func unwrapCaughtFailureThenAssertEqual27() throws {
    let failure = #expect(throws: Failure.self) {
      throw Failure(code: 27)
    }
    
    let code = try #require(failure?.code)
    #expect(code == 27)
  }

  @Test
  func unwrapCaughtFailureThenAssertEqual28() throws {
    let failure = #expect(throws: Failure.self) {
      throw Failure(code: 28)
    }
    
    let code = try #require(failure?.code)
    #expect(code == 28)
  }

  @Test
  func unwrapCaughtFailureThenAssertEqual29() throws {
    let failure = #expect(throws: Failure.self) {
      throw Failure(code: 29)
    }
    
    let code = try #require(failure?.code)
    #expect(code == 29)
  }

  @Test
  func unwrapCaughtFailureThenAssertEqual30() throws {
    let failure = #expect(throws: Failure.self) {
      throw Failure(code: 30)
    }
    
    let code = try #require(failure?.code)
    #expect(code == 30)
  }

  @Test
  func unwrapCaughtFailureThenAssertEqual31() throws {
    let failure = #expect(throws: Failure.self) {
      throw Failure(code: 31)
    }
    
    let code = try #require(failure?.code)
    #expect(code == 31)
  }

  @Test
  func unwrapCaughtFailureThenAssertEqual32() throws {
    let failure = #expect(throws: Failure.self) {
      throw Failure(code: 32)
    }
    
    let code = try #require(failure?.code)
    #expect(code == 32)
  }

  @Test
  func unwrapCaughtFailureThenAssertEqual33() throws {
    let failure = #expect(throws: Failure.self) {
      throw Failure(code: 33)
    }
    
    let code = try #require(failure?.code)
    #expect(code == 33)
  }

  @Test
  func unwrapCaughtFailureThenAssertEqual34() throws {
    let failure = #expect(throws: Failure.self) {
      throw Failure(code: 34)
    }
    
    let code = try #require(failure?.code)
    #expect(code == 34)
  }

  @Test
  func unwrapCaughtFailureThenAssertEqual35() throws {
    let failure = #expect(throws: Failure.self) {
      throw Failure(code: 35)
    }
    
    let code = try #require(failure?.code)
    #expect(code == 35)
  }

  @Test
  func unwrapCaughtFailureThenAssertEqual36() throws {
    let failure = #expect(throws: Failure.self) {
      throw Failure(code: 36)
    }
    
    let code = try #require(failure?.code)
    #expect(code == 36)
  }

  @Test
  func unwrapCaughtFailureThenAssertEqual37() throws {
    let failure = #expect(throws: Failure.self) {
      throw Failure(code: 37)
    }
    
    let code = try #require(failure?.code)
    #expect(code == 37)
  }

  @Test
  func unwrapCaughtFailureThenAssertEqual38() throws {
    let failure = #expect(throws: Failure.self) {
      throw Failure(code: 38)
    }
    
    let code = try #require(failure?.code)
    #expect(code == 38)
  }

  @Test
  func unwrapCaughtFailureThenAssertEqual39() throws {
    let failure = #expect(throws: Failure.self) {
      throw Failure(code: 39)
    }
    
    let code = try #require(failure?.code)
    #expect(code == 39)
  }

  @Test
  func unwrapCaughtFailureThenAssertEqual40() throws {
    let failure = #expect(throws: Failure.self) {
      throw Failure(code: 40)
    }
    
    let code = try #require(failure?.code)
    #expect(code == 40)
  }

  @Test
  func unwrapCaughtFailureThenAssertEqual41() throws {
    let failure = #expect(throws: Failure.self) {
      throw Failure(code: 41)
    }
    
    let code = try #require(failure?.code)
    #expect(code == 41)
  }

  @Test
  func unwrapCaughtFailureThenAssertEqual42() throws {
    let failure = #expect(throws: Failure.self) {
      throw Failure(code: 42)
    }
    
    let code = try #require(failure?.code)
    #expect(code == 42)
  }

  @Test
  func unwrapCaughtFailureThenAssertEqual43() throws {
    let failure = #expect(throws: Failure.self) {
      throw Failure(code: 43)
    }
    
    let code = try #require(failure?.code)
    #expect(code == 43)
  }

  @Test
  func unwrapCaughtFailureThenAssertEqual44() throws {
    let failure = #expect(throws: Failure.self) {
      throw Failure(code: 44)
    }
    
    let code = try #require(failure?.code)
    #expect(code == 44)
  }

  @Test
  func unwrapCaughtFailureThenAssertEqual45() throws {
    let failure = #expect(throws: Failure.self) {
      throw Failure(code: 45)
    }
    
    let code = try #require(failure?.code)
    #expect(code == 45)
  }

  @Test
  func unwrapCaughtFailureThenAssertEqual46() throws {
    let failure = #expect(throws: Failure.self) {
      throw Failure(code: 46)
    }
    
    let code = try #require(failure?.code)
    #expect(code == 46)
  }

  @Test
  func unwrapCaughtFailureThenAssertEqual47() throws {
    let failure = #expect(throws: Failure.self) {
      throw Failure(code: 47)
    }
    
    let code = try #require(failure?.code)
    #expect(code == 47)
  }

  @Test
  func unwrapCaughtFailureThenAssertEqual48() throws {
    let failure = #expect(throws: Failure.self) {
      throw Failure(code: 48)
    }
    
    let code = try #require(failure?.code)
    #expect(code == 48)
  }

  @Test
  func unwrapCaughtFailureThenAssertEqual49() throws {
    let failure = #expect(throws: Failure.self) {
      throw Failure(code: 49)
    }
    
    let code = try #require(failure?.code)
    #expect(code == 49)
  }

  @Test
  func unwrapCaughtFailureThenAssertEqual50() throws {
    let failure = #expect(throws: Failure.self) {
      throw Failure(code: 50)
    }
    
    let code = try #require(failure?.code)
    #expect(code == 50)
  }

  @Test
  func unwrapCaughtFailureThenAssertEqual51() throws {
    let failure = #expect(throws: Failure.self) {
      throw Failure(code: 51)
    }
    
    let code = try #require(failure?.code)
    #expect(code == 51)
  }

  @Test
  func unwrapCaughtFailureThenAssertEqual52() throws {
    let failure = #expect(throws: Failure.self) {
      throw Failure(code: 52)
    }
    
    let code = try #require(failure?.code)
    #expect(code == 52)
  }

  @Test
  func unwrapCaughtFailureThenAssertEqual53() throws {
    let failure = #expect(throws: Failure.self) {
      throw Failure(code: 53)
    }
    
    let code = try #require(failure?.code)
    #expect(code == 53)
  }

  @Test
  func unwrapCaughtFailureThenAssertEqual54() throws {
    let failure = #expect(throws: Failure.self) {
      throw Failure(code: 54)
    }
    
    let code = try #require(failure?.code)
    #expect(code == 54)
  }

  @Test
  func unwrapCaughtFailureThenAssertEqual55() throws {
    let failure = #expect(throws: Failure.self) {
      throw Failure(code: 55)
    }
    
    let code = try #require(failure?.code)
    #expect(code == 55)
  }

  @Test
  func unwrapCaughtFailureThenAssertEqual56() throws {
    let failure = #expect(throws: Failure.self) {
      throw Failure(code: 56)
    }
    
    let code = try #require(failure?.code)
    #expect(code == 56)
  }

  @Test
  func unwrapCaughtFailureThenAssertEqual57() throws {
    let failure = #expect(throws: Failure.self) {
      throw Failure(code: 57)
    }
    
    let code = try #require(failure?.code)
    #expect(code == 57)
  }

  @Test
  func unwrapCaughtFailureThenAssertEqual58() throws {
    let failure = #expect(throws: Failure.self) {
      throw Failure(code: 58)
    }
    
    let code = try #require(failure?.code)
    #expect(code == 58)
  }

  @Test
  func unwrapCaughtFailureThenAssertEqual59() throws {
    let failure = #expect(throws: Failure.self) {
      throw Failure(code: 59)
    }
    
    let code = try #require(failure?.code)
    #expect(code == 59)
  }

  @Test
  func unwrapCaughtFailureThenAssertEqual60() throws {
    let failure = #expect(throws: Failure.self) {
      throw Failure(code: 60)
    }
    
    let code = try #require(failure?.code)
    #expect(code == 60)
  }

  @Test
  func unwrapCaughtFailureThenAssertEqual61() throws {
    let failure = #expect(throws: Failure.self) {
      throw Failure(code: 61)
    }
    
    let code = try #require(failure?.code)
    #expect(code == 61)
  }

  @Test
  func unwrapCaughtFailureThenAssertEqual62() throws {
    let failure = #expect(throws: Failure.self) {
      throw Failure(code: 62)
    }
    
    let code = try #require(failure?.code)
    #expect(code == 62)
  }

  @Test
  func unwrapCaughtFailureThenAssertEqual63() throws {
    let failure = #expect(throws: Failure.self) {
      throw Failure(code: 63)
    }
    
    let code = try #require(failure?.code)
    #expect(code == 63)
  }

  @Test
  func unwrapCaughtFailureThenAssertEqual64() throws {
    let failure = #expect(throws: Failure.self) {
      throw Failure(code: 64)
    }
    
    let code = try #require(failure?.code)
    #expect(code == 64)
  }

  @Test
  func unwrapCaughtFailureThenAssertEqual65() throws {
    let failure = #expect(throws: Failure.self) {
      throw Failure(code: 65)
    }
    
    let code = try #require(failure?.code)
    #expect(code == 65)
  }

  @Test
  func unwrapCaughtFailureThenAssertEqual66() throws {
    let failure = #expect(throws: Failure.self) {
      throw Failure(code: 66)
    }
    
    let code = try #require(failure?.code)
    #expect(code == 66)
  }

  @Test
  func unwrapCaughtFailureThenAssertEqual67() throws {
    let failure = #expect(throws: Failure.self) {
      throw Failure(code: 67)
    }
    
    let code = try #require(failure?.code)
    #expect(code == 67)
  }

  @Test
  func unwrapCaughtFailureThenAssertEqual68() throws {
    let failure = #expect(throws: Failure.self) {
      throw Failure(code: 68)
    }
    
    let code = try #require(failure?.code)
    #expect(code == 68)
  }

  @Test
  func unwrapCaughtFailureThenAssertEqual69() throws {
    let failure = #expect(throws: Failure.self) {
      throw Failure(code: 69)
    }
    
    let code = try #require(failure?.code)
    #expect(code == 69)
  }

  @Test
  func unwrapCaughtFailureThenAssertEqual70() throws {
    let failure = #expect(throws: Failure.self) {
      throw Failure(code: 70)
    }
    
    let code = try #require(failure?.code)
    #expect(code == 70)
  }

  @Test
  func unwrapCaughtFailureThenAssertEqual71() throws {
    let failure = #expect(throws: Failure.self) {
      throw Failure(code: 71)
    }
    
    let code = try #require(failure?.code)
    #expect(code == 71)
  }

  @Test
  func unwrapCaughtFailureThenAssertEqual72() throws {
    let failure = #expect(throws: Failure.self) {
      throw Failure(code: 72)
    }
    
    let code = try #require(failure?.code)
    #expect(code == 72)
  }

  @Test
  func unwrapCaughtFailureThenAssertEqual73() throws {
    let failure = #expect(throws: Failure.self) {
      throw Failure(code: 73)
    }
    
    let code = try #require(failure?.code)
    #expect(code == 73)
  }

  @Test
  func unwrapCaughtFailureThenAssertEqual74() throws {
    let failure = #expect(throws: Failure.self) {
      throw Failure(code: 74)
    }
    
    let code = try #require(failure?.code)
    #expect(code == 74)
  }

  @Test
  func unwrapCaughtFailureThenAssertEqual75() throws {
    let failure = #expect(throws: Failure.self) {
      throw Failure(code: 75)
    }
    
    let code = try #require(failure?.code)
    #expect(code == 75)
  }

  @Test
  func unwrapCaughtFailureThenAssertEqual76() throws {
    let failure = #expect(throws: Failure.self) {
      throw Failure(code: 76)
    }
    
    let code = try #require(failure?.code)
    #expect(code == 76)
  }

  @Test
  func unwrapCaughtFailureThenAssertEqual77() throws {
    let failure = #expect(throws: Failure.self) {
      throw Failure(code: 77)
    }
    
    let code = try #require(failure?.code)
    #expect(code == 77)
  }

  @Test
  func unwrapCaughtFailureThenAssertEqual78() throws {
    let failure = #expect(throws: Failure.self) {
      throw Failure(code: 78)
    }
    
    let code = try #require(failure?.code)
    #expect(code == 78)
  }

  @Test
  func unwrapCaughtFailureThenAssertEqual79() throws {
    let failure = #expect(throws: Failure.self) {
      throw Failure(code: 79)
    }
    
    let code = try #require(failure?.code)
    #expect(code == 79)
  }

  @Test
  func unwrapCaughtFailureThenAssertEqual80() throws {
    let failure = #expect(throws: Failure.self) {
      throw Failure(code: 80)
    }
    
    let code = try #require(failure?.code)
    #expect(code == 80)
  }

  @Test
  func unwrapCaughtFailureThenAssertEqual81() throws {
    let failure = #expect(throws: Failure.self) {
      throw Failure(code: 81)
    }
    
    let code = try #require(failure?.code)
    #expect(code == 81)
  }

  @Test
  func unwrapCaughtFailureThenAssertEqual82() throws {
    let failure = #expect(throws: Failure.self) {
      throw Failure(code: 82)
    }
    
    let code = try #require(failure?.code)
    #expect(code == 82)
  }

  @Test
  func unwrapCaughtFailureThenAssertEqual83() throws {
    let failure = #expect(throws: Failure.self) {
      throw Failure(code: 83)
    }
    
    let code = try #require(failure?.code)
    #expect(code == 83)
  }

  @Test
  func unwrapCaughtFailureThenAssertEqual84() throws {
    let failure = #expect(throws: Failure.self) {
      throw Failure(code: 84)
    }
    
    let code = try #require(failure?.code)
    #expect(code == 84)
  }

  @Test
  func unwrapCaughtFailureThenAssertEqual85() throws {
    let failure = #expect(throws: Failure.self) {
      throw Failure(code: 85)
    }
    
    let code = try #require(failure?.code)
    #expect(code == 85)
  }

  @Test
  func unwrapCaughtFailureThenAssertEqual86() throws {
    let failure = #expect(throws: Failure.self) {
      throw Failure(code: 86)
    }
    
    let code = try #require(failure?.code)
    #expect(code == 86)
  }

  @Test
  func unwrapCaughtFailureThenAssertEqual87() throws {
    let failure = #expect(throws: Failure.self) {
      throw Failure(code: 87)
    }
    
    let code = try #require(failure?.code)
    #expect(code == 87)
  }

  @Test
  func unwrapCaughtFailureThenAssertEqual88() throws {
    let failure = #expect(throws: Failure.self) {
      throw Failure(code: 88)
    }
    
    let code = try #require(failure?.code)
    #expect(code == 88)
  }

  @Test
  func unwrapCaughtFailureThenAssertEqual89() throws {
    let failure = #expect(throws: Failure.self) {
      throw Failure(code: 89)
    }
    
    let code = try #require(failure?.code)
    #expect(code == 89)
  }

  @Test
  func unwrapCaughtFailureThenAssertEqual90() throws {
    let failure = #expect(throws: Failure.self) {
      throw Failure(code: 90)
    }
    
    let code = try #require(failure?.code)
    #expect(code == 90)
  }

  @Test
  func unwrapCaughtFailureThenAssertEqual91() throws {
    let failure = #expect(throws: Failure.self) {
      throw Failure(code: 91)
    }
    
    let code = try #require(failure?.code)
    #expect(code == 91)
  }

  @Test
  func unwrapCaughtFailureThenAssertEqual92() throws {
    let failure = #expect(throws: Failure.self) {
      throw Failure(code: 92)
    }
    
    let code = try #require(failure?.code)
    #expect(code == 92)
  }

  @Test
  func unwrapCaughtFailureThenAssertEqual93() throws {
    let failure = #expect(throws: Failure.self) {
      throw Failure(code: 93)
    }
    
    let code = try #require(failure?.code)
    #expect(code == 93)
  }

  @Test
  func unwrapCaughtFailureThenAssertEqual94() throws {
    let failure = #expect(throws: Failure.self) {
      throw Failure(code: 94)
    }
    
    let code = try #require(failure?.code)
    #expect(code == 94)
  }

  @Test
  func unwrapCaughtFailureThenAssertEqual95() throws {
    let failure = #expect(throws: Failure.self) {
      throw Failure(code: 95)
    }
    
    let code = try #require(failure?.code)
    #expect(code == 95)
  }

  @Test
  func unwrapCaughtFailureThenAssertEqual96() throws {
    let failure = #expect(throws: Failure.self) {
      throw Failure(code: 96)
    }
    
    let code = try #require(failure?.code)
    #expect(code == 96)
  }

  @Test
  func unwrapCaughtFailureThenAssertEqual97() throws {
    let failure = #expect(throws: Failure.self) {
      throw Failure(code: 97)
    }
    
    let code = try #require(failure?.code)
    #expect(code == 97)
  }

  @Test
  func unwrapCaughtFailureThenAssertEqual98() throws {
    let failure = #expect(throws: Failure.self) {
      throw Failure(code: 98)
    }
    
    let code = try #require(failure?.code)
    #expect(code == 98)
  }

  @Test
  func unwrapCaughtFailureThenAssertEqual99() throws {
    let failure = #expect(throws: Failure.self) {
      throw Failure(code: 99)
    }
    
    let code = try #require(failure?.code)
    #expect(code == 99)
  }

  @Test
  func unwrapCaughtFailureThenAssertEqual100() throws {
    let failure = #expect(throws: Failure.self) {
      throw Failure(code: 100)
    }
    
    let code = try #require(failure?.code)
    #expect(code == 100)
  }
}

extension ExpectFailureTests {
  struct Failure: Error {
    let code: Int
  }
}
