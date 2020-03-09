/**
 Podcast.swift
 Copyright (c) 2020 Callum Kerr-Edwards
 Licensed under the MIT license.
 */

open class Podcast {
    // MARK: - Properties

    let title: String
    let link: String
    private var block: Bool?
    private var explicit: Bool?
    private var languageCode: String?
    private var author: String?
    private var copyright: String?
    private var summary: String?
    private var subtitle: String?
    private var owner: (String, String)?
    private var imageLink: String?
    private var categories: [(name: String, subcategory: String?)] = []
    private var episodes: [Episode] = []

    // MARK: - init

    public init(title: String, link: String) {
        self.title = title
        self.link = link
    }

    // MARK: - builder functions

    @discardableResult
    open func blockFromITunes(_ block: Bool? = true) -> Self {
        self.block = block
        return self
    }

    @discardableResult
    open func containsExplicitMaterial(_ explicit: Bool? = true) -> Self {
        self.explicit = explicit
        return self
    }

    @discardableResult
    open func withLanguageCode(_ code: String?) -> Self {
        languageCode = code
        return self
    }

    @discardableResult
    open func withLanguage(_ language: Language?) -> Self {
        withLanguageCode(language?.rawValue)
        return self
    }

    @discardableResult
    open func withAuthor(_ author: String?) -> Self {
        self.author = author
        return self
    }

    @discardableResult
    open func withCopyrightInfo(_ copyright: String?) -> Self {
        self.copyright = copyright
        return self
    }

    @discardableResult
    open func withSummary(_ summary: String?) -> Self {
        self.summary = summary
        return self
    }

    @discardableResult
    open func withSubtitle(_ subtitle: String?) -> Self {
        self.subtitle = subtitle
        return self
    }

    @discardableResult
    open func withOwner(name: String, email: String) -> Self {
        owner = (name, email)
        return self
    }

    @discardableResult
    open func withImage(link: String?) -> Self {
        imageLink = link
        return self
    }

    @discardableResult
    open func withCategory(name: String, subcategory: String? = nil) -> Self {
        categories.append((name: name, subcategory: subcategory))
        return self
    }

    @discardableResult
    open func withCategory(_ category: Category) -> Self {
        withCategory(name: category.parent, subcategory: category.subcategory)
    }

    @discardableResult
    open func withEpisode(_ episode: Episode) -> Self {
        episodes.append(episode)
        return self
    }

    @discardableResult
    open func withEpisodes(_ episodes: Episode...) -> Self {
        for episode in episodes {
            withEpisode(episode)
        }
        return self
    }

    @discardableResult
    open func withEpisodes(_ episodes: [Episode]) -> Self {
        self.episodes = episodes
        return self
    }

    // MARK: - Building RSS Feed

    open func getFeed() -> String {
        let attributes = ["xmlns:itunes": "http://www.itunes.com/dtds/podcast-1.0.dtd",
                          "xmlns:content": "http://purl.org/rss/1.0/modules/content/",
                          "version": "2.0"]
        let podcastFeed = RSSFeed(attributes: attributes)
        let channel = podcastFeed.addChild(name: "channel")
        channel.addChild(name: "title", value: title)
        channel.addChild(name: "link", value: link)
        if let languageCode: String = languageCode {
            channel.addChild(name: "language", value: languageCode)
        }
        if let copyright: String = copyright {
            channel.addChild(name: "copyright", value: copyright)
        }
        if let subtitle: String = subtitle {
            channel.addChild(name: "itunes:subtitle", value: subtitle)
        }
        if let author: String = author {
            channel.addChild(name: "itunes:author", value: author)
        }
        if let summary: String = summary {
            channel.addChild(name: "itunes:summary", value: summary)
            channel.addChild(name: "description", value: summary)
        }
        if let owner: (name: String, email: String) = owner {
            let ownerNode = channel.addChild(name: "itunes:owner")
            ownerNode.addChild(name: "itunes:name", value: owner.name)
            ownerNode.addChild(name: "itunes:email", value: owner.email)
        }
        if let imageLink: String = imageLink {
            channel.addChild(name: "itunes:image", attributes: ["href": imageLink])
        }
        for category in categories {
            if channel.hasChild(name: "itunes:category", attributes: ["text": category.name]) {
                if let subcategory: String = category.subcategory {
                    channel.getChild(name: "itunes:category", attributes: ["text": category.name])!
                        .addChild(name: "itunes:category",
                                  attributes: ["text": subcategory])
                }
            } else {
                let categoryNode = channel.addChild(name: "itunes:category",
                                                    attributes: ["text": category.name])
                if let subcategory: String = category.subcategory {
                    categoryNode.addChild(name: "itunes:category",
                                          attributes: ["text": subcategory])
                }
            }
        }
        if let explicit: Bool = explicit {
            if explicit {
                channel.addChild(name: "itunes:explicit", value: "yes")
            } else {
                channel.addChild(name: "itunes:explicit", value: "no")
            }
        }
        if let block: Bool = block {
            if block {
                channel.addChild(name: "itunes:block", value: "Yes")
            }
        }
        for episode in episodes.sorted(by: { $0.publicationDate > $1.publicationDate }) {
            channel.addChild(episode.getNode())
        }
        return podcastFeed.xml
    }
}
