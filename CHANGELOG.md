# Changes

1.7.0
----------
- Persist optOut changes.
- Default console logging to true.
- Default log level to trace.

1.6.0
----------
- Add ability to force config synchronization.
- Add multi agent support.
- Add additional debug logging.

1.5.0
----------
- Improve json serialization performance of source.
- Add ability to toggle console logging.
- Add ability to toggle remote logging.
- Add ability to toggle synchronous logging.
- Add ability to override log level locally.

1.4.0
----------
- Add multiplatform support.

1.3.0
----------
- Add zlib compression.
- Improve password scrubbing for json.

1.2.3
----------
- Rename repo to birch-swift.
- Flush on every write to ensure file has all logs prior to rotating.

1.2.2
----------
- Adjust remote source configuration

1.2.1
----------
- Fixes SPM import

1.2.0
----------
- Add encryption at rest

1.1.2
----------
- Adjust delayed initialization to reduce impact on startup.

1.1.1
----------
- Add SPM support

1.1.0
----------
- Stops logging after disk is full
- Add ability to scrub logs, includes built in email and password scrubbers.

1.0.0
----------
- Initial release
