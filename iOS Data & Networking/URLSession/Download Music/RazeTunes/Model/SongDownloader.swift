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

class SongDownloader: ObservableObject {
  @Published var downloadLocation: URL?
  
  // MARK: Artwork Download Error
  enum ArtworkDownloadError: Error {
    case failedToDownloadArtwork
    case invalidResponse
  }
  
  // MARK: Song Download Error
  enum SongDownloaderError: Error {
    case documentDirectoryError
    case failedToStoreSong
    case invalidResponse
  }
  
  private let session: URLSession
  private let sessionConfiguration: URLSessionConfiguration
  
  init() {
    sessionConfiguration = URLSessionConfiguration.default
    session = URLSession(configuration: sessionConfiguration)
  }

  // MARK: Functions
  //download image
  func downloadArtwork(at url: URL) async throws -> Data {
    let (downloadURL, response) = try await session.download(from: url)
    
    guard response is HTTPURLResponse else {
      throw ArtworkDownloadError.invalidResponse
    }
    
    do {
      return try Data(contentsOf: downloadURL)
    } catch {
      throw ArtworkDownloadError.failedToDownloadArtwork
    }
  }
  
  // download song
  func downloadSong(at url: URL) async throws {
    let (downloadURL, response) = try await session.download(from: url)
    
    guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
      throw SongDownloaderError.invalidResponse
    }
    
    let fileManager = FileManager.default
    
    guard let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
      throw SongDownloaderError.documentDirectoryError
    }
    
    let lastPathComponent = url.lastPathComponent
    let destinationURL = documentsPath.appendingPathComponent(lastPathComponent)
    
    do {
      if fileManager.fileExists(atPath: destinationURL.path) {
        try fileManager.removeItem(at: destinationURL)
      }
      
      try fileManager.copyItem(at: downloadURL, to: destinationURL)
      
      await MainActor.run(body: {
        downloadLocation = destinationURL // since downloadLocation is published property it may change UI so update this property in main thread
      })
    } catch {
      throw SongDownloaderError.failedToStoreSong
    }
  }
  
  
  // Grouping Resquest (download song and image together)
  func download(songAt songURL: URL, artworkAt artworkURL: URL) async throws -> Data {
    typealias Download = (_ url: URL, _ response: URLResponse)
    
    async let song: Download = try session.download(from: songURL)
    async let artwork: Download = try session.download(from: artworkURL)
    
    let (songDownload, artworkDownload) = try await (song, artwork)
    
    guard let songHttpRespose = songDownload.response as? HTTPURLResponse, let artworkHttpResponse = artworkDownload.response as? HTTPURLResponse, songHttpRespose.statusCode == 200, artworkHttpResponse.statusCode == 200 else {
      throw SongDownloaderError.invalidResponse
    }
    
    let fileManager = FileManager.default
    
    guard let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
      throw SongDownloaderError.documentDirectoryError
    }
    
    let lastPathComponent = songURL.lastPathComponent
    let destinationURL = documentsPath.appendingPathComponent(lastPathComponent)
    
    do {
      if fileManager.fileExists(atPath: destinationURL.path) {
        try fileManager.removeItem(at: destinationURL)
      }
      
      try fileManager.copyItem(at: songDownload.url, to: destinationURL)
      
      await MainActor.run(body: {
        downloadLocation = destinationURL // since downloadLocation is published property it may change UI so update this property in main thread
      })
    } catch {
      throw SongDownloaderError.failedToStoreSong
    }
    
    do {
      return try Data(contentsOf: artworkDownload.url)
    } catch {
      throw ArtworkDownloadError.failedToDownloadArtwork
    }
  }
  
  // data for progress bar
  func downloadSongBytes(at url: URL, progress: Binding<Float>) async throws {
    let (asyncBytes, response) = try await session.bytes(from: url)
    
    let contentLength = Float(response.expectedContentLength)
    var data = Data(capacity: Int(contentLength))
    
    for try await byte in asyncBytes {
      data.append(byte)
      let currentProgress = Float(data.count) / contentLength
      
      if Int(progress.wrappedValue*100) != Int(currentProgress*100) {
        progress.wrappedValue = currentProgress
      }
    }
    
    let fileManager = FileManager.default
    
    guard let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
      throw SongDownloaderError.documentDirectoryError
    }
    
    let lastPathComponent = url.lastPathComponent
    let destinationURL = documentsPath.appendingPathComponent(lastPathComponent)
    
    do {
      if fileManager.fileExists(atPath: destinationURL.path) {
        try fileManager.removeItem(at: destinationURL)
      }
      
      try data.write(to: destinationURL)
      
      await MainActor.run(body: {
        downloadLocation = destinationURL // since downloadLocation is published property it may change UI so update this property in main thread
      })
    } catch {
      throw SongDownloaderError.failedToStoreSong
    }
  }
}
