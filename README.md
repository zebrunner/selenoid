Zebrunner Selenoid Engine
==================

Zebrunner Selenoid Engine is dockerized infrastructure for executing web tests in selenoid images on Chrome, Firefox, Opera and MicrosoftEdge browsers with AWS S3 integration for artifacts uploading (log, video recordings).
Is is fully integrated into the [Zebrunner (Community Edition)](https://zebrunner.github.io/zebrunner) ecosystem as embedded Selenium Hub.

## Usage
1. Clone [selenoid](https://github.com/zebrunner/selenoid) and launch setup procedure
  ```
  git clone https://github.com/zebrunner/selenoid.git && cd selenoid && ./zebrunner.sh setup
  ```
2. Provide required details and start services (AWS S3 compatible storage crdentials are required).
> Uncomment 4444 ports sharing if you wanna to use it as independent service
3. Use `http://hostname:444/wd/hub` url to start selenium tests for above browsers
4. Run `./zebrunner.sh setup` anytime you wanna to pull latest browser version
> Each setup operation pull twi latest browsers versions for Chrome/Firefox and Opera browsers and update browsers.json for Selenoid service

## Documentation and free support
* [Zebrunner CE](https://zebrunner.github.io/zebrunner) 
* [Zebrunner Reporting](https://zebrunner.github.io/documentation/) 
* [Carina Manual](http://qaprosoft.github.io/carina) 
* [Demo Project](https://github.com/qaprosoft/carina-demo) 
* [Telegram Channel](https://t.me/zebrunner)

## License
Code - [Apache Software License v2.0](http://www.apache.org/licenses/LICENSE-2.0)

Documentation and Site - [Creative Commons Attribution 4.0 International License](http://creativecommons.org/licenses/by/4.0/deed.en_US)
