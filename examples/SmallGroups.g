LoadPackage( "ArangoDBInterface" );

db := AttachAnArangoDatabase( );

sg := db.SmallGroups;

if sg = fail then
    sg := db._create( "SmallGroups" );
    Assert( 0, IsDatabaseCollection( sg ) );
    Assert( 0, sg.count() = 0 );
fi;

Assert( 0, sg.count( ) = 6847 );

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

##
ComputeAttributeForSmallGroups := function( attr, collection, arg... )
  local query_rec, attr_lock, lock_rec, d, a_rec, attr_rec;
  
  if not IsString( attr ) then
      Error( "the first argument is not a string\n" );
  elif not IsBoundGlobal( attr ) then
      Error( "ValueGlobal( the first argument ) is not bound\n" );
  elif not IsDatabaseCollectionRep( collection ) then
      Error( "the second argument is not a database collection\n" );
  fi;
  
  query_rec := rec( );
  
  query_rec.(attr) := fail;
  
  attr_lock := Concatenation( attr, "_lock" );
  
  lock_rec := rec( );
  
  lock_rec.(attr_lock) := CallFuncList( FingerprintOfGapProcess, arg );
  
  a_rec := rec( );
  
  a_rec.(attr_lock) := fail;
  
  while true do
      
      d := MarkFirstDocument( query_rec, lock_rec, collection );
      
      if d = false then
          return true;
      elif d = fail then
          Sleep( 1 );
      fi;
      
      attr_rec := ShallowCopy( a_rec );
      
      attr_rec.(attr) := ValueGlobal( attr )( SmallGroup( d.IdGroup ) );
      
      UpdateDatabase( d._key, attr_rec, collection : OPTIONS := rec( keepNull := false ) );
      
  od;
  
end;

ComputeIsAbelian := function( arg... )
    
    return ComputeAttributeForSmallGroups( "IsAbelian", sg, arg );
    
end;

ComputeIsNilpotent := function( arg... )
    
    return ComputeAttributeForSmallGroups( "IsNilpotent", sg, arg );
    
end;

ComputeIsSolvable := function( arg... )
    
    return ComputeAttributeForSmallGroups( "IsSolvable", sg, arg );
    
end;

ComputeIsSupersolvable := function( arg... )
    
    return ComputeAttributeForSmallGroups( "IsSupersolvable", sg, arg );
    
end;

ComputeIsSimple := function( arg... )
    
    return ComputeAttributeForSmallGroups( "IsSimple", sg, arg );
    
end;
