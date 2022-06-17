---
title: "Rechnerarchitektur"
author: "Oliver Herrmann"
institute: "HTWK Leipzig"
documentclass: beamer
classoption:
  - handout
#date: "07.01.2022"
#theme: "Frankfurt"
#section-titles: true
---

# Algorithmus

- [Fibonacci Folge](https://de.wikipedia.org/wiki/Fibonacci-Folge)
    - 1,1,2,3,5,8,13,...

$f: \mathbb{N} \to \mathbb{N},\; f(n) \mapsto \begin{cases} 1 & n < 2 \\ f(n - 1) + f(n - 2) & sonst\end{cases}$

- Laufzeit: $\mathcal{O}(2^n)$

# Performance

- Laufzeitbetrachtung unterschiedlicher Varianten
    - hängt von Implementierung ab (bei gleicher Spezifikation)

## Varianten

- Iterativ
    - ohne Caching
    - mit Caching
- Rekursiv
    - ohne Caching
    - mit Caching
    - Tailrecursive
    - Tailrecursive + Loop unrolling

## Iterativ

\footnotesize
```{.c include=../Algorithm/fib_iterative.c startLine=4 endLine=100}
```
\normalsize

## Iterativ (Cache)

\footnotesize
```{.c include=../Algorithm/fib_iterative_cache.c startLine=4 endLine=100}
```
\normalsize

## Rekursiv

\footnotesize
```{.c include=../Algorithm/fib_rec.c startLine=3 endLine=100}
```
\normalsize

## Rekursiv (Cache)

\footnotesize
```{.c include=../Algorithm/fib_rec_cache.c startLine=6 endLine=100}
```
\normalsize

## Rekursiv (Tailrecursion)

\footnotesize
```{.c include=../Algorithm/fib_tailrec.c startLine=4 endLine=100}
```
\normalsize

## Rekursiv (Tailrecursion + Loop unrolling)

\footnotesize
```{.c include=../Algorithm/fib_unroll.c startLine=4 endLine=100}
```
\normalsize

## Performance

- Vergleichen der Performance
- Erklären der Ursachen

## Laufzeit Maschine

- AMD Opteron(tm) Processor 6174
    - Freq: 2,2 GHz
    - Cores: 12
    - L1 Cache: 12 x 64 KB 2-way set associative caches
    - L2 Cache: 12 x 512 KB 16-way set associative exclusive caches
    - L3 Cache: 2 x 6 MB shared exclusive caches

## Laufzeit Werte

| Algorithmus | $n = 30$ | $n=10^4$ | $n=10^9$ | `-O3` $n=10^9$ |
|-------------|---------:|----------|---------:|---------------:|
| Iterativ    |   2,4ms  | 3,4ms    |   6,8s   | 1,72s          |
| Iterativ C  |   3,4ms  | 3,7ms    |   18s    | 7,436s         |
| Rekursiv    |   20ms   | -        |   -      | -              |
| Rekursiv C  |   1,5ms  | 4,7ms    |   -      | -              |
| Rekursiv T  |   1,5ms  | 4,4ms    |   -      | 1,74s          |
| Rekursiv U  |   3,4ms  | 3,2ms    |   2,3s   | 0,56s          |

## Warum ist `-O3` schneller als `-O0`?

- Variablen werden in Register gehalten (anstatt auf dem Stack)

## Debug Build (Iterativ)
\footnotesize
```{include=../Algorithm/build/debug/fib_iterative.objdump startLine=10 endLine=20 dedent=8}
```
\normalsize

## Release Build (Iterativ)
\footnotesize
```{include=../Algorithm/build/release/fib_iterative.objdump startLine=9 endLine=23 dedent=8}
```
\normalsize

## Warum die Cache Variante langsamer?

- Load/Store Befehle sind langsam(er)
- Algorithmus ist komplexer (mehr Befehle)

## Perf stat (Iterativ ohne Cache)
\footnotesize
```{include=../Algorithm/build/release/fib_iterative_1000000000.stat startLine=5 endLine=20 dedent=4}
```
\normalsize

## Perf stat (Iterativ mit Cache)
\footnotesize
```{include=../Algorithm/build/release/fib_iterative_cache_1000000000.stat startLine=5 endLine=20 dedent=4}
```
\normalsize

# Pipelining

- Tritt massiv auf
    - vor allem in optimieten Versionen (da weniger Speicherzugriffe)

## Superskalares Pipelining

- kann bei Iterationsschritt (`a = b, b = b + a, n += 1`) genutzt werden

# Caching

- für alle Versionen relevant, die Caches oder Stackvariablen benutzen
- *Rückwärtsdurchlaufen* des Caches ungünstig

# Parallelität

- nicht effektiv nutzbar zur berechnung einer *einzelnen* Fibonacci Zahl
    - bei Nutzung von Cache drohen Data-Races
    - bei Tailrecursion gibt es nur einen Pfad / keine Option zur Parallelisierung
    - (bei simpler rekursiver Variante theoretisch nutzbar)
