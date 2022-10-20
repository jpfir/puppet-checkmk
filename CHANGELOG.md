# Changelog

## Unreleased

**Features**

- Add ability to set cmkadmin and automation admin account passwords. It is now a requirement for `cmkadmin_user_password` to be set when `mode => 'server'` is used.
- Add ability to only require `version` to be defined, a common URL will be used, but if `download_url` is given, this will be used instead.

**Bugfixes**

**Known Issues**

- `--trust-cert` option is being used during the CheckMK registration process, this isn't an issue where the CheckMK server is using HTTPS as this is skipped ([werk #14715](https://checkmk.com/werk/14715)).
  This can be a potential security issue if the CheckMK server is only configured for HTTP connections.

## Release 0.1.0

Initial release of the module!