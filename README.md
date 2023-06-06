# Deliberate Practice Initial Session

## The whole idea is to train everyday.
### While training I will be wide open to different things where to improve as well places to develop a clear training reproducible step.

## What we're going to build?

We are going to build a simple App to consume a list of Headlines and show it on screen in a TableView.

## Where to start?

We are going to start with the view.
Our view will be based on a TableView and it should display:

- A Feed of Worldiwe Top News.
- Every news should have it's image.

## UX goals for the News UI experience

- [✅] Load Top Headlines automatically when view is presented

---
- Create the system under test.
- Create the spy.
- Create the Protocol boundary for the loader.
- Create sut private extension for DSL's reliable helpers to protect the tests.
- Create memory leak tracker.
---

- [✅] Allow customer to manually reload feed (pull to refresh)
    - Create the pull to refresh mechanism.

- [✅] Show a  loading indicator while loading feed.

- [] Render all loaded feed items (title, description, publishedAt, content & source name)

- [] Image loading experience
    - [✅] Load when image view is visible (on screen)
    - [✅] Cancel when image view is out of screen
    - [] Show a loading indicator while loading image (shimmer)
    - [] Option to retry on image download error  
    - [] Preload when image view is near visible
 
 ## Networking Layer
 
 ## Json Payload details
    - source
        - id
        - name
    - title
    - description
    - url
    - urlToImage
    - publishedAt
    - content
 




