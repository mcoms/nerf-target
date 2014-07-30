# Nerf Target

A physical target for Nerf bullets or other soft projectiles, which I used to skip Spotify on the @wearefriday office jukebox.

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