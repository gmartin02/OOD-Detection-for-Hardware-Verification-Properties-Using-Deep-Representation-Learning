# OOD Detection for Hardware Verification Properties Using Deep Representation Learning

**EEL 6812 — Robust Deep Learning | Spring 2026**  
**Author:** Gabriel Martin — Department of Computer Engineering

---

## Overview

Formal hardware verification engineers frequently reuse SystemVerilog Assertions (SVA) across RTL modules, risking silent incompatibilities that waste significant debugging effort. This project frames **property–design mismatch detection as an out-of-distribution (OOD) detection problem**.

The pipeline:
- Represents RTL modules as **18-dimensional structural feature vectors** extracted from Abstract Syntax Trees (ASTs)
- Encodes SVA properties using a **BiLSTM with three-way pooling** (mean, max, learned attention)
- Fuses both modalities through a **four-way interaction head**
- Trains with a **composite loss** combining cross-entropy, cosine embedding loss, and energy-bounded learning
- Flags mismatched property–design pairs at inference time using a **logit-derived energy score**

Three training configurations are evaluated on a benchmark of **22 open-source RTL modules** (296 total SVA properties):

| Configuration | Accuracy | F1 | AUROC (Energy) |
|---|---|---|---|
| Random Baseline | 0.500 | 0.500 | 0.500 |
| Base LOO | 0.644 | 0.692 | 0.634 |
| LOO + EBL | 0.642 | 0.625 | 0.676 |
| Random Split + EBL | 0.746 | 0.783 | 0.758 |

---

## Repository Structure

```
├── EEL6812_Final_Project.ipynb   # Main notebook — all code, training, and evaluation
├── data/
│   ├── rtl/                      # 22 RTL modules (.sv files)
│   └── sva/                      # 22 SVA property files (.sva), one per module
├── EEL6812_Final_Report.pdf      # Final project report (ICML 2026 format)
└── README.md
```

The `data/rtl/` directory contains the following modules:
`barrel_shifter`, `clock_divider`, `comparator`, `crc_generator`, `dual_port_ram`, `edge_detector`, `fifo`, `fixed_latency_pipeline`, `fsm_controller`, `handshake_ctrl`, `lzc`, `mux_tree`, `parity_unit`, `popcount`, `priority_encoder`, `pulse_stretcher`, `reg_file`, `rr_arbiter`, `shift_register`, `skid_buffer`, `updown_counter`, `watchdog_timer`

Each module has a matching `.sva` file in `data/sva/` containing 8–12 manually written SVA properties.

> **Note:** Model checkpoints are not included in this repository due to file size. All checkpoints can be reproduced by running the notebook from scratch (see instructions below). Training takes approximately 15–30 minutes on a free Colab GPU.

---

## How to Run

This project is designed to run entirely in **Google Colab**. No local installation is required.

### Step 1 — Open the notebook in Colab

Navigate to [Google Colab](https://colab.research.google.com) and upload the notebook.

### Step 2 — Upload the data files

When you reach **Cell 2** of the notebook, it will prompt you to upload your `.sv` and `.sva` files using the Colab file upload widget. Upload all files from the `data/rtl/` and `data/sva/` directories of this repository. File names must match exactly (e.g., `fifo.sv` paired with `fifo.sva`).

### Step 3 — Run cells in order

Run all cells from top to bottom. Each cell is labeled with its purpose. The notebook is organized as follows:

| Cell | Purpose |
|---|---|
| Cell 1 | Install dependencies (`sv2v`, `pyverilog`, etc.) |
| Cell 2 | Upload `.sv` and `.sva` files |
| Cell 3 | Convert `.sv` → `.v` using `sv2v` |
| Cell 4 | Extract 18-dimensional RTL feature vectors |
| Cell 4b | Dataset overview visualizations |
| Cell 5 | Identifier anonymization |
| Cell 6 | SVA tokenizer and vocabulary construction |
| Cell 7 | Model definition (BiLSTM + joint classifier) |
| Cell 8 | Dataset and DataLoader construction |
| Cell 9 | Metrics (AUROC, FPR@95%TPR, F1) |
| Cell 10 | **Base LOO training** |
| Cell (EBL) | **Random Split + EBL training** |
| Cell (LOO EBL) | **LOO + EBL training** |
| Results Selector | Choose which run to use for downstream plots |
| Cell 11 | Training curves and per-module AUROC |
| Cell 13 | Energy score distributions and ROC curves |
| Cell 14 | Anonymization ablation |
| Cell 15 | Anonymization ablation visualization |
| Cell 16 | Architecture ablation (RTL-only, SVA-only, joint) |
| Cell 17 | Error analysis |
| Cell 18 | Download all output figures |

### Step 4 — (Optional) Switch active results

After training, the **Results Selector** cell lets you switch between `"base"` (Base LOO) and `"loo_ebl"` (LOO + EBL) to use either run for all downstream visualizations. Change the `ACTIVE_RESULTS` variable and re-run from that cell.

---

## Dependencies

All dependencies are installed automatically by Cell 1. For reference, the key packages are:

- `torch` — PyTorch (pre-installed on Colab)
- `numpy`, `sklearn`, `matplotlib` — pre-installed on Colab
- `pyverilog` — RTL AST parsing
- `pyyaml` — configuration utilities
- `sv2v` v0.0.12 — SystemVerilog to Verilog conversion (downloaded as a binary by Cell 1)
- `iverilog` — required by pyverilog (installed via `apt` by Cell 1)

No GPU is required, but a Colab T4 GPU is strongly recommended to reduce training time. The notebook automatically detects and uses CUDA if available.