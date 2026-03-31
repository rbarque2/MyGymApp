import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'dart:js_interop';
import 'package:web/web.dart' as web;

void playShortBeepImpl() {
  _playWebTone(880, 150);
}

void playLongBeepImpl() {
  _playWebTone(1046, 500);
}

void playRoarImpl() {
  try {
    _playWebRoar();
  } catch (e) {
    debugPrint('Error al reproducir rugido: $e');
  }
}

void _playWebTone(double frequency, int durationMs) {
  final context = web.AudioContext();
  final oscillator = context.createOscillator();
  final gainNode = context.createGain();

  oscillator.type = 'sine';
  oscillator.frequency.value = frequency;
  gainNode.gain.value = 0.5;

  oscillator.connect(gainNode);
  gainNode.connect(context.destination);

  oscillator.start();

  Future.delayed(Duration(milliseconds: durationMs), () {
    oscillator.stop();
    context.close();
  });
}

void _playWebRoar() {
  final context = web.AudioContext();
  final now = context.currentTime;
  final duration = 1.8;

  // — Base growl: sawtooth at low frequency with sweep —
  final growl = context.createOscillator();
  growl.type = 'sawtooth';
  growl.frequency.setValueAtTime(90, now);
  growl.frequency.linearRampToValueAtTime(140, now + 0.3);
  growl.frequency.linearRampToValueAtTime(80, now + 1.0);
  growl.frequency.linearRampToValueAtTime(50, now + duration);

  // — Sub bass layer —
  final sub = context.createOscillator();
  sub.type = 'sine';
  sub.frequency.setValueAtTime(55, now);
  sub.frequency.linearRampToValueAtTime(40, now + duration);

  // — Higher snarl harmonic —
  final snarl = context.createOscillator();
  snarl.type = 'square';
  snarl.frequency.setValueAtTime(180, now);
  snarl.frequency.linearRampToValueAtTime(280, now + 0.2);
  snarl.frequency.linearRampToValueAtTime(120, now + 0.8);
  snarl.frequency.linearRampToValueAtTime(60, now + duration);

  // — Noise-like texture via FM modulation —
  final modulator = context.createOscillator();
  modulator.type = 'sawtooth';
  modulator.frequency.setValueAtTime(30, now);
  modulator.frequency.linearRampToValueAtTime(15, now + duration);
  final modGain = context.createGain();
  modGain.gain.setValueAtTime(50, now);
  modGain.gain.linearRampToValueAtTime(20, now + duration);
  modulator.connect(modGain);
  modGain.connect(growl.frequency);

  // — Waveshaper distortion —
  final waveshaper = context.createWaveShaper();
  final curveLength = 256;
  final curveData = Float32List(curveLength);
  for (var i = 0; i < curveLength; i++) {
    final x = (i * 2 / curveLength) - 1;
    curveData[i] = (x * 1.5).clamp(-1.0, 1.0);
  }
  final jsArray = curveData.toJS;
  waveshaper.curve = jsArray;
  waveshaper.oversample = 'none';

  // — Gain envelopes —
  final growlGain = context.createGain();
  growlGain.gain.setValueAtTime(0.0, now);
  growlGain.gain.linearRampToValueAtTime(0.7, now + 0.15);
  growlGain.gain.setValueAtTime(0.7, now + 0.4);
  growlGain.gain.linearRampToValueAtTime(0.3, now + 1.0);
  growlGain.gain.linearRampToValueAtTime(0.0, now + duration);

  final subGain = context.createGain();
  subGain.gain.setValueAtTime(0.0, now);
  subGain.gain.linearRampToValueAtTime(0.5, now + 0.1);
  subGain.gain.linearRampToValueAtTime(0.0, now + duration);

  final snarlGain = context.createGain();
  snarlGain.gain.setValueAtTime(0.0, now);
  snarlGain.gain.linearRampToValueAtTime(0.25, now + 0.1);
  snarlGain.gain.linearRampToValueAtTime(0.15, now + 0.5);
  snarlGain.gain.linearRampToValueAtTime(0.0, now + duration);

  // — Master volume —
  final masterGain = context.createGain();
  masterGain.gain.value = 0.8;

  // — Wiring —
  growl.connect(growlGain);
  growlGain.connect(waveshaper);
  waveshaper.connect(masterGain);

  sub.connect(subGain);
  subGain.connect(masterGain);

  snarl.connect(snarlGain);
  snarlGain.connect(waveshaper);

  masterGain.connect(context.destination);

  // — Start & stop —
  growl.start();
  sub.start();
  snarl.start();
  modulator.start();

  final stopMs = (duration * 1000).toInt() + 100;
  Future.delayed(Duration(milliseconds: stopMs), () {
    growl.stop();
    sub.stop();
    snarl.stop();
    modulator.stop();
    context.close();
  });
}
