<!-- __JSON: egrunner script.sh # LONG ONLINE

Immutable/persistent data structures in Go
30 Aug 2018

Paul Jolly
modelogiq
paul@myitcv.io
https://myitcv.io
@_myitcv

* Why are immutable/persistent data structures useful?

* A good printer

{{PrintBlockOut "goodprint" | fromHere "// HERE" | indent}}

gives

{{PrintBlockOut "run goodprint" | indent}}

* A bad printer

{{PrintBlockOut "badprint" | fromHere "// HERE" | indent}}

gives

{{PrintBlockOut "run badprint" | indent}}

: Docs can help
: But things get complicated if you're calling deep into other code...
: Make assurances about

* Creating immutable/persistent data structures

Let's create an immutable/persistent equivalent:

{{PrintBlockOut "immprint type" | between "// 1" "// 2" | indent}}

* Running gogenerate

{{PrintBlock "immprint gogenerate" | indent}}

* An "imm" printer

{{PrintBlockOut "immprint type" | between "// 2" "// 3" | indent}}

* Did it work?

{{PrintBlockOut "immprint type" | between "// 3" "// 4" | indent}}

gives:

{{PrintBlockOut "immprint run" | indent}}

* Why did it work?

  type ImmutableMap(type K, V) interface {

     Len() int

     Get(k K) (V, bool)

     Set(k K, v V) ImmutableMap(K, V)

     Del(k K) ImmutableMap(K, V)

     Range() map[K]V
  }

Immutable structs and slices also have their own interface.

* Common immutable interface

  type Immutable(type T) interface {

     Mutable() bool

     AsMutable() Immutable(T)

     AsImmutable(prev Immutable(T)) Immutable(T)

     WithMutable(f func(t Immutable(T))) Immutable(T)

     WithImmutable(f func(t Immutable(T))) Immutable(T)
  }


* Recap

- Write immutable template types as regular go types (structs, maps and slices)
- Use `go`generate` (`immutableGen`) to explode templates
- Write your code in terms of the generated types
- Run `immutableVet` to ensure your code is safe

* Further reading

- [[https://github.com/myitcv/x/blob/master/immutable/_doc/README.md]["Docs"]]

-->

<!-- END -->
