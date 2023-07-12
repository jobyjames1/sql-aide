# SQL Aide Flow (SQLa Flow)

SQL Aide Flow is a data operations workflow library similar to Apache Airflow or
Dagster but built for TypeScript-based SQL-first workflows. It helps you
orchestrate stateful SQL tasks such as acquiring source data, preparing SQL,
loading into a database. It handles task scheduling, dependencies, retries,and
more using an Aspect-oriented Programming (AOP) style using dependency
injections.

## Core Strategy

- Each flow is defined as a set of type-safe TypeScript modules that can operate
  independently as a CLI or as a library to be included by other flows in a DAG.
  Flow code can operate outside of Flow or as part of the Flow framework. It's a
  design goal to ensure that Flow does not become a dependency and that there's
  no vendor lock-in. The way we accomplish this is to allow a Flow to be a plain
  TypeScript Class.
- Every Flow step should be type-safe on the incoming and outgoing sides.
  Creating maintainable and decoupled code is a design goal and type-safety
  helps achieve that goal.
- Each Flow step should have explicit dependencies that are easy to follow. Ease
  of debugging is a design goal so implicit dependencies should be reduced.
- Every Flow step should be independently unit testable. Creating maintainable
  and decoupled code is a design goal and unit testing helps achieve that goal.
- Flow steps should be stateless whenever possible but if they are stateful they
  should allow their state to be stored using Open Telememtry traces, logs, and
  metrics plus be storage independent. It is a design goal to elminate state
  management dependencies by storing state in files, databases, or in memory.
- Flow steps must be able to store their own Quality System (documentation)
  content such as descriptions, lineage, stewardship, etc.

## Flow Runner Status

- [x] Each flow can be executed as a standalone Deno script
- [x] Each flow can be scheduled using `cron` or other external utilities
- [ ] Each flow can be executed as a daemon/service
  - [ ] Can have a built-in scheduler via `croner` or similar
  - [ ] Can be executed via a _sensor_, like a file watcher or S3 watcher check
        an API regularly, etc..

## Flow Class Status

- [x] Each flow is a TypeScript class
  - [x] Flow classes do not not require any base classes or inheritence (though
        does support inheritable workflows).
  - [ ] Flow classes can use TypeScript imports and support dependencies at the
        flow level not just at the step level
  - [ ] Flow classes can be unit tested independently of the Flow framework
  - [ ] Flow runs should be able to be "dry-runnable" so it will just "document"
        what it will do instead of actually running the steps
  - [ ] Flow runs should be able to report their execution status, progress,
        etc. (`verbose` mode) as Open Telemetry traces, logs, and metrics
- [x] Each flow step is a _synchronous_ or _asynchronous_ class method.
- [x] Each flow step may have one or more decorators that can specify aspects.
- [x] Each flow can have one or more _initialization_ methods declared by
      decorators; initialization can also occur in flow class constructor but
      since constructors cannot be asynchronous you can use decorated async
      methods when required
- [x] Each flow step class method is called in linear order unless it has a
      dependency decorator. If there are any dependencies the flow will become a
      DAG that is toplogically sorted and executed.
- [x] Each flow step has a common set of arguments
  - [x] The current flow state and step context is the first argument.
  - [x] The previous step's result (either an Error or its `return` statement
        value) is the second argument
- [x] Each flow can one or more finalization methods delcared by decorators.
- [x] Flow execution has complete observability of all initialization, execution
      of steps, errors, and finalization through EventEmitter pattern
  - [ ] EventEmitter allows unlimited typed listeners for each flow step
- [ ] The flow engine can manage secrets outside of the flow instances so that
      sensitive values and data are not seen by all developers; allow the
      secrets to managed in a type-safe way using Zod schemas
- [ ] Each flow step can request value of Environment variables to be injected
      as function arguments or available in the stepCtx object.
- [ ] Each flow step can provide decorator to specify what happens on error
  - [ ] Retries
  - [ ] Supply a different result
- [ ] Flow instance property decorators can inject values from Engine
  - [ ] Each flow step can specific asset dependencies that can be loaded and
        memoized before the step is executed (`dependsOnAsset` which can accept
        a URL, function, filename, etc.)
  - [ ] Flow initialization can inject database connections (with pooling) and
        store them as instance properties
  - [ ] Flow initialization can inject files or content being watched
- [ ] Each flow step can optionally request memoization of its results through a
      decorator.
- [ ] Flow steps already store results as part of `runContext.stepsExecuted` but
      we should have standard decorators to push results into S3, store them in
      a file, etc. as well
- [ ] Each flow step can optionally inject arguments into function call
  - [ ] Each flow step can optionally inject database connections (with pooling)
        as a parameter
  - [ ] Each flow step can optionally inject files or content being watched
- [ ] Each flow as a whole can specify a timeouts to abort long-running flows
- [ ] Each flow step can provide decorator to specify timeouts to abort
      long-running steps
- [ ] Each flow step can provide an interruption decorator to specify
      preconditions.

## Flow Quality System

- [ ] Flow execution should have options for injecting synthetic or mock data or
      provide limited (e.g. first N rows instead of all rows) data for testing
      flows.