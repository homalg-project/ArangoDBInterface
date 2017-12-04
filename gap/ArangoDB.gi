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
            credentials := [ "--server.username", "root@example", "--server.database", "example", "--server.password", "password" ],
            options := Concatenation( [ "--console.auto-complete", "false", "--console.colors", "false" ], ~.credentials ),
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
# rewrite a Json method
#
####################################

InstallMethod(_GapToJsonStreamInternal, [IsOutputStream, IsBool],
function(o, b)
  if b = true then
      PrintTo(o, "true");
  elif b = false then
      PrintTo(o, "false");
  elif b = fail then
      PrintTo(o, "null");
  else
      Error("Invalid Boolean");
  fi;
end );

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
            Name, Concatenation( "[object ArangoDatabase \"", name, "\"]" )
            );
    
    return db;
    
end );

##
InstallMethod( _ExtractDatabase,
        "for a homalg external object",
        [ IshomalgExternalObjectRep ],

  function( ext_obj )
    local database;
    
    if not IsBound( ext_obj!.database ) then
        Error( "the external object has no component called `database'\n" );
    fi;
    
    database := ext_obj!.database;
    
    if not IsArangoDatabaseRep( database ) then
        Error( "the component ext_obj!.database is not an IsArangoDatabaseRep\n" );
    fi;
    
    return database;
    
end );

##
InstallMethod( CreateDatabaseCollection,
        "for a homalg external object",
        [ IshomalgExternalObjectRep ],

  function( ext_obj )
    local database, name, collection;
    
    if not IsBound( ext_obj!.name ) then
        Error( "the external object has no component called `name'\n" );
    fi;
    
    name := ext_obj!.name;
    
    database := _ExtractDatabase( ext_obj );
    
    collection := rec( pointer := ext_obj, name := name, database := database );
    
    ObjectifyWithAttributes( collection, TheTypeDatabaseCollection,
            Name, Concatenation( "[ArangoCollection \"", name, "\"]" )
            );
    
    return collection;
    
end );

##
InstallMethod( CreateDatabaseStatement,
        "for a homalg external object",
        [ IshomalgExternalObjectRep ],

  function( ext_obj )
    local database, statement;
    
    if not IsBound( ext_obj!.statement ) then
        Error( "the external object has no component called `statement_string'\n" );
    fi;
    
    database := _ExtractDatabase( ext_obj );
    
    statement := rec( pointer := ext_obj, statement := ext_obj!.statement, database := database );
    
    ObjectifyWithAttributes( statement, TheTypeDatabaseStatement,
            Name, Concatenation( "[ArangoStatement in ", Name( database ), "]" )
            );
    
    return statement;
    
end );

##
InstallMethod( CreateDatabaseCursor,
        "for a homalg external object",
        [ IshomalgExternalObjectRep ],

  function( ext_obj )
    local database, cursor;
    
    database := _ExtractDatabase( ext_obj );
    
    cursor := rec( pointer := ext_obj, database := database );
    
    ObjectifyWithAttributes( cursor, TheTypeDatabaseCursor,
            Name, Concatenation( "[ArangoQueryCursor in ", Name( database ), "]" )
            );
    
    return cursor;
    
end );

##
InstallMethod( CreateDatabaseArray,
        "for a homalg external object",
        [ IshomalgExternalObjectRep ],

  function( ext_obj )
    local database, array;
    
    database := _ExtractDatabase( ext_obj );
    
    array := rec( pointer := ext_obj, database := database );
    
    ObjectifyWithAttributes( array, TheTypeDatabaseArray,
            Name, "[ArangoArray]"
            );
    
    return array;
    
end );

