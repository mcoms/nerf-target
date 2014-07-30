# Nerf Target

A physical target for Nerf bullets or other soft projectiles, which I used to skip Spotify on the [@wearefriday](https://github.com/wearefriday) office jukebox.

Powered by [Arduino](http://www.arduino.cc/) and [Ruby](https://www.ruby-lang.org/), although any language that can access a serial port will work.

## Build one of your own

### You will need

- A picture frame to serve as your target
  - I'd avoid glass, get one fronted with plastic
  - Doesn't need to be thick
- An Arduino with an analog input pin and USB-Serial capabilities
  - I used a Duemilanove clone I had laying around
  - A Pro Micro would be ideal as it has USB-Serial and could be recessed into the frame
- A [piezoelectric sensor](https://www.google.co.uk/search?q=Piezoelectric+disc&tbm=isch)
  - Also known as a piezoelectric disc/sounder/transducer
  - You can find these in piezo buzzers, musical birthday cards
  - If you get the buzzer type, remove the case so you're left with just the disc
- A 1 megaohm resistor (1MΩ) (for the piezo)
- An LED for the power light
- A resistor to [limit current through the LED](http://led.linear1.org/1led.wiz)
  - Depends on the voltage/current requirements of the LED
  - I used 560Ω, because I had one nearby and it made the green LED glow a nice colour
- A USB cable to program the Arduino/communicate with the target
- Hook up wire and some way to make connections (solder, breadboard, sticky tape and prayers)

I'll assume you are comfortable with programming an Arduino, and basic electronics. Otherwise, you should run through the [Arduino Getting Started guide](http://arduino.cc/en/Guide/HomePage). Fiddling with electronics plugged into your very expensive laptop can be a frustrating and potentially hazardous experience, so make sure you're confident first.

### Circuit

The circuit we'll be building is very simple. It's the [Arduino Knock Example](http://arduino.cc/en/Tutorial/Knock), with an LED.

![Fritzing breadboard diagram](diagrams/circuit_bb.png?raw=true)

In assembly, the black case around the sounder would be removed, leaving only the piezo disc.

### Assembling the frame

- Drill a hole for the status LED
- Place the piezo sensor sandwiched between the back board and front plastic
- Insert any printed graphics
- Make sure the piezo makes contact with both the back and front of the frame
  - We're going to sense when this pressure suddenly increases
  - Use hard tack/plastic/card if you need to increase the pressure on parts of the frame
  - Experiment to get this right
- Mount the electronics so they're secure (remember they will get hit)

### Programming

Flash the Arduino [with the program](arduino/Nerf_Target/Nerf_Target.ino), making sure to set the correct pins if you haven't wired as per the diagram above:

```processing
const int knockSensor = A0;
const int led = 13;
const int threshold = 10;
````

The threshold value determines how hard the target has to be hit to register contact. You may need to play around a little to get this right for your kind of projectile. Higher values means harder hits are required. The value can be between 0 and 1023. You can usually expect your sensor to read some value, even at rest.

### Connecting/the serial protocol

The target defines a very simple protocol. When you connect, or it's restarted it sends an information message. When it's hit, it sends a line beginning with `NP` along with the time and sensor reading.

```
Nerf Target v0.0.1, github.com/mcoms/nerf-target, 2014.
NP,3604,268
NP,4205,219
NP,5407,214
NP,6410,135
NP,7711,53
NP,7813,14
...
```

To process it, connect to the serial port at 9600 baud, and wait for a line beginning `NP`. Split those lines where you see a comma `,`. `NP` is the command, the next number is the microprocessor time (milliseconds), and the final number is the sensor reading (roughly proportional to impact force).

#### Time

You can use the time to figure out if you've already processed that hit, or the number of milliseconds between hits. It's the number of milliseconds since the Arduino board began running the current program. This number will overflow (go back to zero), after approximately 50 days, so bear in mind that it could go down as well as up.

## Skipping Spotify

This target can be used to trigger anything. We used it [@wearefriday](https://github.com/wearefriday) to skip Spotify on the office jukebox.

### An example client in Ruby

I've provided a [very basic Ruby client](ruby/nerf-target.rb) for the target using the [SerialPort gem](https://github.com/hparra/ruby-serialport/). It uses AppleScript to skip Spotify, so only works on OSX. That was fine by us, but you could easily extend it to work for you.

#### Usage

```
$ bundle install
$ ruby nerf-target.rb /dev/tty.usbserial-A6008k35 
I, [2014-07-30T12:07:50.828619 #3501]  INFO -- : Trying /dev/tty.usbserial-A6008k35...
I, [2014-07-30T12:07:50.832633 #3501]  INFO -- : Listening on /dev/tty.usbserial-A6008k35.
D, [2014-07-30T12:07:52.221687 #3501] DEBUG -- : Received: Nerf Target v0.0.1, github.com/mcoms/nerf-target, 2014.
D, [2014-07-30T12:07:56.891676 #3501] DEBUG -- : Received: NP,4706,18
I, [2014-07-30T12:07:56.891831 #3501]  INFO -- : Hit at 4706 with force 18.
I, [2014-07-30T12:07:57.858570 #3501]  INFO -- : Skipping Spotify.
D, [2014-07-30T12:07:57.858676 #3501] DEBUG -- : Ignoring hits until 11:08:06 UTC.
D, [2014-07-30T12:08:02.185334 #3501] DEBUG -- : Received: NP,10012,38
I, [2014-07-30T12:08:02.185506 #3501]  INFO -- : Hit at 10012 with force 38.
D, [2014-07-30T12:08:02.185546 #3501] DEBUG -- : Ignoring this hit.
```

## Contributing

I'd love to hear about fun uses of this project, and welcome PRs to improve.