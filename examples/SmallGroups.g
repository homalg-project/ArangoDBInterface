LoadPackage( "ArangoDBInterface" );

db := AttachAnArangoDatabase( );

sg := db.SmallGroups;

if sg = fail then
    sg := db._create( "SmallGroups" );
else
    Assert( 0, sg.count( ) = 6847 );
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

##
ComputeAttributeForSmallGroups := function( attr, collection, arg... )
  local query_rec, attr_lock, lock_rec, count, d, a_rec, attr_rec;
  
  if not IsString( attr ) then
      Error( "the first argument is not a string\n" );
  elif not IsBoundGlobal( attr ) then
      Error( "ValueGlobal( the first argument ) is not bound\n" );
  elif not IsDatabaseCollectionRep( collection ) then
      Error( "the second argument is not a database collection\n" );
  fi;
  
  query_rec := ValueOption( "query_rec" );
      
  if query_rec = fail then
      query_rec := rec( );
  fi;
  
  query_rec.(attr) := fail;
  
  attr_lock := Concatenation( attr, "_lock" );
  
  lock_rec := rec( );
  
  lock_rec.(attr_lock) := CallFuncList( FingerprintOfGapProcess, arg );
  
  a_rec := rec( );
  
  a_rec.(attr_lock) := fail;
  
  count := 0;
  
  while true do
      
      d := MarkFirstDocument( query_rec, lock_rec, collection );
      
      if d = false then
          return count;
      elif d = fail then
          Print( "all documents with unknown attribute `", attr, "' are currently locked, sleeping for 1 second\n" );
          Sleep( 1 );
      else
          attr_rec := ShallowCopy( a_rec );
          
          attr_rec.(attr) := ValueGlobal( attr )( SmallGroup( d.IdGroup ) );
          
          UpdateDatabase( d._key, attr_rec, collection : OPTIONS := rec( keepNull := false ) );
          
          count := count + 1;
      fi;
      
  od;
  
end;

ComputeIsCyclic := function( arg... )
    
    return ComputeAttributeForSmallGroups( "IsCyclic", sg, arg );
    
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

ComputeIsMonomial := function( arg... )
    
    return ComputeAttributeForSmallGroups( "IsMonomial", sg, arg );
    
end;
