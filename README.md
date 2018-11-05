# saucelabs-orb
orb encapsulating interactions with SauceLabs from a CircleCI project


## Sauce Connect Proxy
This orb lets you install and run an instance of SauceLab's Connect Proxy on your CircleCI Build container.

See [https://wiki.saucelabs.com/display/DOCS/Sauce+Connect+Proxy](https://wiki.saucelabs.com/display/DOCS/Sauce+Connect+Proxy) for more info on Sauce Connect Proxy


## Sample Config
An example config running selenium tests for multiple browsers in parallel with Maven

```
version: 2.1
orbs:
  saucelabs: saucelabs/connects@volatile
workflows:
  browser_tests:
    jobs:
      - saucelabs/with_proxy:
          name: "Chrome Tests"
          steps:
            - run: mvn verify -B -Dsauce.browser=chrome  -Dsauce.tunnel="chrome"
          tunnel_identifier: "chrome"
      - saucelabs/with_proxy:
          name: "Safari Tests"
          steps:
            - run: mvn verify -B -Dsauce.browser=safari  -Dsauce.tunnel="safari"
          tunnel_identifier: "safari"
          
```