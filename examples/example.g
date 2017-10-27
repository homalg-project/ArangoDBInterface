#! @System example

LoadPackage( "ArangoDB" );

#! @Example
stream := LaunchCAS( "HOMALG_IO_ArangoShell" );;
l := DatabaseCollection( "examples", stream );
#! <Database collection "examples">
TruncateDatabaseCollection( l );
InsertIntoDatabase( rec( _key := 1, TP := "x-y" ), l );
InsertIntoDatabase( rec( _key := 2, TP := "x*y" ), l );
InsertIntoDatabase( rec( _key := 3, TP := "x+2*y" ), l );
UpdateDatabase( "3", rec( TP := "x+y" ), l );
t := DatabaseStatement( "FOR e IN examples RETURN e", l );
#! <A statement in <Database collection "examples">>
c := t.execute();
#! <A cursor in <Database collection "examples">>
a := c.toArray();
#! <An array in <Database collection "examples">>
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
