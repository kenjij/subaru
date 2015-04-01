# Subaru

A gem to run RESTful (kinda) API server to industrial relays.

The `subaru` command will launch a [Sinatra](http://www.sinatrarb.com) based server, functioning as a gateway to your web-enabled relays.

## Supported Relays

- Xytronix (a.k.a. ControlByWeb)
  - WebRelay
  - WebRelay-10

I welcome requests for other relay equipment. If development/evaluation units can be provided, that would increase the likelyhood of support.

## Requirements

- Ruby 2.0.0 <=
- [Kajiki](http://www.kenj.rocks/kajiki/) 1.1 <=
- Sinatra 1.4 <=

## Getting Started

### Install

```
$ gem install subaru
```

### Configure

Store configuration in a YAML file. If you need a template, just try to start Subaru without the `--config` option and it'll output an example.

```yaml
---
:global:
  :pretty_json: YES
  :auth_tokens:
    :any:
      - abcd # This is the auth token. List as many as you want, or remove it to disable auth.

:devices:
  factory: # This is the device name to use in the URL.
    :definition: Xytronix::WebRelay
    :url: http://192.168.0.10
    :password: password
    :read_timeout: 15
```

### Run

```
$ subaru start -c config.yml
```

### Consume

`GET` to read the state.

```
$ curl http://subaru/factory
{
  "relay": "off",
  "input": "off"
}
```

`PUT` to set the state.

```
$ curl -X PUT http://subaru/factory -d '{"relay":"on"}'
{
  "relay": "on",
  "input": "off"
}
```

## Security

For obvious reasons, you should not expose this server to the public. If so, at least protect behind a reverse proxy, like NGINX, and/or require auth over HTTPS.
