# notification-processor

[![NPM version](https://badge.fury.io/js/notification-processor.png)](http://badge.fury.io/js/notification-processor)

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

