#
# ArangoDB: An interface to ArangoDB
#
# Reading the implementation part of the package.
#
ReadPackage( "ArangoDB", "gap/ArangoDB.gi");

if IsBound( MakeThreadLocal ) then
    Perform(
            [
             "HOMALG_IO_ArangoShell",
             ],
            MakeThreadLocal );
fi;
