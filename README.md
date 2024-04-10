# ![RealWorld Example App](logo.png)

[![CI](https://github.com/martenframework/realworld/workflows/Specs/badge.svg)](https://github.com/martenframework/realworld/actions) [![CI](https://github.com/martenframework/realworld/workflows/QA/badge.svg)](https://github.com/martenframework/realworld/actions)

> ### [Marten](https://github.com/martenframework/marten) codebase containing real world examples (CRUD, auth, advanced patterns, etc) that adheres to the [RealWorld](https://github.com/gothinkster/realworld) spec and API.

This codebase was created to demonstrate a fully fledged fullstack application built with the **[Marten web framework](https://github.com/martenframework/marten)** including CRUD operations, authentication, routing, pagination, and more.

We've gone to great lengths to adhere to the **[Marten](https://github.com/martenframework/marten)** community styleguides & best practices.

For more information on how to this works with other frontends/backends, head over to the [RealWorld](https://github.com/gothinkster/realworld) repo.

## System requirements

* [Crystal](https://crystal-lang.org/) 1.12+
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


## Frontend development

This project uses [Gulp](https://gulpjs.com/) and [Webpack](https://webpack.js.org) to bundle the assets of the application. Client-side scripts are written using **vanilla JS** and the stylesheets used are the precompiled ones that are [provided by the Realworld project](https://realworld-docs.netlify.app/docs/specs/frontend-specs/styles). All the tools necessary to work on the assets of this project should've been installed when running `make` in the previous sections.

Client-side scripts are stored in the `src/assets/build_dev` folder. Whenever those scripts need to be recompiled, the following command can be used:

```shell
npm run gulp -- build
```

Finally, a Webpack dev server can also be launched in order to use hot reloading if necessary. To do so, the following command can be used:

```shell
npm run gulp -- webpack-dev-server
```

Note that the Marten development server should be started in another terminal _after_ the Webpack dev server has been started.

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
