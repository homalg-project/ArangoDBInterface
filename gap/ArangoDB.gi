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

DeclareRepresentation( "IsArangoDatabaseRep",
        IsArangoDatabase,
        [ ] );

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
BindGlobal( "TheFamilyOfArangoDatabases",
        NewFamily( "TheFamilyOfArangoDatabases" ) );

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
BindGlobal( "TheTypeArangoDatabase",
        NewType( TheFamilyOfArangoDatabases,
                IsArangoDatabaseRep ) );

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
InstallGlobalFunction( AttachAnArangoDatabase,
  function( arg )
    local nargs, save, options, stream, name, db;
    
    nargs := Length( arg );
    
    if nargs = 1 and IsList( arg[1] ) then
        save := HOMALG_IO_ArangoShell.options;
        HOMALG_IO_ArangoShell.options := arg[1];
    fi;
    
    options := HOMALG_IO_ArangoShell.options;
    
    stream := LaunchCAS( "HOMALG_IO_ArangoShell" );
    
    if IsBound( save ) then
        HOMALG_IO_ArangoShell.options := save;
    fi;
    
    name := homalgSendBlocking( [ "db" ], "need_output", stream );
    name := SplitString( name, "\"" )[2];
    
    db := rec( stream := stream,
               options := options,
               pointer := "db",
               name := name );
    
    ObjectifyWithAttributes( db, TheTypeArangoDatabase,
            Name, Concatenation( "<Arango database \"", name, "\">" )
            );
    
    return db;
    
end );

##
InstallMethod( DatabaseCollection,
        "for a homalg external object and an Arango database",
        [ IshomalgExternalObjectRep, IsArangoDatabaseRep ],

  function( pointer, db )
    local collection;
    
    if not IsBound( pointer!.name ) then
        Error( "the pointer has no component called `name'\n" );
    fi;
    
    collection := rec( pointer := pointer, name := pointer!.name, database := db );
    
    ObjectifyWithAttributes( collection, TheTypeDatabaseCollection,
            Name, Concatenation( "<Database collection \"", pointer!.name, "\">" )
            );
    
    return collection;
    
end );

##
InstallMethod( CreateDatabaseCollection,
        "for a string and an Arango database",
        [ IsString, IsArangoDatabaseRep ],

  function( collection_name, db )
    
    return db._create( collection_name );
    
end );

##
InstallMethod( TruncateDatabaseCollection,
        "for a database collection",
        [ IsDatabaseCollectionRep ],
        
  function( collection )
    local db;
    
    db := collection!.database;
    
    return db._truncate( collection );
    
end );

##
InstallMethod( DatabaseStatement,
        "for a string and a database collection",
        [ IsString, IsDatabaseCollectionRep ],

  function( statement_string, collection )
    local ext_obj, statement;
    
    ext_obj := homalgSendBlocking( [ "db._createStatement({ \"query\": \"", statement_string, "\" })" ], collection!.pointer );
    
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
        "for an Arango database and a positive integer",
        [ IsArangoDatabaseRep, IsPosInt ],
        
  function( db, string_as_int )
    local name, pointer;
    
    name := NameRNam( string_as_int );
    
    if name = "_create" then
        
        return
          function( collection_name )
            local extobj;
            
            extobj := homalgSendBlocking( [ db!.pointer, ".", name, "(\"", collection_name, "\")" ], db!.stream );
            
            extobj!.name := collection_name;
            
            return DatabaseCollection( extobj, db );
            
        end;
        
    elif name in [ "_truncate", "_drop" ] then
        
        return
          function( collection )
            local collection_name, output;
            
            if IsDatabaseCollectionRep( collection ) then
                collection_name := collection!.name;
            elif IsString( collection ) then
                collection_name := collection;
            else
                Error( "the input should either be a collection or its name as a string\n" );
            fi;
            
            output := homalgSendBlocking( [ db!.pointer, ".", name, "(\"", collection_name, "\")" ], db!.stream, "need_output" );
            
            if not output = "" then
                Error( output, "\n" );
            fi;
            
            return true;
            
        end;
        
    elif name in [ "_executeTransaction" ] then
        
        return
          function( keys_values_rec )
            local string, output;
            
            string := GapToJsonString( keys_values_rec );
            
            output := homalgSendBlocking( [ db!.pointer, ".", name, "(", string, ")" ], db!.stream, "need_output" );
            
            if not output = "null" then
                Error( output, "\n" );
            fi;
            
            return true;
            
        end;
        
    elif name[1] = '_' then
        
        return
          function( keys_values_rec )
            local string;
            
            string := GapToJsonString( keys_values_rec );
            
            return homalgSendBlocking( [ db!.pointer, ".", name, "(", string, ")" ], db!.stream );
            
        end;
        
    fi;
    
    if homalgSendBlocking( [ db!.pointer, ".", name ], "need_output", db!.stream ) = "" then
        Error( "no collection named \"", name, "\" is loadable in the database \"", db!.name, "\"" );
    fi;
    
    pointer := homalgSendBlocking( [ db!.pointer, ".", name ], db!.stream );
    
    pointer!.name := name;
    
    return DatabaseCollection( pointer, db );
    
end );

