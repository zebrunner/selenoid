Zebrunner Selenoid Engine
==================

Zebrunner Selenoid Engine is a dockerized infrastructure for executing web tests in selenoid images on Chrome, Firefox, Opera and Microsoft Edge browsers with AWS S3 integration for artifacts uploading (logs, video recordings).

It is fully integrated into the [Zebrunner (Community Edition)](https://zebrunner.github.io/zebrunner) ecosystem as an embedded Selenium Hub.

Feel free to support the development with a [**donation**](https://www.paypal.com/donate?hosted_button_id=JLQ4U468TWQPS) for the next improvements.

<p align="center">
  <a href="https://zebrunner.com/"><img alt="Zebrunner" src="./docs/img/zebrunner_intro.png"></a>
</p>

## Usage
1. Clone [selenoid](https://github.com/zebrunner/selenoid) and launch the setup procedure:
   ```
   git clone https://github.com/zebrunner/selenoid.git && cd selenoid && ./zebrunner.sh setup
   ```
2. Provide the required details and start services (AWS S3 compatible storage credentials are required).
   > Uncomment 4444 ports sharing if you want to use it as independent service
3. Use `http://hostname:4444/wd/hub` URL to start selenium tests for the above browsers
4. Run `./zebrunner.sh setup` anytime you want to pull the latest browser versions
   > Each setup operation pulls the two latest browsers versions for Chrome/Firefox and Opera browsers and updates browsers.json for Selenoid service

## Documentation and free support
* [Zebrunner CE](https://zebrunner.github.io/zebrunner) 
* [Carina Guide](https://zebrunner.github.io/carina) 
* [Demo Project](https://github.com/qaprosoft/carina-demo) 
* [Telegram Channel](https://t.me/zebrunner)

## License
Code - [Apache Software License v2.0](http://www.apache.org/licenses/LICENSE-2.0)

Documentation and Site - [Creative Commons Attribution 4.0 International License](http://creativecommons.org/licenses/by/4.0/deed.en_US)
