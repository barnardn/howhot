# howhot

A simple command line client to fetch the current weather conditions from [openweathermap.org](http://openweathermap.org). I wrote this app primarily to 
test out building swift apps outside of Xcode. I used the loverly [zed editor](http://zed.dev) with much success.

## Prerequisites

This app requires that you have api keys from [openweathermap.org](http://openweathermap.org) and [geolocated.io](http://geolocated.io). As of this writing, you can get free api keys, which 
is enough to use all the functions of this app. 

### Configuration

You'll need to add your api keys to a configuration file (default: `~/.config/howhot.yaml`) or your environment. The config file format is:

```
openweathermap: "some-openweathermap-key-here"
geokey: "some-geolocated-io-key-here"
```
For your environment, name each variable name with the `howhot` prefix:

```
HOWHOT_OPENWEATHERMAP: "some-openweathermap-key-here"
HOWHOT_GEOKEY: "some-geolocated-io-key-here"
```

## Building

The build process is pretty standard stuff if you've built and installed swift packages:

```
  git clone --recursive https://github.com/barnardn/howhot
  swift build -c release
  cp .build/release/howhot ~/bin # or some directory in your path
```

## Running howhot

`howhot` by itself will fetch your public ip address, lookup where that's located in the world, and use the postal code to fetch your current weather conditions: 

```
$ howhot
Loading... [Done]
Current Weather Conditions
------- ------- ----------
US, Portage
Sunrise: 2025-12-26 at 8:09 AM GMT-5
Sunset: 2025-12-26 at 5:15 PM GMT-5
Coordinates: 42.1938°, -85.5639°
Temperature: 39.3℉
Feels Like: 32.1℉
Coldest Reported: 39.2℉
Warmest Reported: 41.1℉
Humidity: 96.0%
mist
Wind Speed: 11.5mph at 310°
Cloud Cover: 100.0%
```

For weather data only, you can specify the `--format-string` argument which will return just those fields defined in the string, e.g.

```
$ howhot conditions 49002 --format-string "{temperature} / {feelsLike} humity: {humidity}"
39.5℉ / 32.8℉ humity: 94.0%
```

This is handy for showing important weather bits in a status bar, like one would use with `tmux`

For more ways to run the command:

`howhot --help`
