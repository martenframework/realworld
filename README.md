# ![RealWorld Example App](logo.png)

[![CI](https://github.com/martenframework/realworld/workflows/Specs/badge.svg)](https://github.com/martenframework/realworld/actions) [![CI](https://github.com/martenframework/realworld/workflows/QA/badge.svg)](https://github.com/martenframework/realworld/actions)

> ### [Marten](https://github.com/martenframework/marten) codebase containing real world examples (CRUD, auth, advanced patterns, etc) that adheres to the [RealWorld](https://github.com/gothinkster/realworld) spec and API.

### [Demo](https://demo.realworld.io/)&nbsp;&nbsp;&nbsp;&nbsp;[RealWorld](https://github.com/gothinkster/realworld)

This codebase was created to demonstrate a fully fledged fullstack application built with the **[Marten web framework](https://github.com/martenframework/marten)** including CRUD operations, authentication, routing, pagination, and more.

We've gone to great lengths to adhere to the **[Marten](https://github.com/martenframework/marten)** community styleguides & best practices.

For more information on how to this works with other frontends/backends, head over to the [RealWorld](https://github.com/gothinkster/realworld) repo.

## System requirements

* [Crystal](https://crystal-lang.org/) 1.10+
* [Node.js](https://nodejs.org/en/) - 18.x

## Installation

If all the above system dependencies are properly installed on the target system, it should be possible to install the project using the following command:

```shell
$ make
```

This command will take care of the installation of the required dependencies (Crystal and Node.js) and will (i) build the development assets and (ii) setups the project's database using SQLite.

## Running the development server

The development server can be started using the following command:

```shell
$ make server
```

The development server should be accessible at http://127.0.0.1:8000.

## Running the test suite

The test suite can be run using the following command:

```shell
$ make tests
```

Code quality checks can be triggered using the following command:

```shell
$ make qa
```

## License

MIT. See `LICENSE` for more details.
