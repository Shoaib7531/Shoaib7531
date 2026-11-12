<img width="1363" height="912" alt="Screenshot 2026-11-12 230409" src="https://github.com/user-attachments/assets/dd02e64b-c471-4ab9-9ea4-92360f1cec9b" />
# SATARK.AI: Layer 5 UPI Intent & Persuasion Shield

A client-side point-of-payment intervention prototype that decodes social engineering manipulation in the critical 30-second window before UPI PIN authorization.

## File Structure

| File | Purpose |
|---|---|
| **[`index.html`](file:///C:/Users/ratho/.gemini/antigravity/scratch/satark-prototype/index.html)** | Master 4-tab interactive prototype UI (Stack, Problem, Simulator, Benchmark). |
| **[`styles.css`](file:///C:/Users/ratho/.gemini/antigravity/scratch/satark-prototype/styles.css)** | Custom styles, typography, scrollbars, and threat pulse animations. |
| **[`radar.js`](file:///C:/Users/ratho/.gemini/antigravity/scratch/satark-prototype/radar.js)** | Persuasion signal radar, intent scoring, and multilingual messages (Hindi, Hinglish, Tamil, Telugu, English). |
| **[`app.js`](file:///C:/Users/ratho/.gemini/antigravity/scratch/satark-prototype/app.js)** | UI state controller, phone simulation, and 8s cognitive pause timer. |
| **[`dataset.json`](file:///C:/Users/ratho/.gemini/antigravity/scratch/satark-prototype/dataset.json)** | 30 curated test vectors across 6 Indian fraud archetypes and legitimate controls. |
| **[`evaluator.ps1`](file:///C:/Users/ratho/.gemini/antigravity/scratch/satark-prototype/evaluator.ps1)** | Automated benchmark evaluation runner for Windows PowerShell. |
| **[`evaluator.js`](file:///C:/Users/ratho/.gemini/antigravity/scratch/satark-prototype/evaluator.js)** | Standalone evaluation script for Node.js / JavaScript runtimes. |

## Quick Start

### 1. View Interactive Web Prototype
Double-click or open `index.html` in any web browser.

### 2. Run Automated Verification (PowerShell)
```powershell
powershell -ExecutionPolicy Bypass -File evaluator.ps1
```

## Key Evaluation Results
- **Overall Accuracy:** 96.67% (29 / 30)
- **Scam Recall (Catch Rate):** 93.75% (15 / 16)
- **Precision:** 100.0% (Zero false alarms on routine groceries, rent, BBPS)
- **False Alarm Rate:** 0.0%
