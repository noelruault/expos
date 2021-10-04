# Golang Coding challenge

The dev team created this coding challenge to help assess your coding and problem-solving skills. Along with this file, you should find an archive with the code of the project to complete.

## The Project

The project contains a simple HTTP service that simulates a news API.

### Content

- The content itself is fetched from multiple providers (those could be 3rd party APIs, internal services, or database connections).
- Content providers are represented by the `Provider` type. And the API has a mapping between providers and `Clients`, which are used to fetch content.

### Content configuration

- The API has set a configuration, which represents the repeating sequence of providers to use.
If the sequence is `[Provider1, Provider2, Provider3]` and the user requests five (5) articles, the response should contain items from `[Provider1, Provider2, Provider3, Provider1, Provider2]` in that order.

In addition,

- If a provider fails to deliver content, the configuration might contain a fallback to use instead.
- If both, the main provider and the fallback fail (or if the main provider fails and there is no fallback), the API should respond with all the items before that point. So, for example, if the configuration calls for `[1,1,2,3]` and `2` fails, the response should only contain `[1,1]`.

## The Interface

The API responds to GET requests with 2 URL parameters:

- `count` represents the number of items desired
- `offset` represents the number of items previously requested. The configuration should be offset by this number.

The expected response is a list of content items, each one being a JSON representation of the `ContentItem` struct, found in `content.go`

Example request/response:

```text
    Request:
    http '127.0.0.1:8080/?count=3&offset=10'

    Response:
    HTTP/1.1 200 OK
    Content-Length: 385
    Content-Type: application/json
    Date: Thu, 24 Sep 2020 10:47:11 GMT
```

```json
[
    {
        "expiry": "2020-09-24T11:47:11.204318471+01:00",
        "id": "5577006791947779410",
        "link": "",
        "source": "1",
        "summary": "",
        "title": "title"
    },
    {
        "expiry": "2020-09-24T11:47:11.204324536+01:00",
        "id": "8674665223082153551",
        "link": "",
        "source": "1",
        "summary": "",
        "title": "title"
    },
    {
        "expiry": "2020-09-24T11:47:11.204326896+01:00",
        "id": "6129484611666145821",
        "link": "",
        "source": "2",
        "summary": "",
        "title": "title"
    }
]
```

## Instructions

1. Complete the `ServeHTTP` method in `server.go` in accordance with the specifications above.
2. Run existing tests, and make sure they all pass.
3. Add some tests to catch missing edge cases. For example, check that fallbacks are handled.

Hints:

- You can run the server simply with `go run .` in the projects directory.
- Tests are run with `go test` in the current directory.
- Try to keep to the standard library as much as possible
- Latency is crucial for this application, so fetching the items sequentially one at a time might not be good enough

## Decisions taken on the implementation

- For the sake of simplicity, I coded a [simple test](sever_test.go#L33) that works with the given implementation, but there is another [test that would work if external dependencies](sever_test.go#L260) were added.
- When testing, I've decided to mock `rand.Int` and `time.Now` packages creating a [global variable](content.go#L9) rather than (for example) extend `SampleContentProvider` to take a `now` `func() time.Time`.
- I've created a [custom error struct](server.go#L13) to return a formatted error on the response.
- I've used a helper function [(`Respond`) to return a unified response](response.go#L212).
- Added [golangci.yml](golangci.yml) for the CI/CD to catch errors for me but also to be independent from the IDE. In addition, would help other people to follow same linter rules.

## Querying the service

The application is tested by `server_test.go` file, but you can query the running service by running:

`curl "http://localhost:8080/?count=8" | jq`

Expected result sources: `1 1 2 3 1 1 1 2` given [default config](config.go#L39)

`curl "http://localhost:8080/?count=8&offset=10" | jq`

Expected result sources: `2 3 1 1 1 2 1 1` given [default config](config.go#L39)
