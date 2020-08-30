# ArangoDBInterface

| **Documentation**                        |
|:----------------------------------------:|
| [![][docs-stable-img]][docs-stable-url]  |

[docs-stable-img]: https://img.shields.io/badge/docs-stable-blue.svg
[docs-stable-url]: https://homalg-project.github.io/ArangoDBInterface/doc/chap0.html

[tests-img]: https://github.com/homalg-project/ArangoDBInterface/workflows/Tests/badge.svg
[tests-url]: https://github.com/homalg-project/ArangoDBInterface/

[codecov-img]: https://codecov.io/gh/homalg-project/ArangoDBInterface/branch/master/graph/badge.svg
[codecov-url]: https://codecov.io/gh/homalg-project/ArangoDBInterface

The following example requires a running `arangod` on your system with a database having the following specifications:

* database: `example`
* username: `root_example`
* password: `password`

Before you can run the example check you can run this command:
```
arangosh --server.username root_example --server.database example --server.password password
```

```gap
gap> LoadPackage( "ArangoDBInterface" );
true
gap> db := AttachAnArangoDatabase( );
[object ArangoDatabase "example"]
gap> db._isSystem();
false
gap> db._name();
"example"
gap> db._drop( "test" );
true
gap> coll := db._create( "test" );
[ArangoCollection "test"]
gap> db.test;
[ArangoCollection "test"]
gap> coll.count();
0
gap> db.test.count();
0
gap> InsertIntoDatabase( rec( _key := "1", TP := "x-y" ), coll );
[ArangoDocument]
gap> coll.count();
1
gap> db._truncate( coll );
true
gap> coll.count();
0
gap> coll.save( rec( _key := "1", TP := "x-y" ) );
[ArangoDocument]
gap> coll.count();
1
gap> db._truncate( coll );
true
gap> coll.count();
0
gap> coll.save( rec( _key := "1", TP := "x-y" ) );
[ArangoDocument]
gap> coll.save( rec( _key := "2", TP := "x*y" ) );
[ArangoDocument]
gap> InsertIntoDatabase( rec( _key := "3", TP := "x+2*y" ), coll );
[ArangoDocument]
gap> coll.count();
3
gap> UpdateDatabase( "3", rec( TP := "x+y", a := 42, b := " a\nb " ), coll );
[ArangoQueryCursor in [object ArangoDatabase "example"]]
gap> UpdateDatabase( "3", rec( c := rec( d := [ 1, "e" ] ) ), coll );
[ArangoQueryCursor in [object ArangoDatabase "example"]]
gap> coll.ensureIndex(rec( type := "hash", fields := [ "TP" ] ));
[ArangoDocument]
gap> t := rec( query := "FOR e IN test SORT e._key RETURN e", count := true );;
gap> t := db._createStatement( t );
[ArangoStatement in [object ArangoDatabase "example"]]
gap> c := t.execute();
[ArangoQueryCursor in [object ArangoDatabase "example"]]
gap> c.count();
3
gap> a := c.toArray();
[ArangoArray of length 3]
gap> Length( a );
3
gap> Length( List( a ) );
3
gap> a[1].TP;
"x-y"
gap> a[2].TP;
"x*y"
gap> a[3].TP;
"x+y"
gap> a[3].a;
42
gap> a[3].b;
" a\nb "
gap> IsBound( a[3].c );
true
gap> a[3].c;
 rec( d := [ 1, "e" ] )
gap> c := t.execute();
[ArangoQueryCursor in [object ArangoDatabase "example"]]
gap> i := Iterator( c );
<iterator>
gap> d1 := NextIterator( i );
[ArangoDocument]
gap> d1.TP;
"x-y"
gap> d2 := NextIterator( i );
[ArangoDocument]
gap> d2.TP;
"x*y"
gap> d3 := NextIterator( i );
[ArangoDocument]
gap> d3.TP;
"x+y"
gap> d3.a;
42
gap> d3.b;
" a\nb "
gap> IsBound( d3.c );
true
gap> d3.c;
rec( d := [ 1, "e" ] )
gap> r3 := DatabaseDocumentToRecord( d3 );;
gap> IsRecord( r3 );
true
gap> Set( NamesOfComponents( r3 ) );
[ "TP", "_id", "_key", "_rev", "a", "b", "c" ]
gap> [ r3._id, r3._key, r3.TP, r3.a, r3.b, r3.c ];
[ "test/3", "3", "x+y", 42, " a\nb ", rec( d := [ 1, "e" ] ) ]
gap> UpdateDatabase( "1", rec( TP := "x+y" ), coll );
[ArangoQueryCursor in [object ArangoDatabase "example"]]
gap> q := QueryDatabase( rec( TP := "x+y" ), ["_key","TP","a","b","c"], coll );
[ArangoQueryCursor in [object ArangoDatabase "example"]]
gap> a := q.toArray();
[ArangoArray of length 2]
gap> Set( List( a, DatabaseDocumentToRecord ) );
[ rec( TP := "x+y", _key := "1", a := fail, b := fail, c := fail ),
  rec( TP := "x+y", _key := "3", a := 42, b := " a\nb ",
       c := rec( d := [ 1, "e" ] ) ) ]
gap> RemoveFromDatabase( "2", coll );
[ArangoQueryCursor in [object ArangoDatabase "example"]]
gap> coll.count();
2
gap> db._exists( "test/1" );
true
gap> IsRecord( coll.exists( "1" ) );
true
gap> db._exists( "test/2" );
false
gap> coll.exists( "2" );
false
gap> db._exists( "test/3" );
true
gap> db._document( "test/3" );
[ArangoDocument]
gap> coll.document( "3" );
[ArangoDocument]
gap> q := QueryDatabase( rec( TP := "x+y" ), coll );
[ArangoQueryCursor in [object ArangoDatabase "example"]]
gap> q.count();
2
gap> MarkFirstDocument( rec( TP := "x+y" ), rec( TP_lock := "me1" ), coll );
[ArangoDocument]
gap> MarkFirstDocument( rec( TP := "x+y" ), rec( TP_lock := "me2" ), coll );
[ArangoDocument]    
```
