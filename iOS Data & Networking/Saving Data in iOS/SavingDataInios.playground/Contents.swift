import UIKit
import Foundation

let remindersDataURL = URL(fileURLWithPath: "Reminders", relativeTo: FileManager.documentDirectoryURL)
remindersDataURL.path

let stringURL = FileManager.documentDirectoryURL
    .appendingPathComponent("String")
    .appendingPathExtension("txt")
stringURL.path
