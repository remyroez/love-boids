# BOIDS

:bird: Boids simulator with LÖVE

![Screenshot](https://user-images.githubusercontent.com/1193542/60385219-d2f2bd80-9ac1-11e9-80d4-79315347723b.png)

## Window

- Rule
    - Play/Stop button: Toggle simulation.
    - New button: Open "New" dialog.
    - Separation: Separation rate (0 .. 1)
    - Alignment: Alignment rate (0 .. 1)
    - Cohesion: Cohesion rate (0 .. 1)

- New
    - Boids: Number of boids.
    - Width: Field width.
    - Height: Field height.
    - Cancel button: Close dialog.
    - New button: Reset boids and field.

## Getting Started

### Quick Start

1. Download and install [LÖVE](https://love2d.org/) 11.2.
1. Download the latest version of `love-boids.love` game distribution from release.
1. Open the distribution with LÖVE.

### Build and Run from Source

```
git clone https://github.com/remyroez/love-boids.git
cd love-boids/game
love .
```

## Requirements

- [LÖVE](https://love2d.org/) 11.2

## Libraries

- [middleclass](https://github.com/kikito/middleclass) v4.1.1
- [windfield](https://github.com/adnzzzzZ/windfield) commit [830c6f9](https://github.com/adnzzzzZ/windfield/tree/830c6f9c357f31f5c0e53d5721e6dc0d0ccebae1) on 7 Apr 2018 (customized)
- [lume](https://github.com/rxi/lume) commit [d8c2edd](https://github.com/rxi/lume/tree/d8c2eddc10af994ad4956cf0b7ae7188e86db47e) on 15 Mar
- [Slab](https://github.com/coding-jackalope/Slab) v0.4.0

## License

MIT License
