/**
 PodcastFeedKitTests.swift
 Copyright (c) 2020 Callum Kerr-Edwards
 Licensed under the MIT license.
 */

@testable import PodcastFeedKit
/**
 PodcastFeedKitTests.swift
 PodcastFeedKit
 Copyright (c) 2020 Callum Kerr-Edwards
 */
import XCTest

// MARK: - Start of Test

final class PodcastFeedKitTests: XCTestCase {
    func testFullFeedGeneration() {
        var expectedOutput: String?

        do {
            // MARK: - Expected Full RSS XML

            let expectedOutputFile = try Resource(name: "feed", type: "rss").url
            print(expectedOutputFile)
            expectedOutput = try String(contentsOf: expectedOutputFile, encoding: .utf8)

        } catch {
            print(error)
            XCTFail()
        }

        do {
            // MARK: - Episode One

            let demoM4AURL: URL = try! Resource(name: "demo", type: "m4a").url
            let episodeOne = try Episode(title: "My first episode",
                                         publicationDate: getDemoDate(year: 2020, month: 1, day: 1),
                                         audioFile: demoM4AURL,
                                         fileServerLocation: "http://demo.url/ep1/file.m4a")

                .withAuthor("John Doe")
                .withSubtitle("A short episode")
                .withImage(link: "http://demo.url/ep1/artwork.jpg")
                .withShortSummary("A short description")
                .withLongSummary("<h1>A short episode</h1><p>A short description</p>")
                .containsExplicitMaterial(false)

            // MARK: - Episode Two

            let demoMP3URL: URL = try! Resource(name: "demo", type: "mp3").url
            let episodeTwo = try Episode(title: "My second episode",
                                         publicationDate: getDemoDate(year: 2020, month: 1, day: 9),
                                         audioFile: demoMP3URL,
                                         fileServerLocation: "http://demo.url/ep2/file.mp3")

                .withAuthor("Jane Appleseed")
                .withSubtitle("Another episode")
                .withImage(link: "http://demo.url/ep2/artwork.jpg")
                .withGUID("demo-uniqure-id")

            // MARK: - Episode Three

            let demoM4BURL: URL = try! Resource(name: "demo", type: "m4b").url
            let episodeThree = try Episode(title: "My third episode",
                                           publicationDate: getDemoDate(year: 2020, month: 1, day: 17),
                                           audioFile: demoM4BURL,
                                           fileServerLocation: "http://demo.url/ep3/file.m4b")

                .withAuthor("Jane Appleseed")
                .withSubtitle("A new episode")
                .withShortSummary("About time for another new episode")
                .withImage(link: "http://demo.url/ep3/artwork.jpg")

            // MARK: - Podcast

            let podcast = Podcast(title: "Test Podcast Title",
                                  link: "https://demo.url/feed.rss")
                .containsExplicitMaterial()
                .withLanguage(.english)
                .withAuthor("Jane Appleseed & Friends")
                .withOwner(name: "Jane Appleseed",
                           email: "jane.appleseed@example.com")
                .withImage(link: "http://demo.url/artwork.jpg")
                .withCopyrightInfo("Copyright by Jane Appleseed")
                .withSummary("A really great podcast to listen to.")
                .withCategory(.books)
                .withCategory(.tvReviews)
                .withCategory(.filmReviews)
                .withCategory(.technology)
                .withSubtitle("A show about things")
                .withEpisodes(episodeOne, episodeTwo, episodeThree)

            // MARK: - Assertion

            XCTAssertEqual(podcast.getFeed() + "\n", expectedOutput)

        } catch {
            print(error)
            XCTFail()
        }
    }

    static var allTests = [
        ("testFullFeedGeneration", testFullFeedGeneration),
    ]
}

// MARK: - Helpers

private func getDemoDate(year: Int, month: Int, day: Int) -> Date {
    // Specify date components
    var dateComponents = DateComponents()
    dateComponents.year = year
    dateComponents.month = month
    dateComponents.day = day
    dateComponents.hour = 8
    dateComponents.timeZone = TimeZone(identifier: "UTC")!

    return Calendar(identifier: Calendar.Identifier.iso8601)
        .date(from: dateComponents)!
}

struct Resource {
    let name: String
    let type: String
    let url: URL

    init(name: String, type: String, sourceFile: StaticString = #file) throws {
        self.name = name
        self.type = type

        let testCaseURL = URL(fileURLWithPath: "\(sourceFile)", isDirectory: false)
        let testsFolderURL = testCaseURL.deletingLastPathComponent()
        let resourcesFolderURL = testsFolderURL.deletingLastPathComponent()
            .appendingPathComponent("Resources", isDirectory: true)
        url = resourcesFolderURL.appendingPathComponent("\(name).\(type)", isDirectory: false)
        if !FileManager.default.fileExists(atPath: url.path) {
            fatalError("\(url.path) does not exist.")
        }
    }
}
