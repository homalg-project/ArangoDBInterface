#
# ArangoDB: An interface to ArangoDB
#
# Implementations
#

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

##
InstallMethod( SaveToDataBase,
        [ IsRecord, IsString, IsRecord ],

  function( keys_values, collection, stream )
    local key, SEP, string;
    
    string := [ ];
    
    SEP := "";
    
    for key in NamesOfComponents( keys_values ) do
        Append( string, [ SEP, key, " : ",  "\"", String( keys_values.(key) ), "\"" ] );
        SEP := ", ";
    od;
    
    string := Concatenation( string );
    
    homalgSendBlocking( [ "db.", collection, ".save({", string, "})" ], "need_command", stream );
    
end );

##
InstallMethod( QueryDataBase,
        [ IsString, IsRecord ],

  function( query, stream )
    
    return homalgSendBlocking( [ "db._query('", query, "').toArray()" ], "need_output", stream );
    
end );

##
InstallMethod( QueryDataBase,
        [ IsRecord, IsRecord, IsString, IsRecord ],

  function( query_rec, result_rec, collection, stream )
    local string, keys, AND, i, key, value, func, SEP, result;
    
    string := [ "FOR d IN ", collection, " FILTER " ];
    
    keys := NamesOfComponents( query_rec );
    
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
    
    Add( string, " RETURN { " );
    
    keys := NamesOfComponents( result_rec );
    
    func := [ ];
    
    SEP := "";
    
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
    
    string := Concatenation( string );
    
    result := QueryDataBase( string, stream );
    
    Perform( [ 1 .. Length( result ) ],
            function( i )
              if result[i] = '{' then
                  result[i] := '[';
              elif result[i] = '}' then
                  result[i] := ']';
              elif result[i] = ':' then
                  result[i] := ',';
              fi;
            end );
    
    result := EvalString( result );
    
    result := List( result,
                    function( L )
                      local r, i, value;
                      r := rec( );
                      for i in [ 1 .. Length( L ) / 2 ] do
                          r.(L[2*i-1]) := func[i]( L[2*i] );
                      od;
                      return r;
                    end );
    
    return result;
    
end );
