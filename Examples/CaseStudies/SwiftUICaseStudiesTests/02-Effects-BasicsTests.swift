import ComposableArchitecture
import XCTest

@testable import SwiftUICaseStudies

import SwiftUI

class EffectsBasicsTests: XCTestCase {
  func testCountUpAndDown() {
    let store = TestStore(
      initialState: EffectsBasicsState(),
      reducer: effectsBasicsReducer,
      environment: EffectsBasicsEnvironment(
        fact: .failing,
        mainQueue: .failing
      )
    )

    store.send(.incrementButtonTapped) {
      $0.count = 1
    }
    store.send(.decrementButtonTapped) {
      $0.count = 0
    }
  }

  func testNumberFact_HappyPath() {
    let store = TestStore(
      initialState: EffectsBasicsState(),
      reducer: effectsBasicsReducer,
      environment: EffectsBasicsEnvironment(
        fact: .failing,
        mainQueue: .failing
      )
    )

    store.environment.fact.fetchAsync = { n in "\(n) is a good number Brent" }
    store.environment.mainQueue = .immediate

    store.send(.incrementButtonTapped) {
      $0.count = 1
    }
    store.send(.numberFactButtonTapped) {
      $0.isNumberFactRequestInFlight = true
    }
    _ = XCTWaiter.wait(for: [.init()], timeout: 0.05)
    store.receive(.numberFactResponse(.success("1 is a good number Brent"))) {
       $0.isNumberFactRequestInFlight = false
      $0.numberFact = "1 is a good number Brent"
    }
  }

  func testNumberFact_Failing() {
    let store = TestStore(
      initialState: EffectsBasicsState(),
      reducer: effectsBasicsReducer,
      environment: EffectsBasicsEnvironment(
        fact: .failing,
        mainQueue: .failing
      )
    )

    store.environment.fact.fetch = { _ in .init(error: .init()) }
    store.environment.mainQueue = .immediate

    store.send(.incrementButtonTapped) {
      $0.count = 1
    }
    store.send(.numberFactButtonTapped) {
      $0.isNumberFactRequestInFlight = true
    }
    store.receive(.numberFactResponse(.failure(.init()))) {
      $0.isNumberFactRequestInFlight = false
    }
  }
}
