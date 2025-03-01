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
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import SwiftUI

class MutableSongDownloader: NSObject, ObservableObject {
  enum State {
    case paused
    case downloading
    case failed
    case finished
    case waiting
  }
  
  @Published var downloadLocation: URL?
  @Published var downloadProgress: Float = 0.0
  
  private var dowloadURL: URL?
  private var downloadTask: URLSessionDownloadTask?
  private var resumeData: Data?
  
  var state: State = .waiting
  
  private lazy var session: URLSession = {
    let configuration = URLSessionConfiguration.default
    
    return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
  }()
  
  func downloadSong(at url: URL) {
    dowloadURL = url
    
    downloadTask = session.downloadTask(with: url)
    downloadTask?.resume()
    
    state = .downloading
  }
  
  func cancel() {
    state = .waiting
    
    downloadTask?.cancel()
    
    Task {
      await MainActor.run {
        downloadProgress = 0.0
      }
    }
  }
  
  func pause() {
    downloadTask?.cancel(byProducingResumeData: { data in
      Task {
        await MainActor.run {
          self.state = .paused
          self.resumeData = data
          self.downloadProgress = self.downloadProgress
        }
      }
    })
  }
  
  func resume() {
    guard let resumeData = resumeData else {
      return
    }
    
    downloadTask = session.downloadTask(withResumeData: resumeData)
    downloadTask?.resume()
    
    state = .downloading
  }
}

extension MutableSongDownloader: URLSessionDownloadDelegate {
  func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
    Task {
      await MainActor.run {
          downloadProgress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
      }
    }
  }
  
  func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
    let fileManager = FileManager.default
    
    guard let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first, let lastPathComponent = dowloadURL?.lastPathComponent else {
      Task {
        await MainActor.run {
          state = .failed
        }
      }
      return
    }
    
    let destinationUrl = documentsPath.appendingPathComponent(lastPathComponent)
    
    do {
      if fileManager.fileExists(atPath: destinationUrl.path) {
        try fileManager.removeItem(atPath: destinationUrl.path)
      }
      
      try fileManager.copyItem(at: location, to: destinationUrl)
      
      Task {
        await MainActor.run {
          downloadLocation = destinationUrl
          state = .finished
        }
      }
    } catch {
      Task {
        await MainActor.run {
          state = .failed
        }
      }
    }
  }
  
  func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
    Task {
      await MainActor.run {
        if let httpsResponse = task.response as? HTTPURLResponse, httpsResponse.statusCode != 200 {
          print("Request failed")
          state = .failed 
        }
      }
    }
  }
  
  
}
