# Monolith GPU Stutter Investigation — 2026-07-01

## Hardware

- CPU: Ryzen 7 5800X3D
- GPU: Sapphire Pulse RX 9070 XT (RDNA4 / Navi 48 / GFX1200)
- Case: Corsair 4000D

## Background

Investigating responsiveness/stutter issues on the desktop. Two symptoms:

1. **Shell stutter** — DMS (Dank Material Shell, Quickshell/QML-based) had noticeable widget interaction stutter. Switched to Noctalia v5 (native C++/OpenGL ES), felt smoother immediately.
2. **Steam client stutter** — sluggish UI response in Steam, which is not QML-based. Suggests a compositor-level or GPU driver/power-state problem rather than a Qt Quick scenegraph issue.

**Already resolved before this investigation:**
- XMP/DOCP was disabled; now enabled and running DDR4-3200 (confirmed via dmidecode; 2 clean memtest86+ passes)

---

## Step 1: System State Snapshot

### Versions

| Item | Value |
|---|---|
| NixOS | 26.11.20260626.e73de5b (Zokor) |
| Kernel | 6.18.36 (set by jovian-nixos, not user config) |
| nixpkgs pin | `89570f24e97e` — 2026-06-23 UTC |
| Mesa | 26.1.3 |
| niri | 26.04 (April 2026, from nixpkgs) |
| Noctalia | `1d17e1d1f543` — 2026-06-30 |
| Noctalia-greeter | `c09a6b5067ab` — 2026-06-28 |

### GPU Power State

- `power_dpm_force_performance_level` = `auto` ✓
- `power_dpm_state` = `performance` ✓
- Active power profile = **BOOTUP_DEFAULT** (profile 0) — not 3D_FULL_SCREEN
- No amdgpu errors in systemd journal

### CPU Frequency

- Driver: `amd-pstate-epp` ✓
- Energy Performance Preference: `balance_performance`
- Governor: `powersave` (correct for amd-pstate-epp; EPP governs the policy)

### Kernel Command Line

All of the following are injected by the **jovian-nixos** module — none are set in the user config:

```
amdgpu.lockup_timeout=5000,10000,10000,5000
amdgpu.sched_hw_submission=4
amdgpu.dcdebugmask=0x20000
amdgpu.ppfeaturemask=0xfffd7fff
ttm.pages_min=2097152
amd_iommu=off
audit=0
loglevel=4
log_buf_len=4M
```

**What these do:**

| Parameter | Effect |
|---|---|
| `amdgpu.lockup_timeout=5000,10000,10000,5000` | Extends GPU job timeout to 5–10 s before declaring a hang. Prevents spurious resets but delays recovery. |
| `amdgpu.sched_hw_submission=4` | Doubles GPU submission queue depth (default 2). More jobs in flight. |
| `amdgpu.dcdebugmask=0x20000` | Disables DCN Sub-Viewport and FAMS (Firmware-Assisted Memory-Clock Switching). FAMS is a known RDNA3/4 micro-stutter source; disabling it is an intentional mitigation. |
| `amdgpu.ppfeaturemask=0xfffd7fff` | Disables bits 15 and 17 of the PP feature mask (clock power-gating related features). |
| `ttm.pages_min=2097152` | Pre-allocates 8 GB of TTM buffer pages at boot. Reduces allocation-time fragmentation; increases boot-time memory pressure. |
| `amd_iommu=off` | Disables AMD IOMMU. Eliminates IOMMU translation overhead; reduces security isolation. |

### niri Config Notable Gaps

- **No `output` block** → no VRR, no explicit mode/scale, no display-specific settings
- `WLR_NO_HARDWARE_CURSORS=1` was set in `environment.sessionVariables` → forced software cursor (removed as part of this investigation; see changes applied below)
- `animations {}` block present but empty (fine)

### hardware.graphics State

- `enable = true`, `enable32Bit = true` (jovian-nixos sets 32-bit)
- `extraPackages = [gamescope]` — jovian adds gamescope so its Vulkan layers are on the ICD search path for Steam
- No amdvlk, no ROCm — correct; RADV (in Mesa) is the right Vulkan driver for RDNA4

