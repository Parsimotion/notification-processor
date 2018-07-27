# notification-processor

[![NPM version](https://badge.fury.io/js/notification-processor.png)](http://badge.fury.io/js/notification-processor)

# Migrating 1.x -> 2.x

## Job Processor
```JavaScript

// 1.x
const buildOpts = (message) => { return ....  }
const processor = JobsProcessor buildOpts, nonRetryable

// 2.x
const buildOpts = ({ message }) => { return ...... }
const processor = JobsProcessor {
    buildOpts: optionsGenerator,
    maxRetries,
    nonRetryable
}
```

