# JSCPolyfills

Do you miss simple things like `console.log` or `setInterval` when running your JavaScript with JavaScriptCore?

Then this package is for you.

## Features

### Console Polyfill
- `console.log`
- `console.debug`
- `console.info`
- `console.warn`
- `console.error`

### Timer Polyfill
- `clearInterval`
- `clearTimeout`
- `setInterval`
- `setTimeout`

### Fetch Polyfill
- `fetch` using URLSession
- `Headers`
- `Request`
- `Response`

### Async Polyfill
Call any JS method that returns a `Promise` from Swift using `async/await`.
Errors are wrapped into `JSError` structs and thrown in Swift.
