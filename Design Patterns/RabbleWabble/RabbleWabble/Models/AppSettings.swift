/// Copyright (c) 2024 Razeware LLC
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
/// 
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
/// 
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import Foundation

public class AppSettings {
  private struct Keys {
    static let questionStrategy = "questionStrategy"
  }
  let userDefault = UserDefaults.standard
  
  public static let shared = AppSettings()
  
  public var questionStrategyType: QuestionStrategyType {
    get {
      let rawValue = userDefault.integer(forKey: Keys.questionStrategy)
      return QuestionStrategyType(rawValue: rawValue)!
    }
    set {
      userDefault.setValue(newValue.rawValue, forKey: Keys.questionStrategy)
    }
  }
    
  private init() { }
  
  func questionStrategy(for questionGroupCaretaker: QuestionGroupCaretaker) -> QuestionStrategy {
    return questionStrategyType.questionStrategy(for: questionGroupCaretaker)
  }
}

public enum QuestionStrategyType: Int, CaseIterable {
  case random
  case sequential
  
  func title() -> String {
    switch self {
    case .random: return "Random"
    case .sequential: return "Sequential"
    }
  }
  
  func questionStrategy(for questionGroupCaretaker: QuestionGroupCaretaker) -> QuestionStrategy {
    switch self {
    case .random: return RandomQuestionStrategy(questionGroupCaretaker: questionGroupCaretaker)
    case .sequential: return SequentialQuestionStrategy(questionGroupCaretaker: questionGroupCaretaker)
    }
  }
}
