#
# ArangoDBInterface: An interface to ArangoDB
#
# Declarations
#

#! @Chapter ArangoDB

####################################
#
#! @Section Global variables
#
####################################

#! @Description
DeclareGlobalVariable( "HOMALG_IO_ArangoShell" );

#!
DeclareInfoClass( "InfoArangoDB" );

SetInfoLevel( InfoArangoDB, 2 );

####################################
#
#! @Section GAP categories
#
####################################

#! @Description
#!  The &GAP; category of Arango databases.
DeclareCategory( "IsArangoDatabase",
        IsAttributeStoringRep );

#! @Description
#!  The &GAP; category of collections in a database.
DeclareCategory( "IsDatabaseCollection",
        IsAttributeStoringRep );

#! @Description
#!  The &GAP; category of database statements.
DeclareCategory( "IsDatabaseStatement",
        IsAttributeStoringRep );

#! @Description
#!  The &GAP; category of database cursors.
DeclareCategory( "IsDatabaseCursor",
        IsAttributeStoringRep );

#! @Description
#!  The &GAP; category of database arrays.
DeclareCategory( "IsDatabaseArray",
        IsAttributeStoringRep );

#! @Description
#!  The &GAP; category of documents in a database collecton.
DeclareCategory( "IsDatabaseDocument",
        IsAttributeStoringRep );

####################################
#
#! @Section Constructors
#
####################################

#! @Description
#!  Attach an existing database by invoking <C>arangosh</C> with
#!  an optional list of options <A>opts</A> which if not provided
#!  defaults to <C>HOMALG_IO_ArangoShell.options</C>.
#! @Arguments opts
#! @Returns an Arango database
DeclareGlobalFunction( "AttachAnArangoDatabase" );

DeclareOperation( "_ExtractDatabase",
        [ IshomalgExternalObject ] );

# @Arguments ext_obj
# @Returns a database collection
DeclareOperation( "CreateDatabaseCollection",
        [ IshomalgExternalObject ] );

# @Arguments ext_obj
# @Returns a database statement
DeclareOperation( "CreateDatabaseStatement",
        [ IshomalgExternalObject ] );

# @Arguments ext_obj
# @Returns a database cursor
DeclareOperation( "CreateDatabaseCursor",
        [ IshomalgExternalObject ] );

# @Arguments ext_obj
# @Returns a database array
DeclareOperation( "CreateDatabaseArray",
        [ IshomalgExternalObject ] );

# @Arguments ext_obj
# @Returns a database document
DeclareOperation( "CreateDatabaseDocument",
        [ IshomalgExternalObject ] );

####################################
#
#! @Section Query operations
#
####################################

#! @Description
#!  Insert a new document into <A>collection</A> with keys and values
#!  given by the record <A>keys_values_rec</A>.
#! @Arguments keys_values_rec, collection
#! @Returns none
DeclareOperation( "InsertIntoDatabase",
        [ IsRecord, IsDatabaseCollection ] );

#! @Description
#!  Update the document(s) filtered by the record <A>query_rec</A>
#!  or with the identifier string <A>id</A> in <A>collection</A>
#!  using the keys-values record <A>keys_values_rec</A>.
#! @Arguments query_rec, keys_values_rec, collection
#! @Returns a database cursor
#! @Group UpdateDatabase
DeclareOperation( "UpdateDatabase",
        [ IsRecord, IsRecord, IsDatabaseCollection ] );

#! @Arguments id, keys_values_rec, collection
#! @Group UpdateDatabase
DeclareOperation( "UpdateDatabase",
        [ IsString, IsRecord, IsDatabaseCollection ] );

#! @Description
#!  Remove the document with identifier <A>id</A> from <A>collection</A>.
#! @Arguments id, collection
#! @Returns none
DeclareOperation( "RemoveFromDatabase",
        [ IsString, IsDatabaseCollection ] );

#! @Description
#!  Remove the key with the name <A>key_name</A> from the
#!  documents in the collection <A>coll</A> satisfying the
#!  query record <A>query_rec</A>.
#! @Arguments key_name, query_rec, collection
#! @Returns a database cursor
#! @Group RemoveKeyFromCollection
DeclareOperation( "RemoveKeyFromCollection",
        [ IsString, IsRecord, IsDatabaseCollection ] );