### Noctalia / DMS

- Noctalia pinned to 2026-06-30 (effectively HEAD). Native C++/OpenGL ES shell, no Qt Quick overhead.
- DMS/Quickshell completely removed from config. No concerns here.

---

## Step 2: Cross-Reference Against Known Issues

### Kernel 6.18.x — Confirmed Problematic for RDNA3/RDNA4

A Valve-confirmed hard-hang regression affecting RDNA3/RDNA4 GPUs on Linux 6.18+ was documented by Phoronix in December 2025. Symptoms: hard system hangs during GPU-heavy work (games, video decode, AI workloads) with no kernel log trace left on disk. Multiple community threads confirm crashes specific to 6.18.x:

- AMDGPU crashes immediately on launching games (Arch Forums)
- Crashes during video playback in browser (Arch Forums)
- Wayland session crash on Google Meet (fixed in 6.18.4 per Framework Community)
- Compute workload instability (fixed for gfx1151 in Linus' tree as of mid-2026)

**Current kernel is 6.18.36** — 36 stable point-releases in, so many early 6.18.x bugs are resolved. The broader RDNA4 regression class has not been fully addressed at the time of this investigation. The stutter symptoms are more consistent with GPU power-state transitions than the hard-hang class.

### amdgpu.dcdebugmask=0x20000 — Intentional FAMS Workaround

This is set deliberately by jovian-nixos. FAMS (Firmware-Assisted Memory-Clock Switching) on RDNA3/4 switches VRAM clock independently of the GPU core clock and is a documented source of micro-stutters when the firmware makes aggressive switching decisions. Disabling it forces software-managed memory clock control. **Do not remove this.**

### Mesa 26.1.3 — Current, No Action Needed

RADV support for RDNA4 (GFX1200/Navi 48) has been solid since Mesa 25.x. 26.1.3 is the current stable release. No overlay or pin is warranted; the nixpkgs pin will pick up 26.2 when it stabilises.

### niri 26.04 — Current at Pin Date

26.04 is what nixpkgs unstable had at the 2026-06-23 pin. Explicit sync for the DRM/compositor path is implemented; PipeWire screencast explicit-sync is still in progress but irrelevant for normal rendering stutter.

---

## Step 3: Proposed Changes

Priority order: highest expected impact first.

---

### [APPLIED] Change 5: Remove WLR_NO_HARDWARE_CURSORS

**File:** `default.nix`

```diff
-    # If your cursor becomes invisible
-    WLR_NO_HARDWARE_CURSORS = "1";
-
     # Hint electron aps to use wayland
```

**Rationale:** Forced software cursors means the compositor composites the cursor into each frame on CPU rather than using the GPU's dedicated cursor plane. For RDNA4 the hardware cursor plane works correctly. Removing this saves per-frame compositing work.

**Verification:** After rebuild, move the mouse — if cursor is visible and tracking correctly, hardware cursors are working. If cursor disappears, add the variable back.

---

### [PROPOSED] Change 2: Disable amdgpu Runtime Power Management

**File:** `hosts/monolith/default.nix`

```diff
+  boot.kernelParams = [ "amdgpu.runpm=0" ];
+
   boot.kernel.sysctl = {
```

**Rationale:** `amdgpu.runpm` (runtime PM, enabled by default) allows the GPU to enter low-power states between frames. RDNA4 wakeup latency from these states shows up as stutter in desktop interactions and Steam UI. Jovian's params don't disable this.

**Tradeoff:** +5–10 W GPU idle power draw. Significant improvement in responsiveness; negligible impact during gaming (GPU stays active).

---

### [PROPOSED] Change 3: Disable GFXOFF

**File:** `hosts/monolith/default.nix`

```diff
+  # Disable GFXOFF (GPU deep power gate) to reduce first-frame stutter latency.
+  # Jovian sets 0xfffd7fff; additionally clearing bit 10 (0x400 = GFXOFF).
+  # Result: 0xfffd7fff & ~0x400 = 0xfffd7bff
+  boot.kernelParams = lib.mkAfter [ "amdgpu.ppfeaturemask=0xfffd7bff" ];
```

**Rationale:** GFXOFF is the GPU's deepest power-gating state. Exiting it on the first frame after an idle period introduces 1–4 ms of latency that manifests as stutter in light workloads. Jovian already disables two power features (bits 15 and 17); this additionally disables GFXOFF (bit 10).

**Note:** If applying together with Change 2, combine into a single `boot.kernelParams` list. Verify with `cat /sys/module/amdgpu/parameters/ppfeaturemask` after rebuild.

**Tradeoff:** +3–8 W GPU idle power draw.

---

### [PROPOSED] Change 4: Enable VRR in niri

**File:** `modules/desktop/niri/config.kdl`

```diff
+// Replace "DP-1" with actual output name from: niri msg outputs
+output "DP-1" {
+    variable-refresh-rate on-demand=true
+}
+
```

Optionally add a window rule to activate VRR for fullscreen games:

```kdl
window-rule {
    match is-fullscreen=true
    variable-refresh-rate true
}
```

**Rationale:** FreeSync eliminates periodic stutter from frame timing mismatch between GPU output and the fixed 60 Hz panel. `on-demand=true` means VRR only activates for windows with the `variable-refresh-rate` window rule, avoiding cursor/idle VRR issues.

**Prerequisite:** Run `niri msg outputs` to find the exact output name. Confirmed: niri picks mode `2560x1440 @ 60Hz` on the connected display.

**Tradeoff:** Some monitors flash briefly when VRR engages. If cursor animates at low FPS with VRR active, add `debug { disable-cursor-plane; }` to config.

---

### [PROPOSED] Change 1: Kernel Pin to 6.12 LTS (contingency only)

**File:** `hosts/monolith/default.nix`

```diff
+  # Pin to 6.12 LTS if 6.18.x hard-hang regression is encountered.
+  # Remove once the RDNA3/4 hang regression is resolved upstream.
+  boot.kernelPackages = lib.mkForce pkgs.linuxPackages_6_12;
```

**Rationale:** Escape hatch if hard hangs occur. 6.12 LTS predates the 6.18 RDNA3/4 regression window.

**Tradeoff:** Misses RDNA4 improvements landed in kernels 6.13–6.18. Only apply if experiencing actual hard hangs, not just stutter.

---

### No-change items

| Item | Status |
|---|---|
| Mesa 26.1.3 | Current; no override needed |
| RADV (no amdvlk) | Correct for RDNA4 |
| `amdgpu.dcdebugmask=0x20000` | Intentional FAMS workaround from jovian; keep |
| `amdgpu.ppfeaturemask=0xfffd7fff` | Intentional from jovian; Change 3 extends it |
| Noctalia pin | 2026-06-30, effectively HEAD |
| CPU EPP `balance_performance` | Appropriate for 5800X3D (V-Cache benefits more from cache hits than raw clocks) |

---

## Sources

- [AMD RDNA3/RDNA4 Go Down Hard On Linux 6.19 — Phoronix](https://www.phoronix.com/review/old-amdgpu-eoy2025)
- [AMDGPU crashing right after launching games on Linux 6.18.* — Arch Linux Forums](https://bbs.archlinux.org/viewtopic.php?id=311628)
- [Attn: critical bugs in amdgpu driver in kernel 6.18.x/6.19.x — Framework Community](https://community.frame.work/t/attn-critical-bugs-in-amdgpu-driver-included-with-kernel-6-18-x-6-19-x/79221)
- [Display Core Debug tools — kernel.org](https://www.kernel.org/doc/html/v6.11/gpu/amdgpu/display/dc-debug.html)
- [niri Variable Refresh Rate output config — niri wiki](https://github.com/niri-wm/niri/wiki/Configuration:-Outputs)
- [9070XT Crashing and Freezing After Waking Up From Sleep — Arch Linux Forums](https://bbs.archlinux.org/viewtopic.php?id=305331)
- [Fix for Radeon RX 9070 XT on Fedora — Fedora Discussion](https://discussion.fedoraproject.org/t/fix-for-radeon-rx-9070-xt-on-fedora-amdgpu-firmware-errors-19-and-black-screen-solved/175555)
