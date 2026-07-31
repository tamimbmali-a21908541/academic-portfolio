# Image Processing

> A C#/EmguCV desktop application that detects and classifies road traffic signs in static images, and reads the number off speed-limit signs — implemented from first principles with pixel-level operations rather than by calling a pre-trained detector.

**Grade:** 13/20 · **ECTS:** 6 · **Year:** 2 · **Institution:** Universidade Lusófona

---

## Overview

The application is a Windows Forms image editor that grew into a traffic-sign recognition pipeline. Every operation is written against the raw pixel buffer — the point of the course was to implement the algorithms, not to consume them.

## The recognition pipeline

```
input image
    │
    ├─► HSV colour segmentation        Hsv_red / Hsv_blue / Hsv_black
    │   isolate sign-coloured regions   (hue-based, robust to lighting)
    │
    ├─► connected component labelling  Etiquetas()
    │   group pixels into candidate blobs
    │
    ├─► shape classification           tipo_de_sinal() / tipoDeTriangulo()
    │   circular = limit/prohibition
    │   triangular = warning
    │
    ├─► digit segmentation             CoordSinal() + ordenarEtiquetas()
    │   isolate and left-to-right order the digits
    │
    ├─► digit recognition              numerosComparar()
    │   pixel-by-pixel template matching against a digit database
    │
    └─► annotate                       MarcarSinais()
        draw boxes and labels on the output
```

**Why HSV, not RGB:** hue separates colour identity from brightness, so a red sign in shade and the same sign in sunlight land in the same hue band. In RGB they don't.

**Why template matching for digits:** with a constrained alphabet (0–9) and normalised, segmented glyphs, direct pixel comparison is accurate and needs no training data.

Sign types are returned separately — `limitSign`, `warningSign`, `prohibitionSign` — so the caller knows both what was found and what class it belongs to.

## Image operations implemented

All written manually against the pixel buffer:

| Category | Operations |
|---|---|
| Point | Negative, greyscale, red channel isolation, brightness/contrast |
| Geometric | Translation, rotation, scaling, scaling about an arbitrary centre |
| Filters | Mean, median, non-uniform (arbitrary convolution kernel), Sobel, differentiation |
| Analysis | Greyscale histogram |
| Thresholding | Fixed threshold, **Otsu** automatic threshold |
| Segmentation | HSV colour masks, connected-component labelling |

## Tech stack

- **C#**, **.NET Framework**, **Windows Forms**
- **EmguCV** — .NET wrapper over OpenCV (used for image I/O and buffer access; the algorithms are hand-written)
- **ZedGraph** — histogram plotting
- **Visual Studio 2017/2022** solution

## Repository contents

```
CG_OpenCV_Base/
├── CG_OpenCV_2021.sln
└── SS_OpenCV/
    ├── ImageClass.cs        # all image algorithms (~280 KB, the core of the project)
    ├── MainForm.cs          # UI, menu wiring, image loading
    ├── InputBox.cs          # parameter prompts
    └── AuthorsForm.cs
```

## Building

Open `CG_OpenCV_Base/CG_OpenCV_2021.sln` in Visual Studio.

> **Note:** the compiled `bin/` and `obj/` directories — including the bundled EmguCV native DLLs — were removed from this repository, as build output does not belong in version control. Restore the EmguCV package (x86 native binaries required) before building.

## Key takeaways

- **Colour space choice is a design decision, not a detail.** Moving segmentation from RGB to HSV was the single change that made detection work across lighting conditions.
- **Connected-component labelling is the bridge** between "pixels of the right colour" and "objects" — everything downstream depends on getting the blobs right.
- **Implementing convolution by hand** made the cost of a kernel obvious in a way that calling a library function never does.
- **A constrained problem allows a simple solution.** Template matching would be hopeless for general OCR, but for ten digits at a known scale it is both simpler and more reliable than a learned model.
