#! @System example

LoadPackage( "ArangoDB" );

#! @Example
db := AttachAnArangoDatabase( );
#! <Arango database "example">
l := DatabaseCollection( "examples", db );
#! <Database collection "examples">
TruncateDatabaseCollection( l );
InsertIntoDatabase( rec( _key := "1", TP := "x-y" ), l );;
l.save( rec( _key := "2", TP := "x*y" ) );;
InsertIntoDatabase( rec( _key := "3", TP := "x+2*y" ), l );;
UpdateDatabase( "3", rec( TP := "x+y" ), l );
l.ensureIndex(rec( type := "hash", fields := [ "TP" ] ));;
t := DatabaseStatement( "FOR e IN examples RETURN e", l );
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
RemoveFromDatabase( "1", l );
RemoveFromDatabase( "2", l );
#! @EndExample