##
InstallMethod( CreateDatabaseDocument,
        "for a homalg external object",
        [ IshomalgExternalObjectRep ],

  function( ext_obj )
    local database, document;
    
    database := _ExtractDatabase( ext_obj );
    
    document := rec( pointer := ext_obj, database := database );
    
    ObjectifyWithAttributes( document, TheTypeDatabaseDocument,
            Name, "[ArangoDocument]"
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
    local name, ext_obj;
    
    name := NameRNam( string_as_int );
    
    if name in [ "_createDatabase", "_useDatabase", "_dropDatabase" ] then
        
        return
          function( database_name )
            local output;
            
            output := homalgSendBlocking( [ db!.pointer, ".", name, "(\"", database_name, "\")" ], db!.stream, "need_output" );
            
            return EvalString( output );
            
        end;
        
    elif name in [ "_isSystem" ] then
        
        return
          function( )
            local output;
            
            output := homalgSendBlocking( [ db!.pointer, ".", name, "()" ], db!.stream, "need_output" );
            
            return EvalString( output );
            
        end;
        
    elif name in [ "_name", "_id", "_path" ] then
        
        return
          function( )
            local output;
            
            return homalgSendBlocking( [ db!.pointer, ".", name, "()" ], db!.stream, "need_output" );
            
        end;
        
    elif name in [ "_databases" ] then
        
        return
          function( )
            local ext_obj;
            
            ext_obj := homalgSendBlocking( [ db!.pointer, ".", name, "()" ], db!.stream );
            
            ext_obj!.database := db;
            
            return CreateDatabaseArray( ext_obj );
            
        end;
        
    elif name in [ "_engineStats" ] then
        
        return
          function( )
            local ext_obj;
            
            ext_obj := homalgSendBlocking( [ db!.pointer, ".", name, "()" ], db!.stream );
            
            ext_obj!.database := db;
            
            return CreateDatabaseDocument( ext_obj );
            
        end;
        
    elif name in [ "_help" ] then
        
        return
          function( )
            
            Print( homalgSendBlocking( [ db!.pointer, ".", name, "()" ], db!.stream, "need_display" ) );
            
        end;
        
    elif name = "_create" then
        
        return
          function( collection_name )
            local ext_obj, collection;
            
            ext_obj := homalgSendBlocking( [ db!.pointer, ".", name, "(\"", collection_name, "\")" ], db!.stream );
            
            ext_obj!.name := collection_name;
            ext_obj!.database := db;
            
            collection := CreateDatabaseCollection( ext_obj );
            
            Assert( 0, collection.count() = 0 );
            
            return collection;
            
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
        
    elif name in [ "_createStatement" ] then
        
        return
          function( keys_values_rec )
            local string, output;
            
            string := GapToJsonString( keys_values_rec );
            
            ext_obj := homalgSendBlocking( [ db!.pointer, ".", name, "(", string, ")" ], db!.stream );
            
            ext_obj!.statement := keys_values_rec;
            ext_obj!.database := db;
            
            return CreateDatabaseStatement( ext_obj );
            
        end;
        
    elif name in [ "_query" ] then
        
        return
          function( query_string )
            local output;
            
            if not IsString( query_string ) then
                query_string := Concatenation( query_string );
            fi;
            
            ext_obj := homalgSendBlocking( [ db!.pointer, ".", name, "('", query_string, "')" ], db!.stream );
            
            ext_obj!.query := query_string;
            ext_obj!.database := db;
            
            return CreateDatabaseCursor( ext_obj );
            
        end;
        
    elif name in [ "_exists" ] then
        
        return
          function( _id )
            
            return EvalString( homalgSendBlocking( [ db!.pointer, ".", name, "('", _id, "')" ], db!.stream, "need_output" ) );
            
        end;
        
    elif name in [ "_document" ] then
        
        return
          function( _id )
            
            ext_obj := homalgSendBlocking( [ db!.pointer, ".", name, "('", _id, "')" ], db!.stream );
            
            ext_obj!.database := db;
            
            return CreateDatabaseDocument( ext_obj );
            
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
        return fail;
    fi;
    
    ext_obj := homalgSendBlocking( [ db!.pointer, ".", name ], db!.stream );
    
    ext_obj!.name := name;
    ext_obj!.database := db;
    
    return CreateDatabaseCollection( ext_obj );
    
end );

##
InstallMethod( \.,
        "for a database collections and a positive integer",
        [ IsDatabaseCollectionRep, IsPosInt ],
        
  function( collection, string_as_int )
    local name;
    
    name := NameRNam( string_as_int );
    
    if name in [ "rename" ] then
        
        return
          function( new_collection_name )
            
            homalgSendBlocking( [ collection!.pointer, ".", name, "(\"", new_collection_name, "\")" ], "need_command" );
            
            collection!.Name := Concatenation( "[ArangoCollection \"", new_collection_name, "\"]" );
            
            return collection;
            
        end;
        
    elif name in [ "document" ] then
        
        return
          function( _key )
            local ext_obj;
            
            if IsInt( _key ) then
                _key := String( _key );
            fi;
            
            ext_obj := homalgSendBlocking( [ collection!.pointer, ".", name, "('", _key, "')" ] );
            
            ext_obj!.database := collection!.database;
            
            return CreateDatabaseDocument( ext_obj );
            
        end;
        
    elif name in [ "count" ] then
        
        return
          function( )
            
            return Int( homalgSendBlocking( [ collection!.pointer, ".", name, "()" ], "need_output" ) );
            
        end;
        
    elif name in [ "save", "ensureIndex" ] then
        
        return
          function( keys_values_rec )
            local string, ext_obj;
            
            string := GapToJsonString( keys_values_rec );
            
            ext_obj := homalgSendBlocking( [ collection!.pointer, ".", name, "(", string, ")" ] );
            
            ext_obj!.database := collection!.database;
            
            return CreateDatabaseDocument( ext_obj );
            
        end;
        
    fi;
    
    Error( "collection.", name, " is not supported yet\n" );
    
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
            
            ext_obj := homalgSendBlocking( [ pointer, ".", name, "()" ] );
            
            ext_obj!.database := statement!.database;
            
            return CreateDatabaseCursor( ext_obj );
            
        end;
        
    elif name = "getCount" then
        
        return function( )
            local pointer, output;
            
            pointer := statement!.pointer;
            
            return Int( homalgSendBlocking( [ pointer, ".", name, "()" ], "need_output" ) );
            
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
            
            ext_obj!.database := pointer!.database;
            
            array := CreateDatabaseArray( ext_obj );
            
            SetLength( array, Int( str ) );
            
            array!.Name := Concatenation( "[ArangoArray of length ", str, "]" );
            
            if IsBound( cursor!.conversions ) then
                array!.conversions := cursor!.conversions;
            fi;
            
            return array;
            
        end;
        
    elif name = "count" then
        
        return function( )
            local output;
            
            output := homalgSendBlocking( [ cursor!.pointer, ".", name, "()" ], "need_output" );
            
            if output = "" then
                Error( "cursor.count() returned nothing\n" );
            elif Int( output ) = fail then
                Error( "arangosh returned ", output, " instead of an integer\n" );
            fi;
            
            return Int( output );
            
        end;
        
    elif name = "hasNext" then
        
        return function( )
            
            return EvalString( homalgSendBlocking( [ cursor!.pointer, ".hasNext()" ], "need_output" ) );
            
        end;
        
    elif name = "next" then
        
        return function( )
            local ext_obj, document;
            
            ext_obj := homalgSendBlocking( [ cursor!.pointer, ".next()" ] );
            
            ext_obj!.database := cursor!.database;
            
            document := CreateDatabaseDocument( ext_obj );
            
            if IsBound( cursor!.conversions ) then
                document!.conversions := cursor!.conversions;
            fi;
            
            return document;
            
        end;
        
    fi;
    
    Error( name, " is an unknown or yet unsupported method for database cursors\n" );
    
end );

##
InstallOtherMethod( \[\],
        "for a database array and a positive integer",
        [ IsDatabaseArrayRep, IsPosInt ],
        
  function( array, n )
    local pointer, ext_obj, document;
    
    pointer := array!.pointer;
    
    ext_obj := homalgSendBlocking( [ array!.pointer, "[", String( n - 1 ), "]" ] );
    
    ext_obj!.database := pointer!.database;
    
    document := CreateDatabaseDocument( ext_obj );
    
    if IsBound( array!.conversions ) then
        document!.conversions := array!.conversions;
    fi;
    
    return document;
    
end );

##
InstallMethod( \.,
        "for a database document and a positive integer",
        [ IsDatabaseDocumentRep, IsPosInt ],
        
  function( document, string_as_int )
    local name, v, output, undefined, o, doc, func;
    
    name := NameRNam( string_as_int );
    
    v := document!.pointer!.stream.variable_name;
    
    ## arangosh prevents you from doing both in one step
    output := homalgSendBlocking( [ v, "_d = { \"", name, "\" : ", document!.pointer, ".", name, " }" ], "need_display" );
    
    if Length( output ) <= Length( name ) + 30 then ## only compare if reasonable
        undefined := Concatenation( [ "{ \"", name, "\" : undefined }" ] );
        o := ShallowCopy( output );
        NormalizeWhitespace( o );
        if o = undefined then
            Error( "Document: '<doc>.", name, "' must have an assigned value\n" );
        fi;
    fi;
    
    doc := JsonStringToGap( output );
    
    if IsString( doc.(name) ) then
        ## get the string again through a direct method as it might be truncated
        output := homalgSendBlocking( [ document!.pointer, ".", name ], "need_display" );
        ## the pseudo-tty based interface is not reliable concerning
        ## the number of trailing ENTERs which should be 3 but
        ## too often decreases
        while Length( output ) > 0 and output[Length( output )] = '\n' do
            Remove( output );
        od;
        ## the pseudo-tty based interface is not reliable concerning
        ## the number of preceding ENTERs which should be 0 but
        ## too often decreases
        while Length( output ) > 0 and output[1] = '\n' do
            Remove( output, 1 );
        od;
    else
        output := doc.(name);
    fi;
    
    if IsBound( document!.conversions ) and IsBound( document!.conversions.(name) ) then
        func := document!.conversions.(name);
    else
        func := IdFunc;
    fi;
    
    return func( output );
    
end );

##
InstallMethod( IsBound\.,
        "for a database document and a positive integer",
        [ IsDatabaseDocumentRep, IsPosInt ],
        
  function( document, string_as_int )

    return not \.( document, string_as_int ) = fail;
    
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
    local db, string, options;
    
    db := collection!.database;
    
    string := GapToJsonString( keys_values_rec );
    
    string := [ "UPDATE \"", id, "\" WITH ", string, " IN ", collection!.name ];
    
    options := ValueOption( "OPTIONS" );
    
    if not options = fail then
        Append( string, [ " OPTIONS ", GapToJsonString( options ) ] );
    fi;
    
    return db._query( string );
    
end );

##
InstallMethod( RemoveFromDatabase,
        "for a string and a database collection",
        [ IsString, IsDatabaseCollectionRep ],

  function( id, collection )
    local db, string, options;
    
    db := collection!.database;
    
    string := [ "REMOVE \"", id, "\" IN ", collection!.name ];
    
    options := ValueOption( "OPTIONS" );
    
    if not options = fail then
        Append( string, [ " OPTIONS ", GapToJsonString( options ) ] );
    fi;
    
    return db._query( string );
    
end );

##
InstallGlobalFunction( _ArangoDB_create_filter_string,
  function( query_rec, collection )
    local string, keys, AND, i, key, value, val, limit, sort;
    
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
            if value[2] = fail then
                val := "null";
            else
                if IsString( value[2] ) then
                    val := Concatenation( [ "\"", String( value[2] ), "\"" ] );
                else
                    val := GapToJsonString( value[2] );
                fi;
            fi;
            Append( string, [ AND, "d.", key, " ", value[1], " ", val ] );
        elif IsString( value ) or not IsList( value ) then
            if value = fail then
                val := "null";
            else
                if IsString( value ) then
                    val := Concatenation( [ "\"", String( value ), "\"" ] );
                else
                    val := GapToJsonString( value );
                fi;
            fi;
            Append( string, [ AND, "d.", key, " == ", val ] );
        else
            Error( "wrong syntax of query value: ", value, "\n" );
        fi;
        AND := " && ";
    od;
    
    sort := ValueOption( "SORT" );
    
    if not sort = fail then
        Append( string, [ " SORT d.", String( sort ) ] );
    fi;
    
    limit := ValueOption( "LIMIT" );
    
    if IsInt( limit ) then
        Append( string, [ " LIMIT ", String( limit ) ] );
    fi;
    
    return string;
    
end );

##
InstallGlobalFunction( _ArangoDB_create_filter_return_string,
  function( query_rec, result_rec, collection )
    local string, keys, SEP, func, key, value;
    
    string := _ArangoDB_create_filter_string( query_rec, collection );
    
    Add( string, " RETURN " );
    
    if result_rec = "" then
        Add( string, " d" );
        return Concatenation( string );
    else
        Add( string, "{ " );
    fi;
    
    keys := NamesOfComponents( result_rec );
    
    SEP := "";
    
    func := rec( );
    
    for key in keys do
        value := result_rec.(key);
        if not IsString( value ) and IsList( value ) and Length( value ) = 2 then
            Append( string, [ SEP, key, " : d.", value[1] ] );
            func.(key) := value[2];
        elif IsString( value ) or not IsList( value ) then
            Append( string, [ SEP, key, " : d.", value ] );
            func.(key) := IdFunc;
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
    local string, db;
    
    string := _ArangoDB_create_filter_return_string( query_rec, "", collection!.name );
    
    db := collection!.database;
    
    return db._query( string );
    
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
    local string, func, db, cursor;
    
    string := _ArangoDB_create_filter_return_string( query_rec, result_rec, collection!.name );
    
    func := string[2];
    string := string[1];
    
    db := collection!.database;
    
    cursor := db._query( string );
    
    cursor!.conversions := func;
    
    return cursor;
    
end );

##
InstallMethod( QueryDatabase,
        "for a record, a list, and a database collection",
        [ IsRecord, IsList, IsDatabaseCollectionRep ],

  function( query_rec, result_list, collection )
    local result_rec;
    
    result_rec := rec( );
    
    Perform( result_list, function( key ) result_rec.(key) := key; end );
    
    return QueryDatabase( query_rec, result_rec, collection );
    
end );

##
InstallMethod( MarkFirstDocument,
        "for two records and a database collection",
        [ IsRecord, IsRecord, IsDatabaseCollectionRep ],

  function( query_rec, mark_rec, collection )
    local c, a, keys, key, coll, query, mark, action, r, db, trans;
    
    c := QueryDatabase( query_rec, collection : LIMIT := 1 );
    
    a := c.toArray( );
    
    if Length( a ) = 0 then
        return false;
    fi;
    
    query_rec := ShallowCopy( query_rec );
    
    keys := NamesOfComponents( mark_rec );
    
    for key in keys do
        if not IsBound( query_rec.(key) ) then
            query_rec.(key) := fail;
        fi;
    od;
    
    coll := collection!.name;
    
    query := _ArangoDB_create_filter_string( query_rec, coll : LIMIT := 1 );
    
    mark := [ " UPDATE d WITH " ];
    
    Add( mark, GapToJsonString( mark_rec ) );
    
    Append( mark, [ " IN ", coll ] );
    
    query := Concatenation( query );
    
    mark := Concatenation( mark );
    
    action := [ "function () { ",
                "  var db = require(\"@arangodb\").db;",
                "  var coll = db.", coll, ";",
                "  var c = db._query('", query, mark, "');",
                "}",
                ];
    
    r := rec( collections := rec( write := [ coll ] ),
              waitForSync := true,
              action := Concatenation( action )
              );
    
    db := collection!.database;
    
    trans := db._executeTransaction( r );
    
    if not trans = true then
        Error( "the transaction returned ", String( trans ), "\n" );
    fi;
    
    c := QueryDatabase( mark_rec, collection );
    
    a := c.toArray( );
    
    if Length( a ) = 0 then
        return fail;
    elif not Length( a ) = 1 then
        Error( "expected exactly one document but found ", Length( a ), "\n" );
    fi;
    
    return a[1];
    
end );

##
InstallMethod( Iterator,
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
InstallMethod( Iterator,
        "for a database array",
        [ IsDatabaseArrayRep ],
        
  function( array )
    local iter;
    
    iter := rec(
                counter := 1,
                array := array,
                NextIterator := function( iter ) local d; d := iter!.array[iter!.counter]; iter!.counter := iter!.counter + 1; return d; end,
                IsDoneIterator := iter -> iter!.counter > Length( iter!.array ),
                ShallowCopy := function( iter )
                                 return
                                   rec(
                                       counter := iter!.counter,
                                       array := iter!.array,
                                       NextIterator := iter!.NextIterator,
                                       IsDoneIterator := iter!.IsDoneIterator,
                                       ShallowCopy := iter!.ShallowCopy
                                       );
                               end
                );
    
    return IteratorByFunctions( iter );
    
end );

##
InstallMethod( ListOp,
        "for a database array",
        [ IsDatabaseArrayRep ],

  function( array )
    
    return List( [ 1 .. Length( array ) ], i -> array[i] );
    
end );

##
InstallMethod( ListOp,
        "for a database cursor",
        [ IsDatabaseCursorRep ],

  function( cursor )
    
    return ListOp( cursor.toArray( ) );
    
end );

##
InstallMethod( ListOp,
        "for a database array and a function",
        [ IsDatabaseArrayRep, IsFunction ],

  function( array, f )
    
    return List( [ 1 .. Length( array ) ], i -> f( array[i] ) );
    
end );

##
InstallMethod( ListOp,
        "for a database cursor and a function",
        [ IsDatabaseCursorRep, IsFunction ],

  function( cursor, f )
    
    return ListOp( cursor.toArray( ), f );
    
end );

##
InstallMethod( SumOp,
        "for a database cursor and a function",
        [ IsDatabaseCursorRep, IsFunction ],

  function( cursor, f )
    
    return Sum( List( cursor, f ) );
    
end );

##
InstallMethod( SumOp,
        "for a database array and a function",
        [ IsDatabaseArrayRep, IsFunction ],

  function( array, f )
    
    return Sum( List( array, f ) );
    
end );

##
InstallMethod( DatabaseDocumentToRecord,
        "for a database document",
        [ IsDatabaseDocumentRep ],

  function( document )
    local str, doc, i;
    
    str := homalgSendBlocking( [ document!.pointer ], "need_display" );
    
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

##
InstallMethod( ArangoImport,
        "for a string and a database collection",
        [ IsString, IsDatabaseCollectionRep ],
        
  function( filename, collection )
    local exec, type, pos, separator, options, show, db, credentials, i, output;
    
    exec := [ "arangoimp", "--file", filename ];
    
    Append( exec, [ "--collection", Concatenation( [ "\"", collection!.name, "\"" ] ) ] );
    
    type := ValueOption( "type" );
    
    if type = fail then
        ## try to figure out type from suffix
        
        pos := Positions( filename, '.' );
        
        if pos = [ ] then
            Error( "unable to read of the type as a suffix of the file named: ", filename, "\n" );
        fi;
        
        type := filename{[ pos[Length( pos )] + 1 .. Length( filename ) ]};
        
    fi;
    
    Append( exec, [ "--type", type ] );
    
    if type in [ "csv", "tsv" ] then
        
        separator := ValueOption( "separator" );
        
        if separator = fail then
            separator := ",";
        fi;
        
        Append( exec, [ "--separator", Concatenation( [ "\'", separator, "\'" ] ) ] );
        
    fi;
    
    options := ValueOption( "options" );
    
    if not options = fail then
        Add( exec, options );
    fi;
    
    show := [ "# " ];
    Append( show, exec );
    
    db := collection!.database;
    
    credentials := db!.options;
    
    ## get the credentials of the database
    for i in [ 1 .. Length( credentials ) ] do
        if Length( credentials[i] ) > 9 and credentials[i]{[ 1 .. 9 ]} = "--server." then
            Append( exec, credentials{[ i .. i+1 ]} );
            if not credentials[i] = "--server.password" then
                ## do not show password
                Append( show, credentials{[ i .. i+1 ]} );
            fi;
            i := i + 1;
        fi;
    od;
    
    show := JoinStringsWithSeparator( show, " " );
    
    Display( show );
    
    exec := JoinStringsWithSeparator( exec, " " );
    
    output := ApplyCommandToString( exec );
    
    Display( output );
    
end );

####################################
#
# View, Print, and Display methods:
#
####################################

##
InstallMethod( Display,
        "for a database collection",
        [ IsDatabaseCollectionRep ],
        
  function( collection )
    
    homalgDisplay( collection!.pointer );
    
end );

##
InstallMethod( Display,
        "for a database statement",
        [ IsDatabaseStatementRep ],
        
  function( statement )
    
    homalgDisplay( statement!.pointer );
    
end );

##
InstallMethod( Display,
        "for a database cursor",
        [ IsDatabaseCursorRep ],
        
  function( cursor )
    
    homalgDisplay( cursor!.pointer );
    
end );

##
InstallMethod( Display,
        "for a database array",
        [ IsDatabaseArrayRep ],
        
  function( array )
    
    homalgDisplay( array!.pointer );
    
end );

##
InstallMethod( Display,
        "for a database document",
        [ IsDatabaseDocumentRep ],
        
  function( document )
    
    homalgDisplay( document!.pointer );
    
end );
