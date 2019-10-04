# Consul TouchBarOps

![Consul TouchBarOps](touchbarops.png?raw=true "Consul TouchBarOps")

This is a demo toy for a [talk I gave at HashiConf EU 2019](https://youtu.be/GXDpeZo78UY?t=1264).

## Usage

Building in XCode should get a working Touch Bar app.

The main UI pane allows configuring which Consul API endpoint to hit, which
service to configure and which named subsets to split between.

This could all be much cleaner but wasn't needed for the demo. Changing values
should update the Touch Bar next time you move the slider.

![Config UI](ui-ss.png?raw=true "Config UI")

## Maintenance

I don't intend to maintain this so do what you like with it. I may consider PRs
if they are fun and seem to work but this is intended to be a demo tool and not
a real product!

Also, I know the code is messy. I built this in a few hours for a talk OK?
