---
title: "Rechnerarchitektur"
author: "Oliver Herrmann"
institute: "HTWK Leipzig"
date: "07.07.2022"
documentclass: beamer
classoption:
  - handout
output:
  beamer_presentation:
    classoption: "aspectratio=169"
#theme: "Frankfurt"
#section-titles: true
---

# Algorithmus

- [Fibonacci Folge](https://de.wikipedia.org/wiki/Fibonacci-Folge): $1,1,2,3,5,8,13,\ldots$

- $f: \mathbb{N} \to \mathbb{N},\; f(n) \mapsto \begin{cases} 1 & n < 2 \\ f(n - 1) + f(n - 2) & sonst\end{cases}$

- Laufzeit: $\mathcal{O}(2^n)$

## Varianten

- Rekursiv
    - ohne Caching
    - mit Caching
    - Tailrecursive
- Iterativ
    - ohne Caching
    - mit Caching
- Loop unrolling

## Rekursiv

\footnotesize
```{.c include=../src/fib_rec.c startLine=3 endLine=100}
```
\normalsize

## Rekursiv (Cache)

\footnotesize
```{.c include=../src/fib_rec_cache.c startLine=6 endLine=100}
```
\normalsize

## Rekursiv (Tailrecursion)

\footnotesize
```{.c include=../src/fib_tailrec.c startLine=4 endLine=100}
```
\normalsize

## Iterativ

\footnotesize
```{.c include=../src/fib_iterative.c startLine=4 endLine=100}
```
\normalsize

## Iterativ (Cache)

\footnotesize
```{.c include=../src/fib_iterative_cache.c startLine=4 endLine=100}
```
\normalsize

## Loop unrolling

\footnotesize
```{.c include=../src/fib_unroll.c startLine=4 endLine=100}
```
\normalsize

# Analyse

## Charakteristik

Größe der Objektdateien

| Algorithmus | `-g -O0` | `-g -O3` |
|-------------|---------:|---------:|
| Iterativ    |   3,5K   | 4,2K     |
| Iterativ C  |   4,2K   | 5,4K     |
| Rekursiv    |   3,4K   | 7,3K     |
| Rekursiv C  |   4,5K   |  12K     |
| Rekursiv T  |   3,8K   | 4,6K     |
| Loop unroll |   3,6K   | 4,2K     |

## Performance

- Vergleichen der Performance
    - Vergleich der Implementierungen
    - Vergleich der Builds
- Erklären der Ursachen

## Laufzeit Maschine

- AMD Opteron(tm) Processor 6174
    - Freq: 2,2 GHz
    - Cores: 12
    - L1 Cache: 12 x 64 KB 2-way set associative caches
    - L2 Cache: 12 x 512 KB 16-way set associative exclusive caches
    - L3 Cache: 2 x 6 MB shared exclusive caches

## Laufzeit Werte

| Algorithmus | `-O0` $n = 30$ | `-O0` $n=10^4$ | `-O0` $n=10^9$ | `-O3` $n=10^9$ |
|-------------|---------------:|---------------:|---------------:|---------------:|
| Iterativ    |   2,9ms        | 3,0ms          |   6,9s         | 1,85s          |
| Iterativ C  |   2,1ms        | 3,3ms          |   18s          | 7,62s          |
| Rekursiv    |   12ms         | -              |   -            | -              |
| Rekursiv C  |   2,6ms        | 4,3ms          |   -            | -              |
| Rekursiv T  |   2,8ms        | 4,1ms          |   -            | 1,91s          |
| Loop unroll |   2,8ms        | 2,9ms          |   2,3s         | 0,69s          |


## Warum ist `-O3` schneller als `-O0`?

- Variablen werden in Register gehalten (anstatt auf dem Stack)
    - Weniger Hauptspeicherzugriffe

## `-O0` Build (Iterativ)
\footnotesize
```{include=../build/debug/fib_iterative.objdump startLine=10 endLine=20 dedent=8}
```
\normalsize

## `-O3` Build (Iterativ)
\footnotesize
```{include=../build/release/fib_iterative.objdump startLine=9 endLine=23 dedent=8}
```
\normalsize

## Warum ist die Cache Variante langsamer?

- Load/Store Befehle sind langsam(er)
- Algorithmus ist komplexer (mehr Befehle)

## Perf stat (Iterativ ohne Cache)
\footnotesize
```{include=../build/release/fib_iterative_1000000000.stat startLine=5 endLine=20 dedent=4}
```
\normalsize

## Perf stat (Iterativ mit Cache)
\footnotesize
```{include=../build/release/fib_iterative_cache_1000000000.stat startLine=5 endLine=20 dedent=4}
```
\normalsize

## Vergleich Iterativ mit Cache $\leftrightarrow$ Iterativ ohne Cache
Cache Variante hat:

- mehr Context-Switches (malloc, free)
- mehr Page Faults (weil Daten aus dem RAM gelesen werden)
- mehr Zyklen (mehr langsame Schreib-/ Leseoperationen)
- mehr Instructions

## Perf stat (Tailrecursion)
\footnotesize
```{include=../build/release/fib_tailrec_1000000000.stat startLine=5 endLine=20 dedent=4}
```
\normalsize

## Vergleich Tailrecursion $\leftrightarrow$ Iterativ

Tailrec hat im Vergleich zu Iterative ähnliche:

- Laufzeit
- Context-Switches
- Page-Faults
- Zyklen
- Instructions
- Branches

$\rightarrow$ Compiler macht 'den selben' Code daraus

###
``To iterate is human, to recurse is divine''

\hfill - L Peter Deutsch

## Perf stat (Loop unrolling)
\footnotesize
```{include=../build/release/fib_unroll_1000000000.stat startLine=5 endLine=20 dedent=4}
```
\normalsize

## Vergleich Loop unrolling $\leftrightarrow$ Tailrecursion / Iterativ
Loop unrolling hat im Vergleich zu Tailrecursion / Iterative:

- bessere Laufzeit
- weniger Context-Switches
- weniger Zyklen
- weniger Instructions
- weniger Branches(!)
- weniger Branch-Misses

$\rightarrow$ ``Weniger Sprünge und mehr Rechenoperationen sind gut''

# Pipelining

- Effizient nutzbar
    - vor allem in optimierten Versionen (da weniger Speicherzugriffe)

## Iterative (Cache) `-g`

![](./iterative_cache_debug.png)

## Tailrecursion `-03`

![](./tailrec_release.png)

## Superskalares Pipelining

- kann bei Iterationsschritt (`a = b, b = b + a, n += 1`) genutzt werden
    - Berechnungen können parallel stattfinden, wenn mehrere ALUs vorhanden sind

# Caching

- für alle Versionen relevant bei
    - Nutzung von Stackvariablen
    - Verwendung von explizitem Caches
- *Springendes* Abfragen des Caches ungünstig

###
\footnotesize
```{.c include=../src/fib_rec_cache.c startLine=21 endLine=26}
```
\normalsize

# Parallelität

- nicht effektiv nutzbar zur Berechnung einer *einzelnen* Fibonacci Zahl
    - bei Nutzung von Cache drohen Data-Races
    - bei Iteration / Tailrecursion gibt es nur einen Pfad $\rightarrow$ keine Option zur Parallelisierung
    - (bei simpler rekursiver Variante theoretisch nutzbar)

# Fazit

- Fibonacci kann effektiv implementiert und ausgeführt werden
- Rechenlastige Algorithmus $\rightarrow$ effektiv ausführbar
- Explizites Caching nicht immer optimal

## Hyperlinks

Repository: https://github.com/herrmanno/C827-rechnerarchitektur

\begin{center}
%![qr-code to repository](./qr-code.png) { .center width=400 }
\includegraphics[width=0.5\textwidth]{./qr-code.png}
\end{center}