##
InstallMethod( \.,
        "for a database collections and a positive integer",
        [ IsDatabaseCollectionRep, IsPosInt ],
        
  function( collection, string_as_int )
    local command;
    
    command := NameRNam( string_as_int );
    
    return
      function( arg )
        local nargs, string, keys_values_rec, output;
        
        nargs := Length( arg );
        
        if nargs = 0 then
            string := "";
        else
            keys_values_rec := arg[1];
            string := GapToJsonString( keys_values_rec );
        fi;
        
        output := homalgSendBlocking( [ collection!.pointer, ".", command, "(", string, ")" ], "need_output" );
        
        if nargs = 0 then
            if command in [ "count" ] then
                return Int( output );
            fi;
            return output;
        fi;
        
        if not output[1] = '{' then
            Error( output );
        fi;
        
        return JsonStringToGap( output );
        
    end;
    
end );

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
            local pointer, str, ext_obj, array;
            
            pointer := cursor!.pointer;
            
            str := homalgSendBlocking( [ pointer ], "need_output" );
            
            str := SplitString( str, "," )[2];
            str := SplitString( str, ":" )[2];
            
            ext_obj := homalgSendBlocking( [ pointer, ".toArray()" ] );
            ext_obj!.collection := pointer!.collection;
            
            array := CreateDatabaseArray( ext_obj );
            
            SetLength( array, EvalString( str ) );
            
            array!.Name := Concatenation( "<An array of length ", str, " in ", Name( ext_obj!.collection ), ">" );
            
            return array;
            
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
InstallMethod( InsertIntoDatabase,
        "for a record and a database collection",
        [ IsRecord, IsDatabaseCollectionRep ],

  function( keys_values_rec, collection )
    
    return collection.save( keys_values_rec );
    
end );

##
InstallMethod( UpdateDatabase,
        "for a string, a record, and a database collection",
        [ IsString, IsRecord, IsDatabaseCollectionRep ],

  function( id, keys_values_rec, collection )
    local string;
    
    string := GapToJsonString( keys_values_rec );
    
    homalgSendBlocking( [ "db._query('UPDATE \"", id, "\" WITH ", string, " IN ", collection!.name, "')" ], "need_command", collection!.pointer );
    
end );

##
InstallMethod( RemoveFromDatabase,
        "for a string and a database collection",
        [ IsString, IsDatabaseCollectionRep ],

  function( id, collection )
    
    homalgSendBlocking( [ "db._query('REMOVE \"", id, "\" IN ", collection!.name, "')" ], "need_command", collection!.pointer );
    
end );

##
InstallMethod( QueryDatabase,
        "for a string and a database collection",
        [ IsString, IsDatabaseCollectionRep ],

  function( query, collection )
    local ext_obj;
    
    ext_obj := homalgSendBlocking( [ "db._query('", query, "')" ], collection!.pointer );
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

##
InstallMethod( ListOp,
        "for a database array",
        [ IsDatabaseArrayRep ],

  function( array )
    local str;
    
    str := homalgSendBlocking( [ array!.pointer ], "need_output" );
    
    return JsonStringToGap( str );
    
end );

##
InstallMethod( DatabaseDocumentToRecord,
        "for a database document",
        [ IsDatabaseDocumentRep ],

  function( document )
    local str, doc, i;
    
    str := homalgSendBlocking( [ document!.pointer ], "need_output" );
    
    doc := JsonStringToGap( str );
    
    ## long values of keys will probably be corrupt
    ## so get everything again after knowing all keys
    for i in NamesOfComponents( doc ) do
        doc.(i) := document.(i);
    od;
    
    return doc;
    
end );

##
InstallMethod( DisplayInArangoSh,
        "for a database document",
        [ IsObject ],
        
  function( obj )
    
    if IsBound( obj!.pointer ) then
        homalgDisplay( obj!.pointer );
    fi;
    
end );
