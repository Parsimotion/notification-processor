# notification-processor

[![NPM version](https://badge.fury.io/js/notification-processor.png)](http://badge.fury.io/js/notification-processor)

# Breaking change
* Configure API URL and Notification API URL at job processor
```Javascript
//2.x
require("notification-processor").JobProcessor({
    buildOpts: (message) => ({}), notificationApiUrl: "apiNotificationUrl"
})

//3.x
require("notification-processor").JobProcessor({
    apiUrl: "",
    notificationApiUrl: ""
})
```

# New Features
* Adding request async processor

```Javascript
require("notification-processor").RequestAsyncProcessor({
    apiUrl: "baseAPI..."
    silentErrors: []
})
```

# Migrating 1.x -> 2.x

## Deadletter Processor
```Javascript
// 1.x
const buildOpts = (message) => { return ....  }
deadletterProcessor = DeadletterProcessor({
    connection: connection,
    name: "aFunctionName",
    maxDequeueCount: 1,
    rowKeyGenerator: (message) => { return ...... }
}, processor())

// 2.x
const buildOpts = (message) => { return ....  }
const sender = {
    resource: (notification) => { return ... }
    user: (notification) => { return ... }
}

deadletterProcessor = DeadletterProcessor({
    connection: connection,
    name: "aFunctionName",
    maxDequeueCount: 1,
    sender: sender
}, processor())

```

## Job Processor
```JavaScript

// 1.x
const buildOpts = (message) => { return ....  }
const processor = JobsProcessor(buildOpts, nonRetryable)

// 2.x
const buildOpts = ({ message }) => { return ...... }
const processor = JobsProcessor({
    buildOpts: optionsGenerator,
    maxRetries,
    nonRetryable
})
```

## To publish
```
npm version [major/minor/patch]
npm publish
git push origin HEAD
git push origin HEAD --tags
```
