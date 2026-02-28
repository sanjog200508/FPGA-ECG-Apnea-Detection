# FPGA-Based Real-Time ECG Sleep Apnea Detection System

## Overview
This project implements a real-time ECG signal processing system on FPGA (Basys-3) for hardware-based detection of apnea-like patterns. The design performs R-peak detection, RR interval computation, and statistical analysis over a fixed 60-second evaluation window.

Two preloaded ECG datasets (Normal and Apnea) are stored in on-chip Block Memory and can be switched at runtime using switch.

---

## System Architecture

- 100 Hz sampling from 100 MHz clock
- Block Memory Generator IP (COE initialization)
- R-Peak Detection
- RR Interval Computation
- Variance & Irregularity Scoring
- 60-Second Evaluation Window
- Runtime Dataset Switching with Synchronized Reset
- Real-Time BPM Display
- Apnea indication using LED
---

## Key Features

- Fully synchronous modular Verilog design
- Dual dataset comparison (Normal vs Apnea)
- Deterministic time-window processing
- Hardware-based statistical feature extraction
- MATLAB cross-validation of RR and variance metrics

---

## Tools & Technologies

- Verilog HDL
- Xilinx Vivado
- Block Memory Generator IP
- MATLAB (Algorithm Cross-Validation)

---

## Demo

https://drive.google.com/file/d/1lUgYAmjIKPTQgoiC9jjl-aaUNyWbNE_A/view

---

## Folder Structure

```
FPGA-ECG-Apnea-Detection/
│
├── src/
│   ├── ecg_top.v              # Top-level system integration
│   ├── apnea_detection.v      # Apnea classification logic
│   ├── r_peak_detector.v      # R-peak detection module
│   ├── RR_interval.v          # RR interval computation
│   ├── ecg_rom.v              # Normal ECG ROM wrapper
│   ├── apnea_ecg_rom.v        # Apnea ECG ROM wrapper
│
├── data/
│   ├── normal_ecg.coe         # Normal ECG dataset
│   ├── apnea_ecg.coe          # Apnea ECG dataset
│
└── README.md
```
