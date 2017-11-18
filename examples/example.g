#! @System example

LoadPackage( "ArangoDB" );

#! @Example
db := AttachAnArangoDatabase( );
#! <Arango database "example">
db._drop( "examples" );
#! true
coll := db._create( "examples" );
#! <Database collection "examples">
db.examples;
#! <Database collection "examples">
coll.count();
#! 0
db.examples.count();
#! 0
InsertIntoDatabase( rec( _key := "1", TP := "x-y" ), coll );;
coll.count();
#! 1
TruncateDatabaseCollection( coll );
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
coll.ensureIndex(rec( type := "hash", fields := [ "TP" ] ));;
t := DatabaseStatement( "FOR e IN examples RETURN e", coll );
#! <A statement in <Database collection "examples">>
c := t.execute();
#! <A cursor in <Database collection "examples">>
a := c.toArray();
#! <An array of length 3 in <Database collection "examples">>
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
#! <A cursor in <Database collection "examples">>
i := AsIterator( c );
#! <iterator>
d1 := NextIterator( i );
#! <A document in <Database collection "examples">>
d1.TP;
#! "x-y"
d2 := NextIterator( i );
#! <A document in <Database collection "examples">>
d2.TP;
#! "x*y"
d3 := NextIterator( i );
#! <A document in <Database collection "examples">>
d3.TP;
#! "x+y"
r3 := DatabaseDocumentToRecord( d3 );;
IsRecord( r3 );
#! true
NamesOfComponents( r3 );
#! [ "_key", "TP", "_id", "_rev" ]
[ r3._id, r3._key, r3.TP ];
#! [ "examples/3", "3", "x+y" ]
RemoveFromDatabase( "1", coll );
RemoveFromDatabase( "2", coll );
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
#! @EndExample