#! @Description
#!  If not specified <A>query_rec</A> defaults to the empty record.
#! @Arguments key_name, collection
#! @Returns a database cursor
#! @Group RemoveKeyFromCollection
DeclareOperation( "RemoveKeyFromCollection",
        [ IsString, IsDatabaseCollection ] );

DeclareGlobalFunction( "_ArangoDB_create_filter_string" );

DeclareGlobalFunction( "_ArangoDB_create_filter_return_string" );

#! @Description
#!  Return the cursor defined by the query within <A>collection</A>
#!  defined by the following options:
#!  * If the option <C>FILTER</C> := <A>query_rec</A>
#!    is provided, then the query is filtered according to
#!    the names of components of the query record <A>query_rec</A> as keys and
#!    the values of the components as values.
#!    A value <C>fail</C> is translated to <C>null</C>.
#!    This is the way to query for nonbound keys.
#!    If a value is a list, then it is iterpreted as
#!    [ "O1", value1, "O2", value2, ... ],
#!    where "O1", "O2", ... are comparison operators
#!    joined with the and operator.
#!    (see <URL>https://docs.arangodb.com/3.2/AQL/Operators.html</URL>).
#!    The interpretation of this list might change in future!
#!  * If the option <C>RETURN</C> := <A>result</A> (result record/list/string)
#!    is provided, then documents in the resulting cursor will
#!    only contain the values of the components of the record <A>result</A>.
#!    More precisely,
#!    <A>RETURN</A><C>:= rec( new_key1_name := "key1_in_document", ... )</C>.
#!    If instead a result list <A>RETURN</A>=<C>[ "key1", "key2", ... ]</C>
#!    is provided then it is automatically converted into
#!    <A>RETURN</A>:=<C>rec( key1 := "key1", key2 := "key2"... )</C>.
#!    <P/>
#! @Arguments collection
#! @Returns a database cursor
#! @Group QueryDatabase
DeclareOperation( "QueryDatabase",
        [ IsDatabaseCollection ] );

#! @Description
#!  <C>QueryDatabase</C>( <A>query_rec</A>, <A>collection</A> )
#!  is a shorthand for
#!  <C>QueryDatabase</C>( <A>collection</A> : <C>FILTER</C> := <A>query_rec</A> ).
#!  <P/>
#! @Arguments query_rec, collection
#! @Returns a database cursor
#! @Group QueryDatabase
DeclareOperation( "QueryDatabase",
        [ IsRecord, IsDatabaseCollection ] );

#! @Description
#!  <C>QueryDatabase</C>( <A>query_rec</A>, <A>result</A>, <A>collection</A> )
#!  is a shorthand for
#!  <C>QueryDatabase</C>( <A>collection</A> : <C>FILTER</C> := <A>query_rec</A>, <C>RETURN</C> := <A>result</A> ).
#! @Arguments query_rec, result, collection
#! @Returns a database cursor
#! @Group QueryDatabase
DeclareOperation( "QueryDatabase",
        [ IsRecord, IsObject, IsDatabaseCollection ] );

#! @Description
#!  Mark by the entries of <A>mark_rec</A> the first <A>n</A> (or less) documents
#!  in <A>collection</A> (1) satisfying <A>query_rec</A> and
#!  (2) not containing values for the keys in <A>mark_rec</A>
#!  and return them in a database array.
#!  If (1) fails return <C>[ false ]</C>.
#!  If (1) and (2) fail return <C>[ fail ]</C>.
#!  The operation is atomic.
#! @Arguments n, query_rec, mark_rec, collection
#! @Returns a database array, <C>false</C>, or <C>fail</C>
DeclareOperation( "MarkFirstNDocuments",
        [ IsInt, IsRecord, IsRecord, IsDatabaseCollection ] );

#! @Description
#!  Returns
#!  <C>MarkFirstNDocuments( 1,</C> <A>query_rec</A>, <A>mark_rec</A>, <A>collection</A> <C>)[1]</C>,
#!  or <C>false</C>, or <C>fail</C>
#! @Arguments query_rec, mark_rec, collection
#! @Returns a database document, <C>false</C>, or <C>fail</C>
DeclareOperation( "MarkFirstDocument",
        [ IsRecord, IsRecord, IsDatabaseCollection ] );

#! @Description
#!  Convert database <A>cursor</A> into a &GAP; iterator. <P/>
#! @Arguments cursor
#! @Returns an iterator
#! @Group Iterator
DeclareOperation( "Iterator",
        [ IsDatabaseCursor ] );

