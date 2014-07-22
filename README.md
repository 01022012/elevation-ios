## Elevation iOS app

Simple, proof-of-concept iOS app written in RubyMotion which shows the users current location on a map
and their elevation (from sea-level).

Additionally on the 2nd tab a user can choose arbitrary points and display the gain/loss between
those two points.

Search is performed against the Google Places API.

## Configuration

Specify your Google API key in `config/google_config.rb`, specifically both the `PLACES_API_KEY`
and `ELEVATION_API_KEY` - which is likely the same key.

## Screenshots

![a](http://codycaughlan.s3.amazonaws.com/images/elevation-app/you.png)
![b](http://codycaughlan.s3.amazonaws.com/images/elevation-app/two-points.png)

## Requirements

* RubyMotion


## Installation

```bash
$ gem install bundler
$ bundle install
$ rake pod:install
$ rake
```
