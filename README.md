# Kappa

Kappa is a local AWS Lambda runner. It enables you to run Lambdas as a web
server on your local machine. Making testing and development faster and easier.

## Usage

To run Kappa, you will need to have [Docker](https://www.docker.com/) installed
on your machine and you need to execute the following command in the root
directory of your project:

```Bash
docker run \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -p "3000:3000" \
    -p "3001:8080" \
    -e PROJECT_ROOT="$(pwd)" \
    -e HANDLER="bin/index.handler" \
    stankec/kappa
```

This will start a web server on `http://localhost:3000` that will simulate an
AWS Lambda. Ti will also start another web server on `http://localhost:3001`
where you can configure what type of Lambda you want to run and which event
template should it use.

The bare essential arguments for running the container are:

```Bash
docker run \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -e PROJECT_ROOT="$(pwd)" \
    -e HANDLER="bin/index.handler" \
    stankec/kappa
```

Kappa needs access to the host's `docker.sock` to be able to spawn Lambda
containers to execute various tasks. The `PROJECT_ROOT` env variable defines
which project to run as the Lambda code. `HANDLER` specifies which function in
which file to use as the entry point for the Lambda.

### Environment variables

All environment variables from the Kappa container will be passed to the spawned
lambda container. E.g. if the Kappa container has an ENV variable `FOO` with the
value `bar`, then the spawned Lambda container will also have an ENV variable
`FOO` with the value `bar`. This is the intended way of passing environment
variables to the Lambda.

### Docker-Compose

Constantly running the above command can get tedious. If you have
[docker-compose](https://docs.docker.com/compose/) installed, you can use the
following `docker-compose.yml` file:

```YAML
version: '2'
services:
  web:
    image "stankec/kappa"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    ports:
      - "3000:3000"
      - "3001:8080"
    environment:
      - "PROJECT_ROOT=$(pwd)"
      - "AWS_ACCESS_KEY_ID=XXXXXXXXXXXXXXXXXXX"
      - "AWS_SECRET_ACCESS_KEY=YYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY"
      - "AWS_REGION=some-amazon-region"
      - "MY_CUSTOM_ENV_VAR=ZZZZZZZZZZZZZZZZZZZZZZZZZZZZ"
      - "HANDLER=bin/index.handler"
    tty: true
    stdin_open: true
```

And then run `docker-compose up` to start Kappa.
__Note:__ This file assumes it's in the root directory of the project you want
to run in the Lambda.

### Templates

You can see all available templates in the
[`shared/data/tempaltes`](/shared/data/tempaltes) directory.

The template which is used to run the Lambda can be changed in the configurator.
__Note:__ The saved template doesn't change the preset template and that
it will disappear when the container is restarted.

Each template __needs__ to have at least two keys: `name` and `json`. Those keys
are self-explanatory:

* `name` - Name of the template (used only for display purposes)
* `json` - Relative path to a file containing the template's raw JSON payload

Additionally, a template __can__ have a `fields` key, which describes how the
value from the incoming HTTP request should be mapped to the event JSON. It can
have the following keys:

* `body` - mapping of the raw HTTP body string
* `headers` - mapping of a hash with the HTTP header key-value pairs
* `query` - mapping of a hash with the HTTP query key-value pairs
* `path` - mapping of the raw HTTP path string
* `method` - mapping of the raw HTTP method string

E.g. if you want to map the request's path to the key `b` of the following JSON:

```JSON
{
  "a": {
    "b": "path"
  },
  "c": "another_path"
}
```

the `fields.path` field would look like this:

```Ruby
[['a', 'b']]
```

Or in YAML format:

```YAML
path:
  -
    - "a"
    - "b"
```

If a template has multiple fields that need to be mapped to the same data from
the HTTP request then the value of the key can be set as an array of arrays:

```Ruby
[['a', 'b'], 'c']
```

Or in YAML format:

```YAML
path:
  - "c"
  -
    - "a"
    - "b"
```

## Acknowledgments

This project wouldn't have been possible without the folks at
[FloatingPoint](https://floatingpoint.io) who sponsored it's development.

<a href="https://floatingpoint.io">
  <img src="/assets/fp_logo.png" alt="FloatingPoint logo" width="300">
</a>

And the folks behind
[LambdaCI's](https://github.com/lambci/lambci)
[docker-lambda](https://github.com/lambci/docker-lambda)
project. It's the backbone on top of which this application has been built.

## Why kappa?

Well, if AWS Lambdas are the-bleeding-edge™ enabling 'serverless'
infrastructure then this is a step backward - back to a server-client
infrastructure. The Greek letter preceding lambda (λ) is kappa (κ)...
Very clever, I know 🤣

## License

This project is licensed under the [MIT](LICENSE.txt) license.