#! @Description
#!  Convert database <A>array</A> into a &GAP; iterator.
#! @Arguments array
#! @Returns an iterator
#! @Group Iterator
DeclareOperation( "Iterator",
        [ IsDatabaseArray ] );

#! @Description
#!  Convert database <A>array</A> into a &GAP; list of database documents. <P/>
#!  Use as <C>List</C>(<A>array</A>). <P/>
#! @Arguments array
#! @Returns a list
#! @Group ListOp
DeclareOperation( "ListOp",
        [ IsDatabaseArray ] );

#! @Description
#!  Convert database <A>cursor</A> into a &GAP; list of database documents. <P/>
#!  Use as <C>List</C>(<A>cursor</A>).
#! @Arguments cursor
#! @Returns a list
#! @Group ListOp
DeclareOperation( "ListOp",
        [ IsDatabaseCursor ] );

#! @Description
#!  Convert database <A>array</A> into a &GAP; list of database documents
#!  by applying the function <A>f</A>. <P/>
#!  Use as <C>List</C>(<A>array</A>, <A>f</A>). <P/>
#! @Arguments array, f
#! @Returns a list
#! @Group ListOp2
DeclareOperation( "ListOp",
        [ IsDatabaseArray, IsFunction ] );

#! @Description
#!  Convert database <A>cursor</A> into a &GAP; list of database documents
#!  by applying the function <A>f</A>. <P/>
#!  Use as <C>List</C>(<A>cursor</A>, <A>f</A>).
#! @Arguments cursor, f
#! @Returns a list
#! @Group ListOp2
DeclareOperation( "ListOp",
        [ IsDatabaseCursor, IsFunction ] );

#! @Description
#!  Convert database <A>cursor</A> into a &GAP; list of database documents
#!  by applying the function <A>f</A>. <P/>
#!  Use as <C>Sum</C>(<A>cursor</A>, <A>f</A>). <P/>
#! @Arguments cursor, f
#! @Returns a list
#! @Group SumOp2
DeclareOperation( "SumOp",
        [ IsDatabaseCursor, IsFunction ] );

#! @Description
#!  Convert database <A>array</A> into a &GAP; list of database documents
#!  by applying the function <A>f</A>. <P/>
#!  Use as <C>Sum</C>(<A>array</A>, <A>f</A>).
#! @Arguments array, f
#! @Returns a list
#! @Group SumOp2
DeclareOperation( "SumOp",
        [ IsDatabaseArray, IsFunction ] );

#! @Description
#!  Convert <A>document</A> into a &GAP; record.
#! @Arguments document
#! @Returns a record
DeclareOperation( "DatabaseDocumentToRecord",
        [ IsDatabaseDocument ] );

#! @Description
#!  Display in <C>arangosh</C>, the Arango shell.
#! @Arguments object
#! @Returns none
DeclareOperation( "DisplayInArangoSh",
        [ IsObject ] );

#! @Description
#!  Import file named <A>filename</A> to <A>collection</A>.
#!  Accepted options:
#!  * type
#!  * separator (as a string, if type is "csv" or "tsv")
#!  * options (remaining options as a string)
#!  
#!  See (<URL>https://docs.arangodb.com/3.2/Manual/Administration/Arangoimp.html</URL>).
#! @Arguments filename, collection
#! @Returns none
DeclareOperation( "ArangoImport",
        [ IsString, IsDatabaseCollection ] );

#! @Description
#!  Check <A>collection</A> for documents <C>d</C> with existing <C>d.(json_key_lock)</C>
#!  created on this server but with no &GAP; process with PID=<C>d.(json_key_lock).PID</C>.
#!  Here <C>json_key_lock := Concatenation( </C><A>json_key</A>, <C>"_lock" )</C>.
#! @Arguments json_key, collection
#! @Returns a list of documents
DeclareOperation( "DocumentsWithDeadLocks",
        [ IsString, IsDatabaseCollection ] );

#! @Description
#!  Remove the deadlocks in all documents found by
#!  <C>DocumentsWithDeadLocks(</C> <A>json_key</A>, <A>collection</A> <C>)</C>.
#! @Arguments json_key, collection
#! @Returns a list of documents
DeclareOperation( "RemoveDeadLocksFromDocuments",
        [ IsString, IsDatabaseCollection ] );
