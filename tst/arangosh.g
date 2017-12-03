LoadPackage( "ArangoDBInterface" );
db := AttachAnArangoDatabase( );
db._drop( "ArangoDBInterface_tst_collection" );
coll := db._create( "ArangoDBInterface_tst_collection" );
string := ListWithIdenticalEntries( 400, 'a' );
str := ListWithIdenticalEntries( 10, '\n' );
r := rec( _key := "new", empty := "", string := string, number := 42, list := [ 1, 2, [ 3 ] ], record := rec( a := 1, 2 := rec( 3 := [ 1, str ] ) ) );
for i in [ 1 .. 1000 ] do
  coll.save( r );
  q := QueryDatabase( rec( _key := "new" ), [ "_key", "empty", "string", "number", "list", "record" ], coll );
  a := q.toArray();
  d := a[1];
  s := DatabaseDocumentToRecord( d );
  Assert( 0, r = s );
  RemoveFromDatabase( "new", coll );
od;
