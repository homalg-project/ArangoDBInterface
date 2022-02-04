# SPDX-License-Identifier: GPL-2.0-or-later
# ArangoDBInterface: A GAP interface to ArangoDB
#
# This file runs package tests without precompiled code.
#
PushOptions(
    rec(
        no_precompiled_code := true,
    )
);

options := rec(
    exitGAP := true,
    testOptions := rec(
        compareFunction := "uptowhitespace",
    ),
);

TestDirectory( DirectoriesPackageLibrary( "ArangoDBInterface", "tst" ), options );

FORCE_QUIT_GAP( 1 ); # if we ever get here, there was an error
