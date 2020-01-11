import AEXML

class Podcast {
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

   init(title: String,
        link: String) {
       self.title = title
       self.link = link
   }

    func blockFromITunes(_ block: Bool? = true) -> Self {
        self.block = block
        return self
    }

    func containsExplicitMaterial(_ explicit: Bool? = true) -> Self {
        self.explicit = explicit
        return self
    }

    func withLanguageCode(_ code: String?) -> Self {
        self.languageCode = code
        return self
    }

    func withAuthor(_ author: String?) -> Self {
    	self.author = author
	return self
    }

    func withCopyrightInfo(_ copyright: String?) -> Self {
        self.copyright = copyright
        return self
    }

    func withSummary(_ summary: String?) -> Self {
        self.summary = summary
        return self
    }

    func withSubtitle(_ subtitle: String?) -> Self {
        self.subtitle = subtitle
        return self
    }

    func withOwner(name: String, email: String) -> Self {
        self.owner = (name, email)
        return self
    }

    func withImage(link: String?) -> Self {
        self.imageLink = link
        return self
    }

    func getFeed() -> String {
        let podcastFeed = AEXMLDocument()
        let attributes = ["xmlns:itunes": "http://www.itunes.com/dtds/podcast-1.0.dtd", "version": "2.0"]
        let rss = podcastFeed.addChild(name: "rss", attributes: attributes)
        let channel = rss.addChild(name: "channel")
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
        if let owner: (String, String) = owner {
            let ownerNode = channel.addChild(name: "itunes:owner")
            ownerNode.addChild(name: "itunes:name", value: owner.0)
            ownerNode.addChild(name: "itunes:email", value: owner.1)
        }
        if let imageLink: String = imageLink {
            channel.addChild(name: "itunes:image", attributes: ["href": imageLink])
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
        return podcastFeed.xml.replacingOccurrences(of: "\t", with: "    ")
    }
}
