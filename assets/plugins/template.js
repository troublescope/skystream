(function() {
    /**
     * @typedef {Object} Response
     * @property {boolean} success
     * @property {any} [data]
     * @property {string} [errorCode]
     * @property {string} [message]
     */

    /**
     * @type {import('@skystream/sdk').Manifest}
     */
    const pluginManifest = manifest;

    /**
     * Loads the home screen categories.
     * @param {(res: Response) => void} cb
     */
    async function getHome(cb) {
        try {
            cb({
                success: true,
                data: {
                    "Trending Movies": [
                        new MultimediaItem({
                            title: "Interstellar Voyage",
                            url: "https://example.com/movie/interstellar",
                            posterUrl: "https://placehold.co/600x900.png?text=Interstellar&bg=1e293b&clr=ffffff",
                            type: "movie",
                            bannerUrl: "https://placehold.co/1280x720.png?text=Space+Banner&bg=1e293b&clr=ffffff",
                            description: "A team of explorers travel through a wormhole in space in an attempt to ensure humanity's survival."
                        }),
                        new MultimediaItem({
                            title: "Cyberpunk 2077",
                            url: "https://example.com/movie/cyberpunk",
                            posterUrl: "https://placehold.co/600x900.png?text=Cyberpunk&bg=4c1d95&clr=ffffff",
                            type: "movie",
                            description: "In a world of high tech and low life, one mercenary takes on the corporate overlords."
                        })
                    ],
                    "Popular Series": [
                        new MultimediaItem({
                            title: "Nexus Chronicles",
                            url: "https://example.com/series/nexus",
                            posterUrl: "https://placehold.co/600x900.png?text=Nexus&bg=064e3b&clr=ffffff",
                            type: "series",
                            description: "The story of a digital civilization living inside a quantum computer."
                        })
                    ]
                }
            });
        } catch (e) {
            cb({ success: false, errorCode: "HOME_ERROR", message: String(e) });
        }
    }

    /**
     * Searches for media items.
     * @param {string} query
     * @param {(res: Response) => void} cb
     */
    async function search(query, cb) {
        try {
            cb({
                success: true,
                data: [
                    new MultimediaItem({
                        title: `Result for ${query}`,
                        url: "https://example.com/search?q=${encodeURIComponent(query)}",
                        posterUrl: "https://placehold.co/600x900.png?text=${encodeURIComponent(query)}&bg=1e1e1e&clr=ffffff",
                        type: "movie"
                    })
                ]
            });
        } catch (e) {
            cb({ success: false, errorCode: "SEARCH_ERROR", message: String(e) });
        }
    }

    /**
     * Loads details for a specific media item.
     * @param {string} url
     * @param {(res: Response) => void} cb
     */
    function load(url, cb) {
        try {
            cb({
                success: true,
                data: new MultimediaItem({
                    title: "Quantum Leap: The Movie",
                    url: url,
                    posterUrl: "https://placehold.co/600x900.png?text=Quantum+Leap&bg=1a1a1a&clr=ffffff",
                    type: "series", // Change to series to show episodes in UI
                    bannerUrl: "https://placehold.co/1280x720.png?text=Hero+Banner&bg=1a1a1a&clr=ffffff",
                    description: "Full detailed plot description of the Quantum Leap movie goes here. Dramatic tension and sci-fi wonder await.",
                    episodes: [
                        new Episode({
                            name: "Part 1: The Beginning",
                            url: "https://example.com/watch/part1",
                            season: 1,
                            episode: 1,
                            posterUrl: "https://placehold.co/640x360.png?text=Episode+1&bg=2c3e50&clr=ffffff",
                            description: "In the first part, we uncover the mystery of the quantum drift."
                        }),
                        new Episode({
                            name: "Part 2: The End",
                            url: "https://example.com/watch/part2",
                            season: 1,
                            episode: 2,
                            posterUrl: "https://placehold.co/640x360.png?text=Episode+2&bg=2c3e50&clr=ffffff",
                            description: "The final resolution of the drift and the fate of reality."
                        })
                    ]
                })
            });
        } catch (e) {
            cb({ success: false, errorCode: "LOAD_ERROR", message: String(e) });
        }
    }

    /**
     * Resolves streams for a specific media item or episode.
     * @param {string} url
     * @param {(res: Response) => void} cb
     */
    async function loadStreams(url, cb) {
        try {
            cb({
                success: true,
                data: [
                    new StreamResult({
                        url: "https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8",
                        quality: "1080p (HLS)"
                    }),
                    new StreamResult({
                        url: "https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8",
                        quality: "720p (HLS)"
                    })
                ]
            });
        } catch (e) {
            cb({ success: false, errorCode: "STREAM_ERROR", message: String(e) });
        }
    }

    // Export to global scope
    globalThis.getHome = getHome;
    globalThis.search = search;
    globalThis.load = load;
    globalThis.loadStreams = loadStreams;
})();
