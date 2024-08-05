# Ultrasonic-Distance-Calculator-using-8051-Microcontroller

This project is co-owned by: [@chahelgupta](https://www.github.com/chahelgupta) [@amishidesai](https://www.github.com/AmishiDesai04) [@reneeka](https://www.github.com/reneeka)

## Introduction
The Ultrasonic Distance Calculator using 8051 is an advanced electronic device that utilizes ultrasonic technology for precise distance measurements. This report offers a comprehensive overview of the underlying principles of ultrasonic rangefinders, the circuitry involved, and the pivotal role of the 8051 microcontroller in distance calculations.

## Design & Principles
Ultrasonic rangefinders, akin to RADAR systems, function on the pulse-echo method. The fundamental principle entails transmitting an ultrasonic signal towards an object, receiving the echo signal, and determining the distance based on the signal's travel time.

### Circuit Operation
1. The HC-SR04 module integrates ultrasonic transmitter, receiver, and control circuit on a single board, featuring Vcc, Gnd, Trig, and Echo pins.
2. Sending a pulse of 10µs or more to the Trig pin generates 8 pulses of 40 kHz. Subsequently, the Echo pin is elevated by the module's control circuit.
3. The Echo pin remains high until it receives the echo signal of the transmitted pulses.
4. The duration for which the Echo pin stays high represents the time taken for the ultrasonic sound to travel to and from the object.
5. Utilizing this time and the speed of sound in air, the object's distance can be calculated using a simple formula.

### Distance Calculation
The distance is calculated using the formula: Distance = TimerCount / 54, where TimerCount represents the count obtained from the 8051 microcontroller's timer. With an oscillator frequency of 11.0592 MHz, the timer frequency of 8051 is 921.6 kHz.

## Conclusion
The Ultrasonic Distance Calculator using 8051 offers precise distance measurements through efficient utilization of ultrasonic technology and the capabilities of the 8051 microcontroller. This project showcases the convergence of electronics, microcontrollers, and physics to create a sophisticated distance measurement system.

**Development Environment:** The project was developed using Proteus software for circuit simulation and testing.
