#! @System example

LoadPackage( "ArangoDBInterface" );

#! @Example
db := AttachAnArangoDatabase( );
#! [object ArangoDatabase "example"]
db._isSystem();
#! false
db._name();
#! "example"
db._drop( "test" );
#! true
coll := db._create( "test" );
#! [ArangoCollection "test"]
db.test;
#! [ArangoCollection "test"]
coll.count();
#! 0
db.test.count();
#! 0
InsertIntoDatabase( rec( _key := "1", TP := "x-y" ), coll );
#! [ArangoDocument]
coll.count();
#! 1
db._truncate( coll );
#! true
coll.count();
#! 0
coll.save( rec( _key := "1", TP := "x-y" ) );
#! [ArangoDocument]
coll.count();
#! 1
db._truncate( coll );
#! true
coll.count();
#! 0
coll.save( rec( _key := "1", TP := "x-y" ) );
#! [ArangoDocument]
coll.save( rec( _key := "2", TP := "x*y" ) );
#! [ArangoDocument]
InsertIntoDatabase( rec( _key := "3", TP := "x+2*y" ), coll );
#! [ArangoDocument]
coll.count();
#! 3
UpdateDatabase( "3", rec( TP := "x+y", a := 42, b := " a\nb " ), coll );
#! [ArangoQueryCursor in [object ArangoDatabase "example"]]
UpdateDatabase( "3", rec( c := rec( d := [ 1, "e" ] ) ), coll );
#! [ArangoQueryCursor in [object ArangoDatabase "example"]]
coll.ensureIndex(rec( type := "hash", fields := [ "TP" ] ));
#! [ArangoDocument]
t := rec( query := "FOR e IN test SORT e._key RETURN e", count := true );;
t := db._createStatement( t );
#! [ArangoStatement in [object ArangoDatabase "example"]]
c := t.execute();
#! [ArangoQueryCursor in [object ArangoDatabase "example"]]
c.count();
#! 3
a := c.toArray();
#! [ArangoArray of length 3]
Length( a );
#! 3
Length( List( a ) );
#! 3
a[1].TP;
#! "x-y"
a[2].TP;
#! "x*y"
a[3].TP;
#! "x+y"
a[3].a;
#! 42
a[3].b;
#! " a\nb "
IsBound( a[3].c );
#! true
a[3].c;
#!  rec( d := [ 1, "e" ] )
c := t.execute();
#! [ArangoQueryCursor in [object ArangoDatabase "example"]]
i := Iterator( c );
#! <iterator>
d1 := NextIterator( i );
#! [ArangoDocument]
d1.TP;
#! "x-y"
d2 := NextIterator( i );
#! [ArangoDocument]
d2.TP;
#! "x*y"
d3 := NextIterator( i );
#! [ArangoDocument]
d3.TP;
#! "x+y"
d3.a;
#! 42
d3.b;
#! " a\nb "
IsBound( d3.c );
#! true
d3.c;
#! rec( d := [ 1, "e" ] )
r3 := DatabaseDocumentToRecord( d3 );;
IsRecord( r3 );
#! true
Set( NamesOfComponents( r3 ) );
#! [ "TP", "_id", "_key", "_rev", "a", "b", "c" ]
[ r3._id, r3._key, r3.TP, r3.a, r3.b, r3.c ];
#! [ "test/3", "3", "x+y", 42, " a\nb ", rec( d := [ 1, "e" ] ) ]
UpdateDatabase( "1", rec( TP := "x+y" ), coll );
#! [ArangoQueryCursor in [object ArangoDatabase "example"]]
q := QueryDatabase( rec( TP := "x+y" ), ["_key","TP","a","b","c"], coll );
#! [ArangoQueryCursor in [object ArangoDatabase "example"]]
a := q.toArray();
#! [ArangoArray of length 2]
Set( List( a, DatabaseDocumentToRecord ) );
#! [ rec( TP := "x+y", _key := "1", a := fail, b := fail, c := fail ),
#!   rec( TP := "x+y", _key := "3", a := 42, b := " a\nb ",
#!        c := rec( d := [ 1, "e" ] ) ) ]
RemoveFromDatabase( "1", coll );
#! [ArangoQueryCursor in [object ArangoDatabase "example"]]
RemoveFromDatabase( "2", coll );
#! [ArangoQueryCursor in [object ArangoDatabase "example"]]
coll.count();
#! 1
db._exists( "test/1" );
#! false
db._exists( "test/3" );
#! true
db._document( "test/3" );
#! [ArangoDocument]
coll.document( "3" );
#! [ArangoDocument]
r := rec( collections := rec( write := [ "test" ] ),
          action := "function () { \
          var db = require(\"@arangodb\").db;\
          for (var i = 4; i < 10; ++i)\
            { db.test.save({ _key: \"\" + i }); }\
            db.test.count();\
          }" );;
db._executeTransaction( r );
#! true
coll.count();
#! 7
MarkFirstDocument( rec( TP := fail ), rec( TP_lock := "me1" ), coll );
#! [ArangoDocument]
MarkFirstDocument( rec( TP := fail ), rec( TP_lock := "me2" ), coll );
#! [ArangoDocument]
#! @EndExample

Assert( coll.count(), 7 );
