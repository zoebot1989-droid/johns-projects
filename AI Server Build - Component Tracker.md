# 🖥️ John's AI Server Build — Component Tracker

## Target Build: Single PC AI Workstation (Phase 1)
Goal: Run 70B+ parameter LLMs locally with room to grow into a multi-node cluster.

## Components Needed

### GPU (Most Important)
| Option | VRAM | Est. Price | Notes |
|--------|------|-----------|-------|
| NVIDIA RTX 5090 | 32GB | ~$1,999 | Latest gen, best perf/watt |
| NVIDIA RTX 4090 | 24GB | ~$1,200-1,600 (used) | Great value used, proven |
| NVIDIA RTX 5080 | 16GB | ~$999 | Budget option, less VRAM |
| NVIDIA A6000 (used) | 48GB | ~$2,500-3,500 | Enterprise, huge VRAM |
| NVIDIA A100 (used) | 80GB | ~$5,000-8,000 | Data center king, prices dropping |

**Ideal: 2x RTX 4090 (used) or 1x RTX 5090 to start**

### CPU
| Option | Cores | Est. Price | Notes |
|--------|-------|-----------|-------|
| AMD Threadripper 7960X | 24C/48T | ~$1,400 | 48 PCIe 5.0 lanes |
| AMD Threadripper 7970X | 32C/64T | ~$2,500 | More headroom |
| AMD Ryzen 9 9950X | 16C/32T | ~$550 | Budget option, still solid |
| Intel i9-14900K | 24C/32T | ~$450 | Budget alternative |

**Ideal: Ryzen 9 9950X (budget) or Threadripper 7960X (future-proof)**

### Motherboard
| Option | Est. Price | Notes |
|--------|-----------|-------|
| ASUS Pro WS WRX90E (Threadripper) | ~$900 | 7 PCIe slots, built for multi-GPU |
| ASUS ROG Crosshair X870E (AM5) | ~$500 | 2 GPU slots, consumer |
| Gigabyte TRX50 AERO D (Threadripper) | ~$850 | Good multi-GPU support |

### RAM
| Option | Est. Price | Notes |
|--------|-----------|-------|
| 128GB DDR5 (4x32GB) | ~$350-500 | Minimum for 70B models |
| 256GB DDR5 (8x32GB) | ~$700-1,000 | Ideal for model loading |

### Storage
| Option | Est. Price | Notes |
|--------|-----------|-------|
| 2TB NVMe Gen4 SSD | ~$120-150 | Model storage + OS |
| 4TB NVMe Gen4 SSD | ~$250-300 | Room for multiple models |

### Power Supply
| Option | Est. Price | Notes |
|--------|-----------|-------|
| 1600W 80+ Platinum (e.g. Corsair HX1600i) | ~$400 | Needed for multi-GPU |
| 1200W 80+ Gold | ~$200 | Enough for single GPU |

### Case
| Option | Est. Price | Notes |
|--------|-----------|-------|
| Fractal Torrent XL | ~$250 | Excellent airflow, fits E-ATX |
| Phanteks Enthoo Pro 2 | ~$170 | Budget, great space |

### Cooling
| Option | Est. Price | Notes |
|--------|-----------|-------|
| Noctua NH-D15 (air) | ~$110 | Reliable, no leak risk |
| 360mm AIO (e.g. Arctic Liquid Freezer III) | ~$130 | Better for Threadripper |

---

## Budget Tiers

### 🟢 Starter ($2,500-3,500)
- Ryzen 9 9950X
- 1x RTX 4090 (used)
- 128GB DDR5
- 2TB NVMe
- 1200W PSU
- Can run: up to 33B models full speed, 70B quantized

### 🟡 Solid ($5,000-7,000)
- Ryzen 9 9950X or Threadripper 7960X
- 2x RTX 4090 (used) or 1x RTX 5090
- 128-256GB DDR5
- 4TB NVMe
- 1600W PSU
- Can run: 70B models full speed, 110B quantized

### 🔴 Beast ($10,000-15,000)
- Threadripper 7970X
- 2x RTX 5090 or 2x A6000
- 256GB DDR5
- 4TB NVMe
- 1600W PSU
- Can run: 110B+ models, cluster-ready

---

## Price Tracking Status
Last checked: TBD
Next check: Weekly

## Notes
- Watching for RTX 4090 used price drops
- Watching for A100 secondary market deals
- New AMD GPUs (MI300 series) on enterprise market
- Phase 2: Add second node and InfiniBand switch
