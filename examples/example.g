#! @System example

LoadPackage( "ArangoDBInterface" );

#! @Example
db := AttachAnArangoDatabase( );
#! [object ArangoDatabase "example"]
db._drop( "examples" );
#! true
coll := db._create( "examples" );
#! [ArangoCollection "examples"]
db.examples;
#! [ArangoCollection "examples"]
coll.count();
#! 0
db.examples.count();
#! 0
InsertIntoDatabase( rec( _key := "1", TP := "x-y" ), coll );;
coll.count();
#! 1
db._truncate( coll );
#! true
coll.count();
#! 0
coll.save( rec( _key := "1", TP := "x-y" ) );;
coll.count();
#! 1
db._truncate( coll );
#! true
coll.count();
#! 0
coll.save( rec( _key := "1", TP := "x-y" ) );;
coll.save( rec( _key := "2", TP := "x*y" ) );;
InsertIntoDatabase( rec( _key := "3", TP := "x+2*y" ), coll );;
coll.count();
#! 3
UpdateDatabase( "3", rec( TP := "x+y" ), coll );
#! [ArangoQueryCursor in [object ArangoDatabase "example"]]
coll.ensureIndex(rec( type := "hash", fields := [ "TP" ] ));;
t := db._createStatement( rec( query := "FOR e IN examples RETURN e", count := true ) );
#! [ArangoStatement in [object ArangoDatabase "example"]]
c := t.execute();
#! [ArangoQueryCursor in [object ArangoDatabase "example"]]
c.count();
#! 3
a := c.toArray();
#! [Array of length 3 in [object ArangoDatabase "example"]]
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
c := t.execute();
#! [ArangoQueryCursor in [object ArangoDatabase "example"]]
i := AsIterator( c );
#! <iterator>
d1 := NextIterator( i );
#! [Document in [object ArangoDatabase "example"]]
d1.TP;
#! "x-y"
d2 := NextIterator( i );
#! [Document in [object ArangoDatabase "example"]]
d2.TP;
#! "x*y"
d3 := NextIterator( i );
#! [Document in [object ArangoDatabase "example"]]
d3.TP;
#! "x+y"
r3 := DatabaseDocumentToRecord( d3 );;
IsRecord( r3 );
#! true
NamesOfComponents( r3 );
#! [ "_key", "TP", "_id", "_rev" ]
[ r3._id, r3._key, r3.TP ];
#! [ "examples/3", "3", "x+y" ]
UpdateDatabase( "1", rec( TP := "x+y" ), coll );
#! [ArangoQueryCursor in [object ArangoDatabase "example"]]
q := QueryDatabase( rec( TP := "x+y" ), [ "_key", "TP" ], coll );
#! [ArangoQueryCursor in [object ArangoDatabase "example"]]
a := q.toArray();
#! [Array of length 2 in [object ArangoDatabase "example"]]
Set( List( a ) );
#! [ rec( TP := "x+y", _key := "1" ), rec( TP := "x+y", _key := "3" ) ]
RemoveFromDatabase( "1", coll );
#! [ArangoQueryCursor in [object ArangoDatabase "example"]]
RemoveFromDatabase( "2", coll );
#! [ArangoQueryCursor in [object ArangoDatabase "example"]]
coll.count();
#! 1
r := rec( collections := rec( write := [ "examples" ] ),
          action := "function () { \
          var db = require(\"@arangodb\").db;\
          for (var i = 4; i < 10; ++i)\
            { db.examples.save({ _key: \"\" + i }); }\
            db.examples.count();\
          }" );;
db._executeTransaction( r );
#! true
coll.count();
#! 7
MarkFirstDocument( rec( TP := fail ), rec( TP_lock := "me1" ), coll );
#! [A document in [object ArangoDatabase "example"]]
MarkFirstDocument( rec( TP := fail ), rec( TP_lock := "me2" ), coll );
#! [A document in [object ArangoDatabase "example"]]
#! @EndExample
