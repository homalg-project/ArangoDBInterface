LoadPackage( "ArangoDBInterface" );

db := AttachAnArangoDatabase( );

sg := db.SmallGroups;

if sg = fail then
    sg := db._create( "SmallGroups" );
    Assert( 0, IsDatabaseCollection( sg ) );
    Assert( 0, sg.count() = 0 );
fi;

KeyIdGroup := function( G )
  local key;
  
  key := IdGroup( G );
  
  return Concatenation( [ String( key[1] ), ":", String( key[2] ) ] );
  
end;

AddSmallGroupsToCollection := function( n )
  local G;
  
  for G in AllSmallGroups( n ) do
      sg.save( rec( _key := KeyIdGroup( G ), IdGroup := IdGroup( G ), Size := Size( G ) ) );
  od;
  
end;

ComputeIsAbelian := function( )
  local query_rec, lock_rec, d, attr_rec;
  
  query_rec := rec( IsAbelian := fail );
  
  lock_rec := rec( IsAbelian_lock := FingerprintOfGapProcess( ) );
  
  while true do
      d := MarkFirstDocument( query_rec, lock_rec, sg );
      
      if d = false then
          return;
      elif d = fail then
          Sleep( 1 );
      fi;
      
      attr_rec := rec( IsAbelian := IsAbelian( SmallGroup( d.IdGroup ) ),
                       IsAbelian_lock := fail );
      
      UpdateDatabase( d._key, attr_rec, sg : OPTIONS := rec( keepNull := false ) );
      
  od;
  
end;
