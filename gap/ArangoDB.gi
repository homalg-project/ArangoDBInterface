#
# ArangoDBInterface: An interface to ArangoDB
#
# Implementations
#

####################################
#
# representations:
#
####################################

DeclareRepresentation( "IsDatabaseCollectionRep",
        IsDatabaseCollection,
        [ ] );

DeclareRepresentation( "IsDatabaseStatementRep",
        IsDatabaseStatement,
        [ ] );

DeclareRepresentation( "IsDatabaseCursorRep",
        IsDatabaseCursor,
        [ ] );

DeclareRepresentation( "IsDatabaseArrayRep",
        IsDatabaseArray,
        [ ] );

DeclareRepresentation( "IsDatabaseDocumentRep",
        IsDatabaseDocument,
        [ ] );

####################################
#
# families and types:
#
####################################

# new families:
BindGlobal( "TheFamilyOfDatabaseCollections",
        NewFamily( "TheFamilyOfDatabaseCollections" ) );

BindGlobal( "TheFamilyOfDatabaseStatements",
        NewFamily( "TheFamilyOfDatabaseStatements" ) );

BindGlobal( "TheFamilyOfDatabaseCursors",
        NewFamily( "TheFamilyOfDatabaseCursors" ) );

BindGlobal( "TheFamilyOfDatabaseArrays",
        NewFamily( "TheFamilyOfDatabaseArrays" ) );

BindGlobal( "TheFamilyOfDatabaseDocuments",
        NewFamily( "TheFamilyOfDatabaseDocuments" ) );

# new types:
BindGlobal( "TheTypeDatabaseCollection",
        NewType( TheFamilyOfDatabaseCollections,
                IsDatabaseCollectionRep ) );

BindGlobal( "TheTypeDatabaseStatement",
        NewType( TheFamilyOfDatabaseStatements,
                IsDatabaseStatementRep ) );

BindGlobal( "TheTypeDatabaseCursor",
        NewType( TheFamilyOfDatabaseCursors,
                IsDatabaseCursorRep ) );

BindGlobal( "TheTypeDatabaseArray",
        NewType( TheFamilyOfDatabaseArrays,
                IsDatabaseArrayRep ) );

BindGlobal( "TheTypeDatabaseDocument",
        NewType( TheFamilyOfDatabaseDocuments,
                IsDatabaseDocumentRep ) );

####################################
#
# global variables:
#
####################################

InstallValue( HOMALG_IO_ArangoShell,
        rec(
            cas := "arangosh",			## normalized name on which the user should have no control
            name := "arangosh",
            executable := [ "arangosh" ],	## this list is processed from left to right
            options := [ "--server.username", "root@example", "--server.database", "example", "--server.password", "password" ],
            BUFSIZE := 1024,
            READY := "!$%&/(",
            CUT_POS_BEGIN := 1,			## these are the most
            CUT_POS_END := 2,			## delicate values!
            eoc_verbose := "",
            eoc_quiet := "",
            remove_enter := true,			## an arangosh specific
            error_stdout := "JavaScript exception",	## an arangosh specific
            define := "=",
            prompt := "\033[01marangosh>\033[0m ",
            output_prompt := "\033[1;30;43m<arangosh\033[0m ",
            display_color := "\033[0;30;47m",
#            init_string := "",
#            InitializeCASMacros := InitializeArangoDBMacros,
#            time := function( stream, t ) return Int( homalgSendBlocking( [ "" ], "need_output", stream, HOMALG_IO.Pictograms.time ) ) - t; end,
#            memory_usage := function( stream, o ) return Int( homalgSendBlocking( [ "" ], "need_output", stream, HOMALG_IO.Pictograms.memory ) ); end,
           )
);

HOMALG_IO_ArangoShell.READY_LENGTH := Length( HOMALG_IO_ArangoShell.READY );

####################################
#
# methods for constructors:
#
####################################

##
InstallMethod( DatabaseCollection,
        "for a string and a record",
        [ IsString, IsRecord ],

  function( collection_name, stream )
    local collection;
    
    collection := rec( stream := stream, name := collection_name );
    
    ObjectifyWithAttributes( collection, TheTypeDatabaseCollection,
            Name, Concatenation( "<Database collection \"", collection_name, "\">" )
            );
    
    return collection;
    
end );

##
InstallMethod( DatabaseStatement,
        "for a string and a database collection",
        [ IsString, IsDatabaseCollectionRep ],

  function( statement_string, collection )
    local ext_obj, statement;
    
    ext_obj := homalgSendBlocking( [ "db._createStatement({ \"query\": \"", statement_string, "\" })" ], collection!.stream );
    
    ext_obj!.collection := collection;
    
    statement := rec( pointer := ext_obj, string := statement_string );
    
    ObjectifyWithAttributes( statement, TheTypeDatabaseStatement,
            Name, Concatenation( "<A statement in ", Name( collection ), ">" )
            );
    
    return statement;
    
end );

