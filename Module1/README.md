# Module 1 — Docker & Container Fundamentals

Images, containers, volumes and Dockerfiles — the runtime foundation that Kubernetes builds on. Only the Docker you need for Kubernetes: you run nginx, then build and harden your own Node.js API with a multi-stage Dockerfile and push it to Docker Hub (`techitfactory`). Module 2 runs that image on a cluster.

## What's in this folder

| File | What it is |
|---|---|
| [demo.html](demo.html) | Step-by-step hands-on lab — 16 steps, every command copy-paste ready with expected output |

Open the `.html` files in any browser. The lab page and the trainer script link to each other: every lecture names the slides it covers and the lab step to run.

## Prerequisites

- Docker Desktop (macOS / Windows) or Docker Engine (Linux) — the lab was verified with Docker Engine 29.
- A terminal: bash or zsh on macOS or Linux, or WSL2 on Windows.
- A free Docker Hub account and a personal access token with Read & Write access (Step 14). The instructor pushes to `techitfactory`; learners use their own account.
- No Kubernetes knowledge needed — this is the starting point.

## Lab outline

| Part | Topic | Steps |
|---|---|---|
| A | Warm-up: run and manage containers | Steps 1–7 · nginx web server · ~30 min |
| B | Build and configure your own images | Steps 8–10 · ~20 min |
| C | Production-grade project | Steps 11–15 · Node.js API · ~35 min |
| D | Clean up | Step 16 · ~5 min |

## After this module you can

- Explain image vs container, layers and the container lifecycle.
- Run, inspect, debug and clean up containers; keep data in a named volume.
- Write a small, secure multi-stage Dockerfile (non-root user, pinned base image, health check).
- Tag and push an image to Docker Hub, ready for any Kubernetes cluster to pull.

## Verified with

Docker Engine 29. Every lab step was run on a live cluster; names, IPs and timings in the expected output will differ from yours.
