---
title: "Measuring Smartphone Energy on a Budget"
kind: article
layout: post
ignore: _x
excerpt: |
    For a recent research project, I measured the power consumption of a
    smartphone. I am clueless when it comes to electronics and I didn't want to
    drop a lot of (my advisor's) cash, so I needed a simple, relatively cheap
    setup to get reasonable power measurements. This post describes how you can
    get a similar apparatus up and running with a [custom Python
    library][pylib] I wrote for controlling a DC power supply.

    [pylib]: https://github.com/sampsyo/bkp1696
---

For a recent research project, I measured the power consumption of a smartphone.
Because their battery life is a critical design constraint, it's import to
understand how smartphones' software behavior influences their power usage, but
there aren't many tools available for actually measuring power---especially ones
that are remotely affordable. I've seen many papers that use expensive,
special-purpose power measurement tools like the [$771 one from Monsoon
Solutions][monsoon] or cumbersome custom setups. Because I'm utterly clueless
when it comes to electronics, I needed a straightforward apparatus that could be
controlled mostly through software. This post describes a simple, relatively
cheap setup I used to get some reasonable power measurements.

### The Equipment

<img src="http://www.cs.washington.edu/homes/asampson/media/apparatus/psup.jpeg"
class="illus" width="350" height="179">

The only equipment I shelled out for in this setup was a DC
power supply: specifically, the [BK Precision 1696][psup]. At $375, this power
supply has everything we need: a reasonable DC voltage and current range and,
crucially, a serial port for communication with a computer that can do the
measurement and control footwork. (I'm sure any similar equipment would work,
but I've written some software that works with this supply in particular---see
below.) Unless you have an ancient serial-port-equipped host machine, you'll
likely also want a USB serial interface like [this one][usbser] (a very
affordable commodity part). The only other physical equipment necessary is a few
wires of the sort easily found in an electrical-engineering lab on any
university campus. (I cannot, of course, condone the "borrowing" of any such
materials...)

### The Setup

<img src="http://www.cs.washington.edu/homes/asampson/media/apparatus/connection.jpeg"
class="illus" width="350" height="219">

The next challenge is to get the smartphone to run off of the power supply so we
can measure its energy consumption. The most straightforward way I found to do
this was to replace the device's battery with the power supply. This just
involves removing the battery, finding the appropriate terminals, and wiring the
supply's output to them. In my case---I was measuring an original Motorola
DROID---there were two extra pins for communication with the battery's charge
meter; the phone worked fine with these pins left disconnected from anything.

After looking up the battery's voltage, I configured the power supply to that
level in "constant voltage" mode and turned on the phone. Shockingly, this
works! The DROID was slightly confused about its battery capacity level, but it
operated normally.

To control the measurements, I used connected a host laptop via USB to both the
phone (to control the software) and the power supply (to take measurements).

### The Software

<img src="http://www.cs.washington.edu/homes/asampson/media/apparatus/netbook.jpeg"
class="illus" width="350" height="261">

On the host machine, there are two main software components: one to talk to the
smartphone and one that talks to the power supply. The former is pretty
straightforward---I manage the "rooted" Android software via SSH
([SSHDroid][])---so I'll just describe the power supply management here.

First, I needed a driver for the USB/serial adapter. Most Linux boxes probably
have this installed; on Mac OS X, [the osx-pl2303 project][osxpl] covers most
devices.

I used a somewhat hard-to-find [description of the BK Precision 1696's serial
protocol][protocol] to build a [Python library for communicating with the power
supply][pylib]. The library takes care of the command encoding, conversion
between ordinary floating-point numbers and the protocol's arcane fixed-point
formats, and other mundanities. To get started, [download the library][pylib]
and start coding:

    import psup
    with psup.Supply() as sup:
        sup.voltage(1.3)
        volts, amps = sup.reading()
        print '%f V, %f A' % (volts, amps)

The `Supply` class represents a connection to the power supply. It's also a
[context manager][ctx], so if you wrap your code in a Python `with` statement,
the connection will be automatically opened and then cleaned up when you're
done. Once you have a connection, you can call `voltage` to set the voltage,
`reading` to get the current sampled voltage and current, `maxima` to get the
acceptable parameter ranges, et cetera. I haven't implemented the entire serial
protocol, but I found these commands to be enough to conduct reasonable
power-measurement experiments. If you want to add any functionality, please feel
free to fork the project on GitHub or [send me patches][email].

[monsoon]: http://www.msoon.com/LabEquipment/PowerMonitor/
[psup]: http://www.bkprecision.com/products/model/1696/programmable-dc-power-supply-1-20vdc-0-999a.html
[usbser]: http://www.amazon.com/TRENDnet-Serial-Converter-TU-S9-Blue/dp/B0007T27H8
[sshdroid]: https://market.android.com/details?id=berserker.android.apps.sshdroid&hl=en
[protocol]: http://kb.bkprecision.com/getattachment.php?data=MjB8UmVtb3RlX2NvbW11bmljYXRpb25fMTY5Nl8xNjk4LnBkZg%3D%3D
[pylib]: https://github.com/sampsyo/bkp1696
[osxpl]: http://osx-pl2303.sourceforge.net/
[ctx]: http://docs.python.org/library/stdtypes.html#typecontextmanager
[email]: mailto:asampson@cs.washington.edu
