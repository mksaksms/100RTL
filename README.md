🔐 RTL Hardware Design & Security Library
From Logic Gates to Hardware Security Primitives

This repository contains 99 Verilog RTL modules ranging from fundamental digital logic circuits to advanced cryptographic and hardware security architectures.
It’s designed for students, researchers, and engineers exploring FPGA design, ASIC development, and secure digital system architectures.

📘 Overview

This collection is structured as a progressive learning and experimentation framework:

🧩 Level 1–20: Core combinational & sequential logic

⚙️ Level 21–50: Finite-state machines, registers, counters, and memory

⚡ Level 51–80: Timing, control, synchronization, and arithmetic datapaths

🔐 Level 81–99: Advanced security-focused RTL — from TRNGs to AES, Galois multipliers, watermarking, and secure boot controllers.

Each module is synthesizable, self-contained, and suitable for FPGA testing on platforms like Xilinx, Intel, or Lattice.

🧠 Highlights — Security-Focused RTL Designs (81–99)
#	Module	Description
86	TRNG_FPGA	True Random Number Generator using metastability and ring oscillators
87	Finite_Field_Multiplier	GF(2ⁿ) modular multiplication
88	ITA_Algorithm	Itoh–Tsujii Inversion Algorithm (GF(2⁸))
89	SHA_256_basic	Basic SHA-256 hash function pipeline
90	Watermarking	RTL watermark for anti-cloning & IP protection
91	GCD_Algorithm	Euclid & Binary GCD implementations
92	Matrix_Multiplication	Synthesizable NxN matrix multiply core
93	XTime_Function	AES xtime() operator (GF(2⁸) multiply-by-2)
94	Galois_Field_Multiplier	Polynomial-based GF(2⁴) or GF(2⁸) multiplier
95	Mastrovito_4bit	Mastrovito-style modular GF multiplier
96	Montgomery	Modular multiplication for cryptographic arithmetic
96b	Montgomery_Ladder	Secure laddering for ECC scalar multiplication
97	BranchFree_Swap	Conditional swap for constant-time crypto
97b	Karatsuba	Recursive large-number multiplier
98	Tiny_Galois_LFSR	Compact Galois Linear Feedback Shift Register
99	TPU2	Minimal matrix multiply TPU-like architecture
🧩 Core RTL Modules (1–80)

Includes full coverage of:

Logic gates, adders, subtractors, multipliers

FSM (Mealy/Moore), flip-flops, synchronizers

Encoders, decoders, multiplexers, counters

FIFO, RAM, ROM, registers, timing monitors

Clock gating, glitch filters, redundant checkers

Priority encoders, datapath design, and pipeline templates


<img width="1028" height="491" alt="image" src="https://github.com/user-attachments/assets/4fa168f1-88f8-4da6-b1cb-efedd7999937" />


❤️ Acknowledgment

“Hardware security starts at the transistor, but trust begins in your RTL.”

If you find this repo useful, please ⭐ it and share it with your FPGA / ASIC / hardware security peers.
Let’s make open-source secure RTL design a movement.
