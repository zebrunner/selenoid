Zebrunner Selenoid Engine
==================

Dockerized Selenium Hub for executing web tests on Chrome, Firefox, Opera and Microsoft Edge browsers saving driver logs and video recordings onto the S3 compatible storage.

It is fully integrated into the [Zebrunner Community Edition](https://zebrunner.github.io/community-edition) ecosystem as an embedded Selenium Hub.

Feel free to support the development with a [**donation**](https://www.paypal.com/donate/?hosted_button_id=MNHYYCYHAKUVA) for the next improvements.

<p align="center">
  <a href="https://zebrunner.com/"><img alt="Zebrunner" src="https://github.com/zebrunner/zebrunner/raw/master/docs/img/zebrunner_intro.png"></a>
</p>

## Usage
1. Clone and configure:
   ```
   git clone https://github.com/zebrunner/selenoid.git && cd selenoid && ./zebrunner.sh setup
   ```
2. Provide the required details and start services
   > S3 compatible storage is needed.
4. Use `http://hostname:4444/wd/hub` as Selenium Hub Url for your tests replacing hostname by actual value or ip address
5. Execute `./zebrunner.sh setup` anytime you want to pull the latest browser versions
   > Each setup pulls the two latest browsers versions for Chrome/Firefox and Opera

## Documentation and free support
* [Zebrunner CE](https://zebrunner.github.io/community-edition) 
* [Carina Guide](https://zebrunner.github.io/carina) 
* [Demo Project](https://github.com/qaprosoft/carina-demo) 
* [Telegram Channel](https://t.me/zebrunner)

## License
Code - [Apache Software License v2.0](http://www.apache.org/licenses/LICENSE-2.0)

Documentation and Site - [Creative Commons Attribution 4.0 International License](http://creativecommons.org/licenses/by/4.0/deed.en_US)
