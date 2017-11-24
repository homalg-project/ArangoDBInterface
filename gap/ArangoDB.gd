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

DeclareOperation( "CreateDatabaseCollection",
        [ IshomalgExternalObject, IsArangoDatabase ] );

#! @Description
#!  Truncate an existing database collection with name <A>collection_name</A>
#!  available through the stream record <A>stream</A>.
#! @Arguments collection_name, stream
#! @Returns none
DeclareOperation( "TruncateDatabaseCollection",
        [ IsDatabaseCollection ] );

#! @Description
#!  Create a database sta
#! @Arguments statement_string, collection
#! @Returns a database statement
DeclareOperation( "DatabaseStatement",
        [ IsString, IsDatabaseCollection ] );

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
#!  Update the document with identifier <A>id</A> in <A>collection</A>
#!  using the keys-values record <A>keys_values_rec</A>.
#! @Arguments id, keys_values_rec, collection
#! @Returns none
DeclareOperation( "UpdateDatabase",
        [ IsString, IsRecord, IsDatabaseCollection ] );

#! @Description
#!  Remove the document with identifier <A>id</A> from <A>collection</A>.
#! @Arguments id, collection
#! @Returns none
DeclareOperation( "RemoveFromDatabase",
        [ IsString, IsDatabaseCollection ] );

DeclareGlobalFunction( "_ArangoDB_create_filter_return_string" );

#! @Description
#!  Return the cursor defined by the query within <A>collection</A>
#!  given by <A>query_string</A>
#! @Arguments query_string, collection
#! @Returns a database cursor
#! @Group QueryDatabase
DeclareOperation( "QueryDatabase",
        [ IsString, IsDatabaseCollection ] );

#! @Description
#!  or by the compoents of the record <A>query_rec</A>.
#! @Arguments query_rec, collection
#! @Returns a database cursor
#! @Group QueryDatabase
DeclareOperation( "QueryDatabase",
        [ IsRecord, IsDatabaseCollection ] );

#! @Description
#!  If the record <A>query_rec</A> is not provided then
#!  it defaults to the empty record <C>rec( )</C>.
#! @Arguments collection
#! @Returns a database cursor
#! @Group QueryDatabase
DeclareOperation( "QueryDatabase",
        [ IsDatabaseCollection ] );

#! @Description
#!  If the result record <A>result_rec</A> is provided
#!  then documents in the resulting cursor will
#!  only contain the values of the components of <A>result_rec</A>.
#!  More precisely,
#!  <A>result_rec</A><C>= rec( new_key1_name := "key1_in_document", ... )</C>.
#! @Arguments query_rec, result_rec, collection
#! @Returns a database cursor
#! @Group QueryDatabase
DeclareOperation( "QueryDatabase",
        [ IsRecord, IsRecord, IsDatabaseCollection ] );

#! @Description
#!  Convert <A>cursor</A> into a &GAP; iterator.
#! @Arguments cursor
#! @Returns an iterator
DeclareOperation( "AsIterator",
        [ IsDatabaseCursor ] );

#! @Description
#!  Convert <A>array</A> into a &GAP; list of &GAP; records. <P/>
#!  Use as <C>List</C>(<A>array</A>).
#! @Arguments array
#! @Returns a list
DeclareOperation( "ListOp",
        [ IsDatabaseArray ] );

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