##
InstallMethod( CreateDatabaseCursor,
        "for a homalg external object",
        [ IshomalgExternalObjectRep ],

  function( ext_obj )
    local cursor;
    
    cursor := rec( pointer := ext_obj );
    
    ObjectifyWithAttributes( cursor, TheTypeDatabaseCursor,
            Name, Concatenation( "<A cursor in ", Name( ext_obj!.collection ), ">" )
            );
    
    return cursor;
    
end );

##
InstallMethod( CreateDatabaseArray,
        "for a homalg external object",
        [ IshomalgExternalObjectRep ],

  function( ext_obj )
    local array;
    
    array := rec( pointer := ext_obj );
    
    ObjectifyWithAttributes( array, TheTypeDatabaseArray,
            Name, Concatenation( "<An array in ", Name( ext_obj!.collection ), ">" )
            );
    
    return array;
    
end );

##
InstallMethod( CreateDatabaseDocument,
        "for a homalg external object",
        [ IshomalgExternalObjectRep ],

  function( ext_obj )
    local document;
    
    document := rec( pointer := ext_obj );
    
    ObjectifyWithAttributes( document, TheTypeDatabaseDocument,
            Name, Concatenation( "<A document in ", Name( ext_obj!.collection ), ">" )
            );
    
    return document;
    
end );

####################################
#
# methods for operations:
#
####################################

##
InstallMethod( \.,
        "for a database statement and a positive integer",
        [ IsDatabaseStatementRep, IsPosInt ],
        
  function( statement, string_as_int )
    local name;
    
    name := NameRNam( string_as_int );
    
    if name = "execute" then
        
        return function( )
            local pointer, ext_obj;
            
            pointer := statement!.pointer;
            
            ext_obj := homalgSendBlocking( [ pointer, ".execute()" ] );
            ext_obj!.collection := pointer!.collection;
            
            return CreateDatabaseCursor( ext_obj );
            
        end;
        
    fi;
    
    Error( name, " is an unknown or yet unsupported method for database collections\n" );
    
end );

##
InstallMethod( \.,
        "for a database cursor and a positive integer",
        [ IsDatabaseCursorRep, IsPosInt ],
        
  function( cursor, string_as_int )
    local name;
    
    name := NameRNam( string_as_int );
    
    if name = "toArray" then
        
        return function( )
            local pointer, ext_obj;
            
            pointer := cursor!.pointer;
            
            ext_obj := homalgSendBlocking( [ cursor!.pointer, ".toArray()" ] );
            ext_obj!.collection := pointer!.collection;
            
            return CreateDatabaseArray( ext_obj );
            
        end;
        
    elif name = "hasNext" then
        
        return function( )
            local pointer, ext_obj;
            
            pointer := cursor!.pointer;
            
            return EvalString( homalgSendBlocking( [ cursor!.pointer, ".hasNext()" ], "need_output" ) );
            
        end;
        
    elif name = "next" then
        
        return function( )
            local pointer, ext_obj;
            
            pointer := cursor!.pointer;
            
            ext_obj := homalgSendBlocking( [ cursor!.pointer, ".next()" ] );
            ext_obj!.collection := pointer!.collection;
            
            return CreateDatabaseDocument( ext_obj );
            
        end;
        
    fi;
    
    Error( name, " is an unknown or yet unsupported method for database cursors\n" );
    
end );

##
InstallOtherMethod( \[\],
        "for a database array and a positive integer",
        [ IsDatabaseArrayRep, IsPosInt ],
        
  function( array, n )
    local pointer, ext_obj;
    
    pointer := array!.pointer;
    
    ext_obj := homalgSendBlocking( [ array!.pointer, "[", String( n - 1 ), "]" ] );
    ext_obj!.collection := pointer!.collection;
    
    return CreateDatabaseDocument( ext_obj );
    
end );

##
InstallMethod( \.,
        "for a database document and a positive integer",
        [ IsDatabaseDocumentRep, IsPosInt ],
        
  function( cursor, string_as_int )
    local name, pointer, ext_obj;
    
    name := NameRNam( string_as_int );
    
    pointer := cursor!.pointer;
    
    return homalgSendBlocking( [ cursor!.pointer, ".", name ], "need_output" );
    
end );

##
InstallGlobalFunction( _ArangoDB_create_keys_values_string,
  function( keys_values_rec )
    local key, SEP, string;
    
    string := [ ];
    
    SEP := "";
    
    for key in NamesOfComponents( keys_values_rec ) do
        Append( string, [ SEP, key, " : ",  "\"", String( keys_values_rec.(key) ), "\"" ] );
        SEP := ", ";
    od;
    
    return Concatenation( string );
    
end );

