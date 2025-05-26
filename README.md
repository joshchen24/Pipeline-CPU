# Lab 2: Pipelined CPU in Verilog

This project implements a 5-stage pipelined RISC-V CPU in Verilog. The design includes proper handling of data and control hazards, forwarding logic, and basic instruction execution. It was developed individually as part of a systems course assignment.

## Overview

The goal of this project was to design and implement a working 5-stage pipelined CPU supporting a subset of RISC-V instructions. The CPU handles hazards using a forwarding unit and introduces stalls and flushes as needed.

## Supported Instructions

The CPU supports the following RISC-V instructions:

- **R-type**: `and`, `xor`, `sll`, `add`, `sub`, `mul`
- **I-type**: `addi`, `srai`, `lw`
- **S-type**: `sw`
- **B-type**: `beq`

## Hardware Specifications

- 32 general-purpose registers (32-bit)
- 1KB instruction memory
- 4KB data memory
- 5 pipeline stages: IF, ID, EX, MEM, WB
- Fully synchronous design

## Usage
```bash
verilog -o cpu_tb.vvp -f filelist.txt -g2012
vvp cpu_tb.vvp
```

## Pipeline Details

### Stages

1. **IF**: Fetch instruction from memory
2. **ID**: Decode instruction and read registers
3. **EX**: Execute ALU operations or compute memory addresses
4. **MEM**: Access data memory for `lw`/`sw`
5. **WB**: Write result back to register file

### Pipeline Registers

Pipeline registers were added between each stage to hold values such as program counters, control signals, and register data for the next stage.

### Hazard Handling

#### Data Hazards

- A forwarding unit is used to reduce stalls for most data hazards.
- For `lw` followed by a dependent instruction, a 1-cycle stall is introduced.
- No forwarding is implemented to the ID stage.

#### Control Hazards

- A 1-cycle stall may occur after a `beq` instruction.
- Pipeline flushes are introduced on branch misprediction.

## Forwarding Logic

Forwarding is handled in the EX stage using the following rules:

### EX Hazard

```verilog
if (EX_MEM.RegWrite &&
    EX_MEM.RegisterRd != 0 &&
    EX_MEM.RegisterRd == ID_EX.RegisterRs1)
    ForwardA = 2'b10;

if (EX_MEM.RegWrite &&
    EX_MEM.RegisterRd != 0 &&
    EX_MEM.RegisterRd == ID_EX.RegisterRs2)
    ForwardB = 2'b10;
```
MEM Hazard
```verilog
Copy code
if (MEM_WB.RegWrite &&
    MEM_WB.RegisterRd != 0 &&
    !(EX_MEM.RegWrite && EX_MEM.RegisterRd != 0 &&
      EX_MEM.RegisterRd == ID_EX.RegisterRs1) &&
    MEM_WB.RegisterRd == ID_EX.RegisterRs1)
    ForwardA = 2'b01;

if (MEM_WB.RegWrite &&
    MEM_WB.RegisterRd != 0 &&
    !(EX_MEM.RegWrite && EX_MEM.RegisterRd != 0 &&
      EX_MEM.RegisterRd == ID_EX.RegisterRs2) &&
    MEM_WB.RegisterRd == ID_EX.RegisterRs2)
    ForwardB = 2'b01;
```
Hazard Detection and Control
A hazard detection unit was implemented to introduce stalls.

Branch control logic flushes the pipeline if a branch is taken incorrectly.

Stall and flush counters were added for visibility during testing and grading.

Testbench Integration
The provided testbench.v:

Initializes instruction and data memory

Simulates the clock

Tracks and logs stalls and flushes

Dumps outputs to output.txt
