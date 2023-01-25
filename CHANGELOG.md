# Changelog

## Release 0.3.2

**Bugfixes**

- Remove Stdlib::HTTPSUrl validation due to "unresolved type" errors

## Release 0.3.1

**Bugfixes**

- Use Puppets HTTP Client (causing certificate validation issues)

## Release 0.3.0

**Refactor**

- Move to using Puppet Providers instead of Functions.

**Bugfixes**

- Handle 404 errors and display a warning
- Add validation on site_name as this is being used to create a unix user

## Release 0.2.1

**Bugfixes**

- Fixes and occasional issue where passwords were attempting to be set before the site is created.

## Release 0.2.0

**Features**

- Add ability to set cmkadmin and automation admin account passwords. It is now a requirement for `cmkadmin_user_password` to be set when `mode => 'server'` is used.
- Add ability to only require `version` to be defined, a common URL will be used, but if `download_url` is given, this will be used instead.

**Bugfixes**

- Raise `Puppet::Error` instead of `function_fail` to correctly alert in the Puppet.

**Known Issues**

- `--trust-cert` option is being used during the CheckMK registration process, this isn't an issue where the CheckMK server is using HTTPS as this is skipped ([werk #14715](https://checkmk.com/werk/14715)).
  This can be a potential security issue if the CheckMK server is only configured for HTTP connections.

## Release 0.1.0

Initial release of the module!