##
InstallMethod( InsertIntoDatabase,
        "for a record and a database collection",
        [ IsRecord, IsDatabaseCollectionRep ],

  function( keys_values_rec, collection )
    local string;
    
    string := _ArangoDB_create_keys_values_string( keys_values_rec );
    
    homalgSendBlocking( [ "db.", collection!.name, ".save({", string, "})" ], "need_command", collection!.stream );
    
end );

##
InstallMethod( UpdateDatabase,
        "for a string, a record, and a database collection",
        [ IsString, IsRecord, IsDatabaseCollectionRep ],

  function( id, keys_values_rec, collection )
    local string;
    
    string := _ArangoDB_create_keys_values_string( keys_values_rec );
    
    homalgSendBlocking( [ "db._query('UPDATE \"", id, "\" WITH {", string, "} IN ", collection, "')" ], "need_command", collection!.stream );
    
end );

##
InstallMethod( RemoveFromDatabase,
        "for a string and a database collection",
        [ IsString, IsDatabaseCollectionRep ],

  function( id, collection )
    
    homalgSendBlocking( [ "db._query('REMOVE \"", id, "\" IN ", collection, "')" ], "need_command", collection!.stream );
    
end );

##
InstallMethod( QueryDatabase,
        "for a string and a database collection",
        [ IsString, IsDatabaseCollectionRep ],

  function( query, collection )
    local ext_obj;
    
    ext_obj := homalgSendBlocking( [ "db._query('", query, "')" ], collection!.stream );
    ext_obj!.collection := collection;
    
    return CreateDatabaseCursor( ext_obj );
    
end );

##
InstallGlobalFunction( _ArangoDB_create_filter_return_string,
  function( query_rec, result_rec, collection )
    local string, keys, AND, SEP, func, i, key, value;
    
    string := [ "FOR d IN ", collection ];
    
    keys := NamesOfComponents( query_rec );
    
    if not keys = [ ] then
        Add( string, " FILTER " );
    fi;
    
    AND := "";
    
    for i in [ 1 .. Length( keys ) ] do
        key := keys[i];
        value := query_rec.(key);
        if not IsString( value ) and IsList( value ) and Length( value ) = 2 then
            Append( string, [ AND, "d.", key, value[1], "\"", String( value[2] ), "\"" ] );
        elif IsString( value ) or not IsList( value ) then
            Append( string, [ AND, "d.", key, "==", "\"", String( value ), "\"" ] );
        else
            Error( "wrong syntax of query value: ", value, "\n" );
        fi;
        AND := " && ";
    od;
    
    Add( string, " RETURN " );
    
    if result_rec = "" then
        Add( string, " d" );
        return Concatenation( string );
    else
        Add( string, "{ " );
    fi;
    
    keys := NamesOfComponents( result_rec );
    
    SEP := "";
    
    func := [ ];
    
    for key in keys do
        value := result_rec.(key);
        if not IsString( value ) and IsList( value ) and Length( value ) = 2 then
            Append( string, [ SEP, key, " : d.", value[1] ] );
            Add( func, value[2] );
        elif IsString( value ) or not IsList( value ) then
            Append( string, [ SEP, key, " : d.", value ] );
            Add( func, IdFunc );
        else
            Error( "wrong syntax of result key: ", value, "\n" );
        fi;
        SEP := ", ";
    od;
    
    Add( string, " }" );
    
    return [ Concatenation( string ), func ];
    
end );

##
InstallMethod( QueryDatabase,
        "for a record and a database collection",
        [ IsRecord, IsDatabaseCollectionRep ],

  function( query_rec, collection )
    local string;
    
    string := _ArangoDB_create_filter_return_string( query_rec, "", collection!.name );
    
    return QueryDatabase( string, collection );
    
end );

##
InstallMethod( QueryDatabase,
        "for a database collection",
        [ IsDatabaseCollectionRep ],

  function( collection )
    
    return QueryDatabase( rec( ), collection );
    
end );

##
InstallMethod( QueryDatabase,
        "for two records and a database collection",
        [ IsRecord, IsRecord, IsDatabaseCollectionRep ],

  function( query_rec, result_rec, collection )
    local string, func;
    
    string := _ArangoDB_create_filter_return_string( query_rec, result_rec, collection!.name );
    
    func := string[2];
    string := string[1];
    
    return QueryDatabase( string, collection );
    
end );

##
InstallMethod( AsIterator,
        "for a database cursor",
        [ IsDatabaseCursorRep ],
        
  function( cursor )
    local iter;
    
    iter := rec(
                NextIterator := iter -> cursor.next(),
                IsDoneIterator := iter -> not cursor.hasNext(),
                ShallowCopy := IdFunc
                );
    
    return IteratorByFunctions( iter );
    
end );
